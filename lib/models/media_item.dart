class MediaItem {
  final String id; // FastHybridHash
  final String filePath; // Absolute path
  final String fileName; // Display name
  final String extension; // File extension (e.g. mp4, mkv, mp3)
  final int fileSizeBytes;
  final Duration? duration;
  final bool isVideo;
  final String? title; // From ID3/Vorbis tags
  final String? artist;
  final String? album;
  final String? coverArtPath; // Cached thumbnail path
  final bool hasCachedTranscript;
  final int? resumePositionMs; // Last saved playback position
  final DateTime? lastOpenedAt; // Timestamp of last open event

  const MediaItem({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.extension,
    required this.fileSizeBytes,
    this.duration,
    required this.isVideo,
    this.title,
    this.artist,
    this.album,
    this.coverArtPath,
    this.hasCachedTranscript = false,
    this.resumePositionMs,
    this.lastOpenedAt,
  });

  MediaItem copyWith({
    String? id,
    String? filePath,
    String? fileName,
    String? extension,
    int? fileSizeBytes,
    Duration? duration,
    bool? isVideo,
    String? title,
    String? artist,
    String? album,
    String? coverArtPath,
    bool? hasCachedTranscript,
    int? resumePositionMs,
    DateTime? lastOpenedAt,
  }) {
    return MediaItem(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      extension: extension ?? this.extension,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      duration: duration ?? this.duration,
      isVideo: isVideo ?? this.isVideo,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      coverArtPath: coverArtPath ?? this.coverArtPath,
      hasCachedTranscript: hasCachedTranscript ?? this.hasCachedTranscript,
      resumePositionMs: resumePositionMs ?? this.resumePositionMs,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fast_hash': id,
      'file_path': filePath,
      'file_name': fileName,
      'cover_art_path': coverArtPath,
      'duration_ms': duration?.inMilliseconds,
      'resume_pos_ms': resumePositionMs ?? 0,
      'last_opened_at': (lastOpenedAt ?? DateTime.now()).millisecondsSinceEpoch,
    };
  }

  factory MediaItem.fromMap(Map<String, dynamic> map) {
    final String path = map['file_path'] as String;
    final String ext = path.contains('.') ? path.split('.').last.toLowerCase() : '';
    final int? durationMs = map['duration_ms'] as int?;

    return MediaItem(
      id: map['fast_hash'] as String,
      filePath: path,
      fileName: map['file_name'] as String,
      extension: ext,
      fileSizeBytes: map['file_size_bytes'] as int? ?? 0,
      duration: durationMs != null ? Duration(milliseconds: durationMs) : null,
      isVideo: map['is_video'] == 1 || (!['mp3', 'flac', 'wav', 'aac', 'm4a', 'ogg', 'opus', 'wma', 'alac', 'aiff', 'ape'].contains(ext)),
      coverArtPath: map['cover_art_path'] as String?,
      resumePositionMs: map['resume_pos_ms'] as int? ?? 0,
      lastOpenedAt: DateTime.fromMillisecondsSinceEpoch(map['last_opened_at'] as int? ?? 0),
    );
  }
}
