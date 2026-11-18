import 'dart:io';
import 'package:path/path.dart' as p;
import '../core/constants/app_constants.dart';

class SidecarSubtitle {
  final String path;
  final String name;
  final String format; // srt, vtt, ass, ssa

  const SidecarSubtitle({
    required this.path,
    required this.name,
    required this.format,
  });
}

class SidecarDetector {
  /// Scans the directory of [mediaFilePath] for sidecar subtitles matching the base name
  static Future<List<SidecarSubtitle>> detect(String mediaFilePath) async {
    final File mediaFile = File(mediaFilePath);
    if (!await mediaFile.exists()) return [];

    final Directory parentDir = mediaFile.parent;
    final String baseName = p.basenameWithoutExtension(mediaFilePath).toLowerCase();
    final List<SidecarSubtitle> detected = [];

    try {
      final List<FileSystemEntity> entities = await parentDir.list().toList();
      for (final entity in entities) {
        if (entity is File) {
          final String ext = p.extension(entity.path).toLowerCase().replaceAll('.', '');
          if (AppConstants.isSubtitle(ext)) {
            final String subBaseName = p.basenameWithoutExtension(entity.path).toLowerCase();
            // Matches exact basename or baseName.locale (e.g., movie.en.srt, movie.zh.vtt)
            if (subBaseName == baseName || subBaseName.startsWith('$baseName.')) {
              detected.add(SidecarSubtitle(
                path: entity.path,
                name: p.basename(entity.path),
                format: ext,
              ));
            }
          }
        }
      }
    } catch (_) {
      // Graceful fallback on permission error
    }

    return detected;
  }
}
