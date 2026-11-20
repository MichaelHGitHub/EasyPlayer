import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../core/constants/app_constants.dart';
import '../core/utils/natural_sort.dart';
import '../models/media_item.dart';
import '../models/playback_mode.dart';
import '../services/metadata_extractor.dart';

class PlaylistController extends ChangeNotifier {
  List<MediaItem> _queue = [];
  int _currentIndex = -1;
  PlayMode _playMode = PlayMode.sequential;
  RepeatMode _repeatMode = RepeatMode.none;
  String? _currentDirectory;
  bool _isLoading = false;

  List<MediaItem> get queue => _queue;
  int get currentIndex => _currentIndex;
  MediaItem? get currentItem => (_currentIndex >= 0 && _currentIndex < _queue.length) ? _queue[_currentIndex] : null;
  PlayMode get playMode => _playMode;
  RepeatMode get repeatMode => _repeatMode;
  String? get currentDirectory => _currentDirectory;
  bool get isLoading => _isLoading;
  bool get hasNext => _queue.isNotEmpty && (_repeatMode != RepeatMode.none || _currentIndex < _queue.length - 1);
  bool get hasPrevious => _queue.isNotEmpty && (_repeatMode != RepeatMode.none || _currentIndex > 0);

  void setModes({PlayMode? playMode, RepeatMode? repeatMode}) {
    if (playMode != null) _playMode = playMode;
    if (repeatMode != null) _repeatMode = repeatMode;
    notifyListeners();
  }

  /// Converts SAF content URIs (e.g. content://.../tree/primary%3AMusic) to local file system paths
  static String parseSafPath(String input) {
    if (!input.startsWith('content://')) return input;

    try {
      final String decoded = Uri.decodeFull(input);
      String target = decoded;

      if (target.contains('/document/')) {
        target = target.split('/document/').last;
      } else if (target.contains('/tree/')) {
        target = target.split('/tree/').last;
      }

      if (target.contains('raw:')) {
        return target.split('raw:').last;
      }

      if (target.contains(':')) {
        final parts = target.split(':');
        final drive = parts.first;
        final rel = parts.sublist(1).join(':');
        if (drive.contains('primary')) {
          return '/storage/emulated/0/$rel';
        } else if (drive.isNotEmpty && !drive.contains('/')) {
          return '/storage/$drive/$rel';
        }
      }
    } catch (_) {}

    return input;
  }

  /// Loads all media files from a directory into the queue with natural sorting
  Future<void> loadDirectory(String dirPath, {bool includeSubfolders = false, String? initialFilePath}) async {
    _isLoading = true;
    final String parsedPath = parseSafPath(dirPath);
    final String normalizedPath = p.normalize(parsedPath);
    _currentDirectory = normalizedPath;
    notifyListeners();

    try {
      final Directory dir = Directory(normalizedPath);
      final List<File> mediaFiles = [];

      Future<void> scanDir(bool recursive) async {
        if (!await dir.exists()) return;
        await for (final entity in dir.list(recursive: recursive, followLinks: false).handleError((err) {
          debugPrint('Error accessing entity in $normalizedPath: $err');
        })) {
          final String path = entity.path;
          final String ext = AppConstants.extractExtension(path);
          if (AppConstants.isSupportedMedia(ext)) {
            mediaFiles.add(File(path));
          }
        }
      }

      // Initial scan
      await scanDir(includeSubfolders);

      // Fallback: If no files were found in top directory and includeSubfolders was false, search subfolders automatically
      if (mediaFiles.isEmpty && !includeSubfolders) {
        await scanDir(true);
      }

      // Natural sort by filename
      mediaFiles.sort((a, b) => NaturalSort.compare(p.basename(a.path), p.basename(b.path)));

      final List<MediaItem> items = [];
      for (final file in mediaFiles) {
        try {
          items.add(await MetadataExtractor.createInitialItem(file));
        } catch (e) {
          debugPrint('Error creating item for ${file.path}: $e');
        }
      }

      _queue = items;

      if (initialFilePath != null) {
        final String parsedInitPath = parseSafPath(initialFilePath);
        _currentIndex = _queue.indexWhere((item) => item.filePath == parsedInitPath || item.filePath == initialFilePath);
        if (_currentIndex == -1 && _queue.isNotEmpty) _currentIndex = 0;
      } else if (_queue.isNotEmpty) {
        _currentIndex = 0;
      } else {
        _currentIndex = -1;
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading directory $dirPath: $e\n$stackTrace');
      _queue = [];
      _currentIndex = -1;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sets single item or external file open
  Future<void> setSingleItem(String filePath) async {
    final String parsedPath = parseSafPath(filePath);
    final File file = File(parsedPath);
    final MediaItem item = await MetadataExtractor.createInitialItem(file);
    _queue = [item];
    _currentIndex = 0;
    _currentDirectory = file.parent.path;
    notifyListeners();
  }

  void selectIndex(int index) {
    if (index >= 0 && index < _queue.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// Advances to next item based on PlayMode & RepeatMode
  MediaItem? getNextTrack() {
    if (_queue.isEmpty) return null;

    if (_repeatMode == RepeatMode.track && currentItem != null) {
      return currentItem;
    }

    if (_playMode == PlayMode.single) {
      return null;
    }

    if (_playMode == PlayMode.shuffle) {
      final random = Random();
      int next = random.nextInt(_queue.length);
      if (_queue.length > 1 && next == _currentIndex) {
        next = (next + 1) % _queue.length;
      }
      _currentIndex = next;
      notifyListeners();
      return _queue[_currentIndex];
    }

    // Sequential mode
    if (_currentIndex + 1 < _queue.length) {
      _currentIndex++;
      notifyListeners();
      return _queue[_currentIndex];
    } else if (_repeatMode == RepeatMode.folder) {
      _currentIndex = 0;
      notifyListeners();
      return _queue[_currentIndex];
    }

    return null;
  }

  /// Advances to previous item
  MediaItem? getPreviousTrack() {
    if (_queue.isEmpty) return null;

    if (_playMode == PlayMode.shuffle) {
      final random = Random();
      _currentIndex = random.nextInt(_queue.length);
      notifyListeners();
      return _queue[_currentIndex];
    }

    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
      return _queue[_currentIndex];
    } else if (_repeatMode == RepeatMode.folder) {
      _currentIndex = _queue.length - 1;
      notifyListeners();
      return _queue[_currentIndex];
    }

    return null;
  }
}
