import 'dart:io';
import 'package:path/path.dart' as p;
import '../core/constants/app_constants.dart';
import '../core/utils/fast_hybrid_hash.dart';
import '../core/utils/storage_paths.dart';
import '../models/media_item.dart';

class MetadataExtractor {
  /// Quick initial media item creation from file without heavy extraction
  static Future<MediaItem> createInitialItem(File file) async {
    final String path = file.path;
    final String fileName = p.basename(path);
    final String ext = p.extension(path).toLowerCase().replaceAll('.', '');
    final int size = await file.length();
    final bool isVideo = AppConstants.isVideo(ext);
    final String hash = await FastHybridHash.compute(file);

    return MediaItem(
      id: hash,
      filePath: path,
      fileName: fileName,
      extension: ext,
      fileSizeBytes: size,
      isVideo: isVideo,
      hasCachedTranscript: await StoragePaths.getTranscriptFile(hash).exists(),
    );
  }

  /// Extracts ID3/Vorbis tags or video thumbnail lazily
  static Future<MediaItem> extractFullMetadata(MediaItem item) async {
    final File artFile = StoragePaths.getAlbumArtFile(item.id);
    String? coverArtPath;

    if (await artFile.exists()) {
      coverArtPath = artFile.path;
    }

    return item.copyWith(
      coverArtPath: coverArtPath,
      title: item.title ?? p.basenameWithoutExtension(item.fileName),
    );
  }
}
