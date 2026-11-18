import 'subtitle_cue.dart';

enum ASRStatus {
  unloaded, // Model not in memory
  modelLoading, // Lazy-loading ONNX session
  idle, // Model loaded and resident; no transcription active
  extractingAudio, // Demuxing & resampling audio to 16kHz PCM
  transcribing, // Active ONNX inference
  completed, // Transcription finished
  cancelled, // Task preempted
  error // Inference or extraction failure
}

class ASRState {
  final ASRStatus status;
  final double progress; // 0.0 to 1.0
  final List<SubtitleCue> cues;
  final String? errorMessage;

  const ASRState({
    required this.status,
    this.progress = 0.0,
    this.cues = const [],
    this.errorMessage,
  });

  ASRState copyWith({
    ASRStatus? status,
    double? progress,
    List<SubtitleCue>? cues,
    String? errorMessage,
  }) {
    return ASRState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      cues: cues ?? this.cues,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isBusy =>
      status == ASRStatus.modelLoading ||
      status == ASRStatus.extractingAudio ||
      status == ASRStatus.transcribing;

  bool get isReady => status == ASRStatus.completed || cues.isNotEmpty;
}
