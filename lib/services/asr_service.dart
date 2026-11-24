import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import '../core/constants/app_constants.dart';
import '../core/utils/sentence_case_formatter.dart';
import '../core/utils/storage_paths.dart';
import '../core/utils/wav_parser.dart';
import '../models/asr_state.dart';
import '../models/subtitle_cue.dart';
import 'model_manager.dart';
import 'subtitle_parser.dart';

class ASRService extends ChangeNotifier {
  static ASRService? _instance;
  ASRState _state = const ASRState(status: ASRStatus.unloaded);
  Timer? _idleTimer;
  bool _isCancelled = false;
  int _taskGeneration = 0;
  String? _currentTaskHash;
  sherpa.OfflineRecognizer? _recognizer;

  ASRService._();

  static ASRService get instance {
    _instance ??= ASRService._();
    return _instance!;
  }

  ASRState get state => _state;

  /// Loads cached transcript if available, returning cues or null
  Future<List<SubtitleCue>?> checkCachedTranscript(String fastHash) async {
    final File transcriptFile = StoragePaths.getTranscriptFile(fastHash);
    if (await transcriptFile.exists()) {
      try {
        final List<SubtitleCue> cues = await SubtitleParser.parseFile(transcriptFile);
        if (cues.isNotEmpty) {
          final formatter = SentenceCaseFormatter();
          final normalizedCues = cues.map((cue) {
            final text = formatter.format(cue.text, preserveCase: cue.isEdited);
            return text == cue.text ? cue : cue.copyWith(text: text);
          }).toList();
          _setState(ASRState(status: ASRStatus.completed, cues: normalizedCues, progress: 1.0));
          return normalizedCues;
        }
      } catch (_) {}
    }
    return null;
  }

  /// Starts transcription task for media file
  Future<void> startTranscription({
    required String filePath,
    required String fastHash,
    required Duration? duration,
    String languageMode = 'auto',
  }) async {
    // 1. Cancel any active task
    cancelCurrentTask();
    final int taskGeneration = ++_taskGeneration;
    bool isTaskCancelled() => _isCancelled || taskGeneration != _taskGeneration;
    _idleTimer?.cancel();
    _currentTaskHash = fastHash;
    _isCancelled = false;

    // 2. Check cache first
    final cached = await checkCachedTranscript(fastHash);
    if (isTaskCancelled()) return;
    if (cached != null) return;

    // 3. Download the model on first use, then load it for inference.
    _setState(_state.copyWith(status: ASRStatus.modelLoading, progress: 0.05));
    try {
      await ModelManager.ensureModelAvailable(
        onProgress: (progress) {
          if (!isTaskCancelled()) {
            _setState(ASRState(status: ASRStatus.downloadingModel, progress: progress));
          }
        },
        isCancelled: isTaskCancelled,
      );
    } on ModelDownloadCancelledException {
      return;
    } catch (e) {
      if (!isTaskCancelled()) {
        _setState(ASRState(
          status: ASRStatus.error,
          errorMessage: 'Failed to download speech model: $e',
        ));
      }
      return;
    }

    if (isTaskCancelled()) return;

    // 4. Audio Extraction step
    _setState(_state.copyWith(status: ASRStatus.extractingAudio, progress: 0.15));

    Float32List? audioSamples;
    final String tempWavPath = p.join(StoragePaths.appDataDir.path, '${fastHash}_temp.wav');

    try {
      // Try native Android extraction via MethodChannel
      if (Platform.isAndroid) {
        try {
          const channel = MethodChannel("com.pandasoft.easyplayer/app");
          final bool? success = await channel.invokeMethod<bool>('extractAudio', {
            'inputPath': filePath,
            'outputPath': tempWavPath,
          });
          if (success == true && await File(tempWavPath).exists()) {
            final bytes = await File(tempWavPath).readAsBytes();
            audioSamples = WavParser.parseWavBytes(bytes);
          }
        } catch (_) {}
      }

      // Fallback: If direct WAV file
      if (audioSamples == null && (filePath.endsWith('.wav') || filePath.endsWith('.WAV'))) {
        final file = File(filePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          audioSamples = WavParser.parseWavBytes(bytes);
        }
      }

      // Fallback: Read extracted temp wav if present
      if (audioSamples == null && await File(tempWavPath).exists()) {
        final bytes = await File(tempWavPath).readAsBytes();
        audioSamples = WavParser.parseWavBytes(bytes);
      }
    } catch (_) {}

    if (isTaskCancelled()) return;
    if (audioSamples == null || audioSamples.isEmpty) {
      _deleteTempFile(tempWavPath);
      _setState(const ASRState(
        status: ASRStatus.error,
        errorMessage: 'Unable to extract audio for speech recognition.',
      ));
      return;
    }

    // 5. Active transcription state
    _setState(_state.copyWith(status: ASRStatus.transcribing, progress: 0.25, cues: []));

    final List<SubtitleCue> progressiveCues = [];

    try {
      // Run AI inference with sherpa_onnx.
      try {
        sherpa.initBindings();

        final modelConfig = sherpa.OfflineModelConfig(
          tokens: ModelManager.tokensFile.path,
          senseVoice: sherpa.OfflineSenseVoiceModelConfig(
            model: ModelManager.onnxModelFile.path,
            language: languageMode == 'auto' ? '' : languageMode,
            useInverseTextNormalization: true,
          ),
          numThreads: Platform.isAndroid ? 2 : 4,
          debug: false,
        );

        final config = sherpa.OfflineRecognizerConfig(model: modelConfig);
        _recognizer = sherpa.OfflineRecognizer(config);

        const int sampleRate = 16000;
        const int chunkSeconds = 10;
        const int chunkSamples = sampleRate * chunkSeconds;
        final int totalSamples = audioSamples.length;
        int currentSampleIndex = 0;
        int cueId = 1;
        final sentenceCaseFormatter = SentenceCaseFormatter();

        while (currentSampleIndex < totalSamples) {
          if (isTaskCancelled()) {
            _cleanupRecognizer();
            _setState(_state.copyWith(status: ASRStatus.cancelled));
            _deleteTempFile(tempWavPath);
            return;
          }

          final int nextSampleIndex = (currentSampleIndex + chunkSamples).clamp(0, totalSamples);
          final Float32List segmentSamples = audioSamples.sublist(currentSampleIndex, nextSampleIndex);

          final stream = _recognizer!.createStream();
          stream.acceptWaveform(samples: segmentSamples, sampleRate: sampleRate);
          _recognizer!.decode(stream);
          final result = _recognizer!.getResult(stream);
          stream.free();

          final cleanText = sentenceCaseFormatter.format(
            result.text.replaceAll(RegExp(r'<\|.*?\|>'), '').trim(),
          );

          final int startMs = ((currentSampleIndex * 1000) / sampleRate).round();
          final int endMs = ((nextSampleIndex * 1000) / sampleRate).round();

          if (cleanText.isNotEmpty) {
            final cue = SubtitleCue(
              id: cueId++,
              startMs: startMs,
              endMs: endMs,
              text: cleanText,
            );
            progressiveCues.add(cue);
          }

          final double progress = 0.25 + (0.75 * (nextSampleIndex / totalSamples));
          _setState(_state.copyWith(
            status: ASRStatus.transcribing,
            progress: progress.clamp(0.0, 1.0),
            cues: List.unmodifiable(progressiveCues),
          ));

          currentSampleIndex = nextSampleIndex;
        }
      } finally {
        _cleanupRecognizer();
      }

      // 6. Save transcript to cache
      if (fastHash.isNotEmpty && progressiveCues.isNotEmpty) {
        final File cacheFile = StoragePaths.getTranscriptFile(fastHash);
        final String vttContent = SubtitleParser.toVtt(progressiveCues);
        await cacheFile.writeAsString(vttContent, flush: true);
      }

      _setState(ASRState(
        status: ASRStatus.completed,
        progress: 1.0,
        cues: List.unmodifiable(progressiveCues),
      ));

      _startIdleTimer();
    } catch (e) {
      if (!isTaskCancelled()) {
        _setState(ASRState(
          status: ASRStatus.error,
          errorMessage: 'Speech inference error: $e',
        ));
      }
    } finally {
      _deleteTempFile(tempWavPath);
    }
  }

  void _cleanupRecognizer() {
    try {
      _recognizer?.free();
    } catch (_) {}
    _recognizer = null;
  }

  void _deleteTempFile(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {}
  }

  /// Clears active task and resets state/cues to empty unloaded state
  void clearState() {
    _isCancelled = true;
    _taskGeneration++;
    _currentTaskHash = null;
    _idleTimer?.cancel();
    _cleanupRecognizer();
    _setState(const ASRState(status: ASRStatus.unloaded, cues: []));
  }

  /// Preempt / cancel active transcription
  void cancelCurrentTask() {
    _isCancelled = true;
    _taskGeneration++;
    _currentTaskHash = null;
    _cleanupRecognizer();
    if (_state.isBusy) {
      _setState(const ASRState(status: ASRStatus.cancelled, cues: []));
      _startIdleTimer();
    }
  }

  /// Update an existing cue (inline editing) and re-save transcript
  Future<void> updateCueText(int cueId, String newText) async {
    final List<SubtitleCue> updated = _state.cues.map((c) {
      if (c.id == cueId) {
        return c.copyWith(text: newText, isEdited: true);
      }
      return c;
    }).toList();

    _setState(_state.copyWith(cues: List.unmodifiable(updated)));

    if (_currentTaskHash != null && _currentTaskHash!.isNotEmpty) {
      final File cacheFile = StoragePaths.getTranscriptFile(_currentTaskHash!);
      final String vttContent = SubtitleParser.toVtt(updated);
      await cacheFile.writeAsString(vttContent, flush: true);
    }
  }

  void _startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: AppConstants.modelIdleTimeoutSeconds), () {
      _cleanupRecognizer();
      _setState(const ASRState(status: ASRStatus.unloaded));
    });
  }

  void _setState(ASRState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _cleanupRecognizer();
    super.dispose();
  }
}
