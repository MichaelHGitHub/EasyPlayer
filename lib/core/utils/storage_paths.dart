import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StoragePaths {
  static Directory? _appDataDir;

  static Future<void> initialize() async {
    _appDataDir = await getApplicationSupportDirectory();
    await modelsDir.create(recursive: true);
    await transcriptsDir.create(recursive: true);
    await albumArtCacheDir.create(recursive: true);
    await databaseDir.create(recursive: true);
  }

  static Directory get appDataDir {
    if (_appDataDir == null) {
      throw StateError('StoragePaths must be initialized before accessing paths.');
    }
    return _appDataDir!;
  }

  static Directory get modelsDir => Directory(p.join(appDataDir.path, 'models'));
  static Directory get senseVoiceModelDir => Directory(p.join(modelsDir.path, 'sensevoice_small_int8'));
  static Directory get transcriptsDir => Directory(p.join(appDataDir.path, 'transcripts'));
  static Directory get albumArtCacheDir => Directory(p.join(appDataDir.path, 'cache', 'album_art'));
  static Directory get databaseDir => Directory(p.join(appDataDir.path, 'database'));
  static File get databaseFile => File(p.join(databaseDir.path, 'easyplayer.db'));

  static File getTranscriptFile(String fastHash) => File(p.join(transcriptsDir.path, '$fastHash.vtt'));
  static File getAlbumArtFile(String fastHash) => File(p.join(albumArtCacheDir.path, '$fastHash.jpg'));

  /// Calculate total size of directory in bytes
  static Future<int> getDirectorySize(Directory dir) async {
    if (!await dir.exists()) return 0;
    int total = 0;
    await for (final FileSystemEntity entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }
}
