import 'package:audio_service/audio_service.dart';
import '../controllers/player_controller.dart';
import '../models/media_item.dart' as model;
import 'settings_service.dart';

class EasyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  PlayerController? _playerController;

  void attachPlayerController(PlayerController controller) {
    _playerController = controller;
  }

  void updateEasyMediaItem(model.MediaItem item, Duration duration) {
    final String itemTitle = (item.title != null && item.title!.isNotEmpty) ? item.title! : item.fileName;
    final String itemArtist = (item.artist != null && item.artist!.isNotEmpty) ? item.artist! : 'EasyPlayer';
    final String itemAlbum = (item.album != null && item.album!.isNotEmpty) ? item.album! : 'EasyPlayer';
    final Duration effectiveDuration = duration > Duration.zero ? duration : (item.duration ?? Duration.zero);
    final Uri? artUri = (item.coverArtPath != null && item.coverArtPath!.isNotEmpty)
        ? Uri.file(item.coverArtPath!)
        : null;

    final currentMediaItem = mediaItem.value;
    if (currentMediaItem != null &&
        currentMediaItem.id == item.id &&
        currentMediaItem.title == itemTitle &&
        currentMediaItem.artist == itemArtist &&
        currentMediaItem.duration == effectiveDuration &&
        currentMediaItem.artUri == artUri) {
      return;
    }

    final newMediaItem = MediaItem(
      id: item.id,
      album: itemAlbum,
      title: itemTitle,
      artist: itemArtist,
      duration: effectiveDuration,
      artUri: artUri,
    );
    mediaItem.add(newMediaItem);
  }

  void updatePlaybackState({
    required bool isPlaying,
    required Duration position,
    required Duration duration,
    required double speed,
    required bool hasNext,
    required bool hasPrevious,
  }) {
    final controls = <MediaControl>[];
    int? prevIndex;
    int playPauseIndex;
    int? nextIndex;

    if (hasPrevious) {
      prevIndex = controls.length;
      controls.add(MediaControl.skipToPrevious);
    }
    controls.add(MediaControl.rewind);

    playPauseIndex = controls.length;
    controls.add(isPlaying ? MediaControl.pause : MediaControl.play);

    controls.add(MediaControl.fastForward);

    if (hasNext) {
      nextIndex = controls.length;
      controls.add(MediaControl.skipToNext);
    }
    controls.add(MediaControl.stop);

    final compactIndices = <int>[];
    if (prevIndex != null) compactIndices.add(prevIndex);
    compactIndices.add(playPauseIndex);
    if (nextIndex != null) compactIndices.add(nextIndex);

    playbackState.add(
      PlaybackState(
        controls: controls,
        systemActions: {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.play,
          MediaAction.pause,
          MediaAction.playPause,
          MediaAction.stop,
          if (hasNext) MediaAction.skipToNext,
          if (hasPrevious) MediaAction.skipToPrevious,
          MediaAction.fastForward,
          MediaAction.rewind,
        },
        androidCompactActionIndices: compactIndices,
        processingState: AudioProcessingState.ready,
        playing: isPlaying,
        updatePosition: position,
        bufferedPosition: position,
        speed: speed,
        queueIndex: 0,
      ),
    );
  }

  @override
  Future<void> play() async {
    await _playerController?.play();
  }

  @override
  Future<void> pause() async {
    await _playerController?.pause();
  }

  @override
  Future<void> stop() async {
    await _playerController?.stop();
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
  }

  @override
  Future<void> seek(Duration position) async {
    await _playerController?.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    final nextTrack = _playerController?.playlistController.getNextTrack();
    if (nextTrack != null) {
      await _playerController?.openMedia(nextTrack);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    final prevTrack = _playerController?.playlistController.getPreviousTrack();
    if (prevTrack != null) {
      await _playerController?.openMedia(prevTrack);
    }
  }

  @override
  Future<void> fastForward() async {
    final int skipSecs = SettingsService.instance.settings.skipForwardSeconds;
    await _playerController?.seekForward(skipSecs);
  }

  @override
  Future<void> rewind() async {
    final int skipSecs = SettingsService.instance.settings.skipBackwardSeconds;
    await _playerController?.seekBackward(skipSecs);
  }
}
