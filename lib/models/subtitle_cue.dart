class SubtitleCue {
  final int id;
  final int startMs;
  final int endMs;
  final String text;
  final bool isEdited;
  final String? audioEventTag; // e.g. "[Laughter]", "[Applause]"

  const SubtitleCue({
    required this.id,
    required this.startMs,
    required this.endMs,
    required this.text,
    this.isEdited = false,
    this.audioEventTag,
  });

  SubtitleCue copyWith({
    int? id,
    int? startMs,
    int? endMs,
    String? text,
    bool? isEdited,
    String? audioEventTag,
  }) {
    return SubtitleCue(
      id: id ?? this.id,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      text: text ?? this.text,
      isEdited: isEdited ?? this.isEdited,
      audioEventTag: audioEventTag ?? this.audioEventTag,
    );
  }

  /// Formatted timestamp mm:ss.mmm
  static String formatTimestamp(int ms) {
    final Duration d = Duration(milliseconds: ms);
    final String minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    final String millis = (ms % 1000).toString().padLeft(3, '0');
    if (d.inHours > 0) {
      final String hours = d.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds.$millis';
    }
    return '$minutes:$seconds.$millis';
  }

  /// Formatted timestamp for display in UI (e.g. 01:23)
  String get displayStartTime {
    final Duration d = Duration(milliseconds: startMs);
    final String minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
