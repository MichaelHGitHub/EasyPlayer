class AppConstants {
  static const String appName = 'EasyPlayer';
  static const String developer = 'PandaSoft';
  static const String androidPackage = 'com.pandasoft.easyplayer';
  static const String windowsPackage = 'PandaSoft.EasyPlayer';
  static const String appVersion = '1.0.0';

  // Playback speeds supported by EasyPlayer
  static const List<double> supportedPlaybackSpeeds = [
    0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 2.0
  ];

  // Audio Extensions
  static const Set<String> audioExtensions = {
    'mp3', 'flac', 'wav', 'aac', 'm4a', 'ogg', 'opus', 'wma', 'alac', 'aiff', 'ape'
  };

  // Video Extensions
  static const Set<String> videoExtensions = {
    'mp4', 'mkv', 'webm', 'avi', 'mov', 'flv', 'wmv', 'ts', '3gp'
  };

  // Subtitle Extensions
  static const Set<String> subtitleExtensions = {
    'srt', 'vtt', 'ass', 'ssa'
  };

  static String extractExtension(String input) {
    String clean = input.trim();
    if (clean.contains('/') || clean.contains('\\')) {
      final int lastDot = clean.lastIndexOf('.');
      if (lastDot != -1 && lastDot > clean.lastIndexOf('/') && lastDot > clean.lastIndexOf('\\')) {
        clean = clean.substring(lastDot + 1);
      }
    } else if (clean.contains('.')) {
      clean = clean.split('.').last;
    }
    return clean.toLowerCase().replaceAll('.', '').trim();
  }

  // Check supported media
  static bool isAudio(String ext) => audioExtensions.contains(extractExtension(ext));
  static bool isVideo(String ext) => videoExtensions.contains(extractExtension(ext));
  static bool isSupportedMedia(String ext) => isAudio(ext) || isVideo(ext);
  static bool isSubtitle(String ext) => subtitleExtensions.contains(extractExtension(ext));

  // Storage constants
  static const String dbName = 'easyplayer.db';
  static const int maxRecentHistory = 20;
  static const int maxPlaybackPositions = 500;
  static const int maxRecentDirectories = 10;
  static const int modelIdleTimeoutSeconds = 180; // 3 minutes
}
