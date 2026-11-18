import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/storage_paths.dart';
import '../models/asr_state.dart';
import '../models/subtitle_cue.dart';
import 'model_manager.dart';
import 'subtitle_parser.dart';

class ASRService extends ChangeNotifier {
  static ASRService? _instance;
  ASRState _state = const ASRState(status: ASRStatus.unloaded);
  Timer? _idleTimer;
  bool _isCancelled = false;
  String? _currentTaskHash;

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
          _setState(ASRState(status: ASRStatus.completed, cues: cues, progress: 1.0));
          return cues;
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
    _idleTimer?.cancel();
    _currentTaskHash = fastHash;
    _isCancelled = false;

    // 2. Check cache first
    final cached = await checkCachedTranscript(fastHash);
    if (cached != null) return;

    // 3. Lazy load model if unloaded
    if (_state.status == ASRStatus.unloaded) {
      _setState(_state.copyWith(status: ASRStatus.modelLoading, progress: 0.05));
      final bool ready = await ModelManager.ensureModelExtracted();
      if (!ready) {
        _setState(const ASRState(
          status: ASRStatus.error,
          errorMessage: 'Failed to initialize speech recognition engine.',
        ));
        return;
      }
      _setState(_state.copyWith(status: ASRStatus.idle));
    }

    if (_isCancelled) return;

    // 4. Extraction state
    _setState(_state.copyWith(status: ASRStatus.extractingAudio, progress: 0.15));
    await Future.delayed(const Duration(milliseconds: 300)); // Simulating audio stream setup

    if (_isCancelled) return;

    // 5. Active transcription state
    _setState(_state.copyWith(status: ASRStatus.transcribing, progress: 0.25, cues: []));

    try {
      final List<SubtitleCue> progressiveCues = [];
      final int totalMs = duration?.inMilliseconds ?? 60000;
      const int chunkMs = 4000; // 4 second speech segments

      int currentStart = 0;
      int cueId = 1;

      while (currentStart < totalMs) {
        if (_isCancelled) {
          _setState(_state.copyWith(status: ASRStatus.cancelled));
          return;
        }

        final int endMs = (currentStart + chunkMs).clamp(0, totalMs);
        final double progress = (endMs / totalMs).clamp(0.0, 1.0);

        // Progressive simulated inference step for demonstration/testing
        await Future.delayed(const Duration(milliseconds: 400));

        if (_isCancelled) {
          _setState(_state.copyWith(status: ASRStatus.cancelled));
          return;
        }

        final cue = SubtitleCue(
          id: cueId++,
          startMs: currentStart,
          endMs: endMs,
          text: 'Speech recognition segment $cueId at ${SubtitleCue.formatTimestamp(currentStart)}',
        );

        progressiveCues.add(cue);
        _setState(_state.copyWith(
          status: ASRStatus.transcribing,
          progress: progress,
          cues: List.unmodifiable(progressiveCues),
        ));

        currentStart = endMs;
      }

      // 6. Complete and persist transcript to cache
      final File cacheFile = StoragePaths.getTranscriptFile(fastHash);
      final String vttContent = SubtitleParser.toVtt(progressiveCues);
      await cacheFile.writeAsString(vttContent, flush: true);

      _setState(ASRState(
        status: ASRStatus.completed,
        progress: 1.0,
        cues: List.unmodifiable(progressiveCues),
      ));

      // 7. Start 3-minute idle timer to unload model
      _startIdleTimer();
    } catch (e) {
      if (!_isCancelled) {
        _setState(ASRState(
          status: ASRStatus.error,
          errorMessage: 'Speech inference error: $e',
        ));
      }
    }
  }

  /// Preempt / cancel active transcription
  void cancelCurrentTask() {
    _isCancelled = true;
    _currentTaskHash = null;
    if (_state.isBusy) {
      _setState(_state.copyWith(status: ASRStatus.cancelled));
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

    if (_currentTaskHash != null) {
      final File cacheFile = StoragePaths.getTranscriptFile(_currentTaskHash!);
      final String vttContent = SubtitleParser.toVtt(updated);
      await cacheFile.writeAsString(vttContent, flush: true);
    }
  }

  void _startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: AppConstants.modelIdleTimeoutSeconds), () {
      // Auto-unload after 3 min idle
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
    super.dispose();
  }
}
