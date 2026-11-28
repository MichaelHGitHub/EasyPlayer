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

    final mediaItem = MediaItem(
      id: item.id,
      album: itemAlbum,
      title: itemTitle,
      artist: itemArtist,
      duration: duration > Duration.zero ? duration : item.duration,
      artUri: (item.coverArtPath != null && item.coverArtPath!.isNotEmpty)
          ? Uri.file(item.coverArtPath!)
          : null,
    );
    this.mediaItem.add(mediaItem);
  }

  void updatePlaybackState({
    required bool isPlaying,
    required Duration position,
    required Duration duration,
    required double speed,
    required bool hasNext,
    required bool hasPrevious,
  }) {
    final controls = [
      if (hasPrevious) MediaControl.skipToPrevious,
      MediaControl.rewind,
      isPlaying ? MediaControl.pause : MediaControl.play,
      MediaControl.fastForward,
      if (hasNext) MediaControl.skipToNext,
      MediaControl.stop,
    ];

    const int prevIndex = 0;
    final int playPauseIndex = hasPrevious ? 2 : 1;
    final int nextIndex = hasPrevious ? 4 : 3;

    playbackState.add(
      PlaybackState(
        controls: controls,
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: [
          hasPrevious ? prevIndex : 1,
          playPauseIndex,
          hasNext ? nextIndex : playPauseIndex,
        ],
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
