import 'package:flutter/material.dart';
import '../../controllers/ab_repeat_controller.dart';
import '../../controllers/caption_controller.dart';
import '../../controllers/player_controller.dart';
import '../../controllers/playlist_controller.dart';
import '../../models/subtitle_cue.dart';
import '../../services/asr_service.dart';

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
                  // Jump -5s
                  IconButton(
                    icon: const Icon(Icons.replay_5, color: Colors.white),
                    tooltip: 'Seek -5s',
                    onPressed: () => playerController.seekBackward(5),
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
                  // Jump +10s
                  IconButton(
                    icon: const Icon(Icons.forward_10, color: Colors.white),
                    tooltip: 'Seek +10s',
                    onPressed: () => playerController.seekForward(10),
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
                  // Volume Slider & Mute
                  IconButton(
                    icon: Icon(
                      playerController.isMuted || playerController.volume == 0
                          ? Icons.volume_off
                          : Icons.volume_up,
                      color: Colors.white,
                    ),
                    tooltip: 'Mute (M)',
                    onPressed: () => playerController.toggleMute(),
                  ),
                  SizedBox(
                    width: 70,
                    child: Slider(
                      value: playerController.isMuted ? 0.0 : playerController.volume,
                      min: 0.0,
                      max: 100.0,
                      onChanged: (vol) => playerController.setVolume(vol),
                    ),
                  ),
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
                        '${playerController.speed}x',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    itemBuilder: (context) => [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((rate) {
                      return PopupMenuItem<double>(
                        value: rate,
                        child: Text('${rate}x'),
                      );
                    }).toList(),
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
