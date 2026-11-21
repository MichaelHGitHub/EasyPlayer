import 'dart:async';
import 'package:flutter/material.dart';
import '../../controllers/ab_repeat_controller.dart';
import '../../controllers/caption_controller.dart';
import '../../controllers/player_controller.dart';
import '../../controllers/playlist_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../models/subtitle_cue.dart';
import '../../services/asr_service.dart';
import '../../services/settings_service.dart';

class PlaybackControls extends StatelessWidget {
  final PlayerController playerController;
  final CaptionController captionController;
  final ABRepeatController abRepeatController;
  final PlaylistController playlistController;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onToggleTranscriptSidebar;
  final VoidCallback onOpenTrackMenu;
  final VoidCallback onOpenSleepTimer;

  const PlaybackControls({
    super.key,
    required this.playerController,
    required this.captionController,
    required this.abRepeatController,
    required this.playlistController,
    required this.onToggleFullscreen,
    required this.onToggleTranscriptSidebar,
    required this.onOpenTrackMenu,
    required this.onOpenSleepTimer,
  });

  String _formatDuration(Duration d) {
    final int hours = d.inHours;
    final int minutes = d.inMinutes % 60;
    final int seconds = d.inSeconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildSeekButton({
    required IconData iconData,
    required int seconds,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: SizedBox(
        width: 30,
        height: 30,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(iconData, size: 30, color: Colors.white),
            Padding(
              padding: const EdgeInsets.only(top: 1.0),
              child: Text(
                '$seconds',
                style: const TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Duration position = playerController.position;
    final Duration duration = playerController.duration;
    final bool isPlaying = playerController.isPlaying;
    final bool hasVideo = playerController.hasVideo;

    final double maxMs = duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
    final double currentMs = position.inMilliseconds.toDouble().clamp(0.0, maxMs);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.85),
            Colors.black.withOpacity(0.0),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Scrub Slider & Timestamps
          Row(
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Expanded(
                child: Slider(
                  value: currentMs,
                  min: 0.0,
                  max: maxMs,
                  onChanged: (val) {
                    playerController.seek(Duration(milliseconds: val.toInt()));
                  },
                ),
              ),
              Text(
                _formatDuration(duration),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),

          // Main Controls Toolbar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              // Left: Play/Pause, Skip, Jump
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Previous
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    tooltip: 'Previous Track',
                    onPressed: playlistController.hasPrevious
                        ? () {
                            final prev = playlistController.getPreviousTrack();
                            if (prev != null) playerController.openMedia(prev);
                          }
                        : null,
                  ),
                  // Jump Backward
                  ListenableBuilder(
                    listenable: SettingsService.instance,
                    builder: (context, _) {
                      final int skipBack = SettingsService.instance.settings.skipBackwardSeconds;
                      return _buildSeekButton(
                        iconData: Icons.rotate_left,
                        seconds: skipBack,
                        tooltip: 'Seek -${skipBack}s',
                        onPressed: () => playerController.seekBackward(skipBack),
                      );
                    },
                  ),
                  // Play / Pause
                  IconButton(
                    iconSize: 36,
                    icon: Icon(
                      isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: const Color(0xFF818CF8),
                    ),
                    tooltip: isPlaying ? 'Pause (Space)' : 'Play (Space)',
                    onPressed: () => playerController.playOrPause(),
                  ),
                  // Jump Forward
                  ListenableBuilder(
                    listenable: SettingsService.instance,
                    builder: (context, _) {
                      final int skipFwd = SettingsService.instance.settings.skipForwardSeconds;
                      return _buildSeekButton(
                        iconData: Icons.rotate_right,
                        seconds: skipFwd,
                        tooltip: 'Seek +${skipFwd}s',
                        onPressed: () => playerController.seekForward(skipFwd),
                      );
                    },
                  ),
                  // Next
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    tooltip: 'Next Track',
                    onPressed: playlistController.hasNext
                        ? () {
                            final next = playlistController.getNextTrack();
                            if (next != null) playerController.openMedia(next);
                          }
                        : null,
                  ),
                  // Expandable Vertical Volume Control
                  VerticalVolumeControl(playerController: playerController),
                ],
              ),

              // Right: Tools (Speed, CC, Sidebar, A-B, Snapshot, Sleep, Fullscreen)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Playback Speed Popup
                  PopupMenuButton<double>(
                    tooltip: 'Playback Speed',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '${playerController.speed.toStringAsFixed(1)}x',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    itemBuilder: (context) {
                      return AppConstants.supportedPlaybackSpeeds.map((rate) {
                        final String label = '${rate.toStringAsFixed(1)}x';
                        final bool isSelected = (playerController.speed - rate).abs() < 0.05;
                        return PopupMenuItem<double>(
                          value: rate,
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF818CF8) : Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList();
                    },
                    onSelected: (rate) => playerController.setSpeed(rate),
                  ),

                  // A-B Repeat Button
                  IconButton(
                    icon: Icon(
                      Icons.repeat,
                      color: abRepeatController.isActive
                          ? const Color(0xFF10B981)
                          : Colors.white70,
                    ),
                    tooltip: abRepeatController.isActive
                        ? 'A-B Loop Active (R to toggle)'
                        : 'Set A-B Repeat (R)',
                    onPressed: () {
                      final pos = playerController.position.inMilliseconds;
                      if (!abRepeatController.hasMarkerA) {
                        abRepeatController.setMarkerA(pos);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Point A set at ${SubtitleCue.formatTimestamp(pos)}'), duration: const Duration(seconds: 1)),
                        );
                      } else if (!abRepeatController.hasMarkerB) {
                        abRepeatController.setMarkerB(pos);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Point B set at ${SubtitleCue.formatTimestamp(pos)}. Looping.'), duration: const Duration(seconds: 1)),
                        );
                      } else {
                        abRepeatController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('A-B Loop Cleared'), duration: Duration(seconds: 1)),
                        );
                      }
                    },
                  ),

                  // Closed Captions (CC) Toggle
                  IconButton(
                    icon: Icon(
                      Icons.closed_caption,
                      color: captionController.sourceType != SubtitleSourceType.off
                          ? const Color(0xFF818CF8)
                          : Colors.white70,
                    ),
                    tooltip: 'Closed Captions (C)',
                    onPressed: () async {
                      if (captionController.sourceType != SubtitleSourceType.off) {
                        captionController.setSourceType(SubtitleSourceType.off);
                      } else {
                        captionController.setSourceType(SubtitleSourceType.autoASR);
                        final item = playlistController.currentItem;
                        if (item != null) {
                          ASRService.instance.startTranscription(
                            filePath: item.filePath,
                            fastHash: item.id,
                            duration: item.duration ?? playerController.duration,
                          );
                        }
                      }
                    },
                  ),

                  // Transcript Sidebar Toggle
                  IconButton(
                    icon: const Icon(Icons.subtitles, color: Colors.white70),
                    tooltip: 'Interactive Transcript Panel',
                    onPressed: onToggleTranscriptSidebar,
                  ),

                  // Video Frame Snapshot (Hot key S)
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white70),
                    tooltip: hasVideo ? 'Snapshot Frame (S)' : 'Snapshot unavailable for audio files',
                    onPressed: hasVideo
                        ? () async {
                            final path = await playerController.captureSnapshot();
                            if (context.mounted && path != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Snapshot saved: $path')),
                              );
                            }
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Snapshot unavailable for audio files')),
                            );
                          },
                  ),

                  // Sleep Timer
                  IconButton(
                    icon: const Icon(Icons.nightlight_round, color: Colors.white70),
                    tooltip: 'Sleep Timer',
                    onPressed: onOpenSleepTimer,
                  ),

                  // Track Settings (Aspect ratio, Audio/Subtitle tracks)
                  IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white70),
                    tooltip: 'Audio & Subtitle Tracks',
                    onPressed: onOpenTrackMenu,
                  ),

                  // Fullscreen Toggle
                  IconButton(
                    icon: const Icon(Icons.fullscreen, color: Colors.white),
                    tooltip: 'Fullscreen (F)',
                    onPressed: onToggleFullscreen,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}

class VerticalVolumeControl extends StatelessWidget {
  final PlayerController playerController;

  const VerticalVolumeControl({super.key, required this.playerController});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      tooltip: 'Volume',
      offset: const Offset(-4, -250),
      constraints: const BoxConstraints(
        minWidth: 50,
        maxWidth: 54,
      ),
      color: const Color(0xFF1E293B),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white24, width: 1),
      ),
      child: ListenableBuilder(
        listenable: playerController,
        builder: (context, _) {
          final bool isMuted = playerController.isMuted || playerController.volume == 0;
          final int volInt = isMuted ? 0 : playerController.volume.round();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isMuted ? Icons.volume_off : (volInt > 50 ? Icons.volume_up : Icons.volume_down),
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 2),
                Text(
                  '$volInt%',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          );
        },
      ),
      itemBuilder: (context) => [
        PopupMenuItem<void>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: ListenableBuilder(
            listenable: playerController,
            builder: (context, _) {
              final double vol = playerController.isMuted ? 0.0 : playerController.volume;
              final int currentVol = playerController.isMuted ? 0 : playerController.volume.round();
              final bool currentlyMuted = playerController.isMuted || playerController.volume == 0;

              return SizedBox(
                width: 50,
                height: 230,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Fixed height title text
                      SizedBox(
                        height: 20,
                        width: 50,
                        child: Center(
                          child: Text(
                            '$currentVol%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Fixed length vertical volume bar centered
                      SizedBox(
                        height: 150,
                        width: 50,
                        child: Center(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: SizedBox(
                              width: 150,
                              child: SliderTheme(
                                data: const SliderThemeData(
                                  trackHeight: 5,
                                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
                                  activeTrackColor: Color(0xFF818CF8),
                                  inactiveTrackColor: Colors.white24,
                                  thumbColor: Color(0xFF818CF8),
                                  overlayColor: Color(0x33818CF8),
                                ),
                                child: Slider(
                                  value: vol.clamp(0.0, 100.0),
                                  min: 0.0,
                                  max: 100.0,
                                  onChanged: (newVol) {
                                    if (playerController.isMuted) {
                                      playerController.toggleMute();
                                    }
                                    playerController.setVolume(newVol);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Mute toggle button centered
                      SizedBox(
                        height: 34,
                        width: 50,
                        child: Center(
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              currentlyMuted ? Icons.volume_off : Icons.volume_up,
                              color: Colors.white70,
                              size: 18,
                            ),
                            onPressed: () {
                              playerController.toggleMute();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
