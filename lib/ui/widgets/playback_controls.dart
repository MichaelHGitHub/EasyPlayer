import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../controllers/ab_repeat_controller.dart';
import '../../controllers/caption_controller.dart';
import '../../controllers/player_controller.dart';
import '../../controllers/playlist_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
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
    required bool isForward,
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
            CustomPaint(
              size: const Size(30, 30),
              painter: SeekIconPainter(
                isForward: isForward,
                color: Colors.white,
              ),
            ),
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
    final l10n = AppLocalizations.of(context)!;
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
                      tooltip: l10n.previousTrack,
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
                          isForward: false,
                          seconds: skipBack,
                          tooltip: l10n.seekBackwardTooltip(skipBack),
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
                      tooltip: isPlaying ? l10n.pauseShortcut : l10n.playShortcut,
                      onPressed: () => playerController.playOrPause(),
                    ),
                    // Jump Forward
                    ListenableBuilder(
                      listenable: SettingsService.instance,
                      builder: (context, _) {
                        final int skipFwd = SettingsService.instance.settings.skipForwardSeconds;
                        return _buildSeekButton(
                          isForward: true,
                          seconds: skipFwd,
                          tooltip: l10n.seekForwardTooltip(skipFwd),
                          onPressed: () => playerController.seekForward(skipFwd),
                        );
                      },
                    ),
                    // Next
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      tooltip: l10n.nextTrack,
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
                      tooltip: l10n.playbackSpeed,
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
                        color: abRepeatController.isActive ? const Color(0xFF10B981) : Colors.white70,
                      ),
                      tooltip: abRepeatController.isActive ? l10n.abLoopActive : l10n.setAbRepeat,
                      onPressed: () {
                        final pos = playerController.position.inMilliseconds;
                        if (!abRepeatController.hasMarkerA) {
                          abRepeatController.setMarkerA(pos);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(l10n.pointASetAt(SubtitleCue.formatTimestamp(pos))),
                                duration: const Duration(seconds: 1)),
                          );
                        } else if (!abRepeatController.hasMarkerB) {
                          abRepeatController.setMarkerB(pos);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(l10n.pointBSetAt(SubtitleCue.formatTimestamp(pos))),
                                duration: const Duration(seconds: 1)),
                          );
                        } else {
                          abRepeatController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.abLoopCleared), duration: const Duration(seconds: 1)),
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
                      tooltip: l10n.closedCaptionsShortcut,
                      onPressed: () async {
                        if (captionController.sourceType != SubtitleSourceType.off) {
                          captionController.setSourceType(SubtitleSourceType.off);
                        } else {
                          final item = playlistController.currentItem;
                          if (item != null) {
                            final cachedCues = await ASRService.instance.checkCachedTranscript(item.id);
                            if (cachedCues != null && cachedCues.isNotEmpty) {
                              captionController.setCues(cachedCues);
                              captionController.setSourceType(SubtitleSourceType.autoASR);
                            } else if (captionController.sidecars.isNotEmpty) {
                              captionController.setSourceType(
                                SubtitleSourceType.sidecar,
                                sidecar: captionController.sidecars.first,
                              );
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.transcriptMissing),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                          }
                        }
                      },
                    ),

                    // Transcript Sidebar Toggle
                    IconButton(
                      icon: const Icon(Icons.subtitles, color: Colors.white70),
                      tooltip: l10n.interactiveTranscriptPanel,
                      onPressed: onToggleTranscriptSidebar,
                    ),

                    // Video Frame Snapshot (Hot key S)
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white70),
                      tooltip: hasVideo ? l10n.snapshotFrameShortcut : l10n.snapshotUnavailableAudio,
                      onPressed: hasVideo
                          ? () async {
                              try {
                                final path = await playerController.captureSnapshot();
                                if (context.mounted && path != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.snapshotSavedPath(path))),
                                  );
                                }
                              } catch (error) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.snapshotSaveFailed(error))),
                                  );
                                }
                              }
                            }
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.snapshotUnavailableAudio)),
                              );
                            },
                    ),

                    // Sleep Timer
                    IconButton(
                      icon: const Icon(Icons.nightlight_round, color: Colors.white70),
                      tooltip: l10n.sleepTimer,
                      onPressed: onOpenSleepTimer,
                    ),

                    // Track Settings (Aspect ratio, Audio/Subtitle tracks)
                    IconButton(
                      icon: const Icon(Icons.tune, color: Colors.white70),
                      tooltip: l10n.audioSubtitleTracks,
                      onPressed: onOpenTrackMenu,
                    ),

                    // Fullscreen Toggle
                    IconButton(
                      icon: const Icon(Icons.fullscreen, color: Colors.white),
                      tooltip: l10n.fullscreen,
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
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<void>(
      tooltip: l10n.volume,
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

class SeekIconPainter extends CustomPainter {
  final bool isForward;
  final Color color;

  const SeekIconPainter({
    required this.isForward,
    this.color = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double radius = size.width * 0.38;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 10:30 position on clock face = -135° (-3pi/4 rad)
    // 1:30 position on clock face = -45° (-pi/4 rad)
    final double endAngle = isForward ? -45 * (math.pi / 180) : -135 * (math.pi / 180);

    const double sweepDegrees = 270.0;
    final double sweepAngle = isForward ? sweepDegrees * (math.pi / 180) : -sweepDegrees * (math.pi / 180);

    final double startAngle = endAngle - sweepAngle;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    canvas.drawArc(rect, startAngle, sweepAngle, false, strokePaint);

    // Calculate arrow tip position at endAngle
    final double tipX = cx + radius * math.cos(endAngle);
    final double tipY = cy + radius * math.sin(endAngle);

    // Tangent direction angle at tip:
    // Clockwise (forward): alpha = endAngle + pi/2
    // Counter-clockwise (backward): alpha = endAngle - pi/2
    final double alpha = isForward ? endAngle + (math.pi / 2) : endAngle - (math.pi / 2);

    const double headLength = 5.5;
    const double wingAngle = 30 * (math.pi / 180);

    final double wing1X = tipX - headLength * math.cos(alpha - wingAngle);
    final double wing1Y = tipY - headLength * math.sin(alpha - wingAngle);
    final double wing2X = tipX - headLength * math.cos(alpha + wingAngle);
    final double wing2Y = tipY - headLength * math.sin(alpha + wingAngle);

    final arrowPath = Path()
      ..moveTo(tipX, tipY)
      ..lineTo(wing1X, wing1Y)
      ..lineTo(wing2X, wing2Y)
      ..close();

    canvas.drawPath(arrowPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant SeekIconPainter oldDelegate) {
    return oldDelegate.isForward != isForward || oldDelegate.color != color;
  }
}
