import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/constants/app_constants.dart';
import '../main.dart';
import '../models/media_item.dart';
import '../models/playback_mode.dart';
import '../services/asr_service.dart';
import '../services/database_service.dart';
import '../services/sidecar_detector.dart';
import 'ab_repeat_controller.dart';
import 'caption_controller.dart';
import 'playlist_controller.dart';

class PlayerController extends ChangeNotifier {
  late final Player player;
  VideoController? videoController;

  final PlaylistController playlistController;
  final CaptionController captionController;
  final ABRepeatController abRepeatController;

  StreamSubscription? _positionSub;
  StreamSubscription? _completedSub;
  StreamSubscription? _errorSub;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  double _volume = 100.0;
  double _speed = 1.0;
  bool _isMuted = false;
  AspectRatioMode _aspectRatioMode = AspectRatioMode.fit;
  bool _hasVideo = true;

  PlayerController({
    required this.playlistController,
    required this.captionController,
    required this.abRepeatController,
  }) {
    _initPlayer();
  }

  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _isPlaying;
  double get volume => _volume;
  double get speed => _speed;
  bool get isMuted => _isMuted;
  AspectRatioMode get aspectRatioMode => _aspectRatioMode;
  bool get hasVideo => _hasVideo;

  void _initPlayer() {
    MediaKit.ensureInitialized();

    player = Player(
      configuration: const PlayerConfiguration(
        title: AppConstants.appName,
        ready: null,
      ),
    );

    videoController = VideoController(
      player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: true,
      ),
    );

    globalAudioHandler?.attachPlayerController(this);
    _setupListeners();
  }

  void _syncAudioHandler() {
    final handler = globalAudioHandler;
    if (handler == null) return;

    final MediaItem? current = playlistController.currentItem;
    if (current != null) {
      handler.updateEasyMediaItem(current, _duration);
      handler.updatePlaybackState(
        isPlaying: _isPlaying,
        position: _position,
        duration: _duration,
        speed: _speed,
        hasNext: playlistController.getNextTrack() != null,
        hasPrevious: playlistController.getPreviousTrack() != null,
      );
    }
  }

  void _setupListeners() {
    _positionSub = player.stream.position.listen((pos) {
      _position = pos;
      final int posMs = pos.inMilliseconds;

      // 1. Update caption sync
      captionController.updatePosition(posMs);

      // 2. Check A-B repeat loop
      final int? loopTarget = abRepeatController.checkLoop(posMs);
      if (loopTarget != null) {
        player.seek(Duration(milliseconds: loopTarget));
      }

      // 3. Save playback position periodically (every 5 seconds)
      final MediaItem? current = playlistController.currentItem;
      if (current != null && posMs > 3000) {
        DatabaseService.instance.savePlaybackPosition(current.id, posMs);
      }

      _syncAudioHandler();
      notifyListeners();
    });

    player.stream.duration.listen((dur) {
      _duration = dur;
      _syncAudioHandler();
      notifyListeners();
    });

    player.stream.playing.listen((playing) {
      _isPlaying = playing;
      _syncAudioHandler();
      notifyListeners();
    });

    player.stream.volume.listen((vol) {
      _volume = vol;
      notifyListeners();
    });

    player.stream.rate.listen((r) {
      _speed = r;
      _syncAudioHandler();
      notifyListeners();
    });

    _completedSub = player.stream.completed.listen((completed) {
      if (completed) {
        _handleTrackCompleted();
      }
    });

    _errorSub = player.stream.error.listen((err) {
      // Auto-skip corrupted file
      _handleCorruptedTrack();
    });
  }

  /// Open and play a media item with instant playback
  Future<void> openMedia(MediaItem item) async {
    _hasVideo = item.isVideo;
    notifyListeners();

    // 0. Reset previous transcript & cancel any active ASR task immediately
    ASRService.instance.clearState();
    captionController.setSourceType(SubtitleSourceType.off);
    captionController.setCues([]);

    // 1. Start media_kit playback immediately
    await player.open(Media(item.filePath), play: true);

    // 2. Check cached resume position
    final int? resumeMs = await DatabaseService.instance.getPlaybackPosition(item.id);
    if (resumeMs != null && resumeMs > 3000) {
      await player.seek(Duration(milliseconds: resumeMs));
    }

    // 3. Record recent history
    await DatabaseService.instance.addRecentHistory(item);

    // 4. Scan sidecar subtitles
    final sidecars = await SidecarDetector.detect(item.filePath);
    captionController.setSidecars(sidecars);

    // 5. Check cached transcript for CC
    final cachedCues = await ASRService.instance.checkCachedTranscript(item.id);
    if (cachedCues != null) {
      captionController.setCues(cachedCues);
      // Keep caption OFF by default for each media item. User can turn it on manually.
    }

    _syncAudioHandler();
  }

  void _handleTrackCompleted() {
    final MediaItem? next = playlistController.getNextTrack();
    if (next != null) {
      openMedia(next);
    }
  }

  void _handleCorruptedTrack() {
    final MediaItem? next = playlistController.getNextTrack();
    if (next != null) {
      openMedia(next);
    }
  }

  // --- Transport Controls ---

  Future<void> play() => player.play();
  Future<void> pause() => player.pause();
  Future<void> playOrPause() => player.playOrPause();
  Future<void> stop() => player.stop();

  Future<void> seek(Duration position) => player.seek(position);

  Future<void> seekForward(int seconds) async {
    final target = _position + Duration(seconds: seconds);
    await seek(target > _duration ? _duration : target);
  }

  Future<void> seekBackward(int seconds) async {
    final target = _position - Duration(seconds: seconds);
    await seek(target < Duration.zero ? Duration.zero : target);
  }

  Future<void> setVolume(double vol) => player.setVolume(vol.clamp(0.0, 100.0));

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    await player.setVolume(_isMuted ? 0.0 : _volume);
    notifyListeners();
  }

  Future<void> setSpeed(double rate) => player.setRate(rate);

  void setAspectRatioMode(AspectRatioMode mode) {
    _aspectRatioMode = mode;
    notifyListeners();
  }

  // --- Audio Enhancement Filters ---

  Future<void> applyAudioFilters({
    required bool loudnessNormalization,
    required bool vocalClarityBoost,
  }) async {
    // Dynamic loudnorm and vocal highpass/peaking filter chain for libmpv
    final List<String> filters = [];

    if (loudnessNormalization) {
      filters.add('loudnorm');
    }
    if (vocalClarityBoost) {
      filters.add('lavfi=[highpass=f=80,equalizer=f=3000:width_type=o:width=2:g=3]');
    }

    if (filters.isNotEmpty) {
      // media_kit audio filter assignment
      final filterString = filters.join(',');
      try {
        await (player.platform as dynamic)?.setProperty('af', filterString);
      } catch (_) {}
    } else {
      try {
        await (player.platform as dynamic)?.setProperty('af', '');
      } catch (_) {}
    }
  }

  // --- Video Frame Snapshot ---

  Future<String?> captureSnapshot({bool includeSubtitles = false}) async {
    if (!_hasVideo) return null;

    final Uint8List? screenshotBytes = await player.screenshot();
    if (screenshotBytes == null) {
      throw StateError('Unable to capture the current video frame.');
    }

    final MediaItem? item = playlistController.currentItem;
    final String baseName = item != null ? p.basenameWithoutExtension(item.fileName) : 'easyplayer';
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final String filename = '${baseName}_snapshot_$timestamp.png';

    if (Platform.isAndroid) {
      final String? savedPath =
          await const MethodChannel('com.pandasoft.easyplayer/app').invokeMethod<String>('saveScreenshot', {
        'fileName': filename,
        'bytes': screenshotBytes,
      });
      if (savedPath == null) {
        throw StateError('Android did not return the saved screenshot location.');
      }
      return savedPath;
    }

    late final Directory saveDir;
    if (Platform.isWindows) {
      final String? userProfile = Platform.environment['USERPROFILE'];
      if (userProfile == null || userProfile.isEmpty) {
        throw StateError('Unable to determine the system Pictures folder.');
      }
      saveDir = Directory(p.join(userProfile, 'Pictures', 'Screenshots'));
    } else {
      final Directory appDir = await getApplicationDocumentsDirectory();
      saveDir = Directory(p.join(appDir.path, 'Pictures', 'Screenshots'));
    }

    await saveDir.create(recursive: true);
    final File snapshotFile = File(p.join(saveDir.path, filename));
    await snapshotFile.writeAsBytes(screenshotBytes);

    return snapshotFile.path;
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _completedSub?.cancel();
    _errorSub?.cancel();
    player.dispose();
    super.dispose();
  }
}
