import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../controllers/caption_controller.dart';
import '../../controllers/player_controller.dart';
import '../../models/playback_mode.dart';
import 'subtitle_overlay.dart';

class VideoViewport extends StatelessWidget {
  final PlayerController playerController;
  final CaptionController captionController;
  final VoidCallback onToggleFullscreen;
  final VoidCallback? onTapScreen;

  const VideoViewport({
    super.key,
    required this.playerController,
    required this.captionController,
    required this.onToggleFullscreen,
    this.onTapScreen,
  });

  BoxFit _getBoxFit(AspectRatioMode mode) {
    switch (mode) {
      case AspectRatioMode.fit:
        return BoxFit.contain;
      case AspectRatioMode.fill:
        return BoxFit.cover;
      case AspectRatioMode.stretch:
        return BoxFit.fill;
      case AspectRatioMode.fixed16_9:
      case AspectRatioMode.fixed4_3:
        return BoxFit.contain;
    }
  }

  double? _getAspectRatio(AspectRatioMode mode) {
    switch (mode) {
      case AspectRatioMode.fixed16_9:
        return 16.0 / 9.0;
      case AspectRatioMode.fixed4_3:
        return 4.0 / 3.0;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (playerController.videoController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Listener(
      // Windows mouse ergonomics: mouse wheel adjusts volume +- 5%
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          final double delta = pointerSignal.scrollDelta.dy;
          if (delta < 0) {
            playerController.setVolume(playerController.volume + 5.0);
          } else if (delta > 0) {
            playerController.setVolume(playerController.volume - 5.0);
          }
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Click toggles controls visibility, double click toggles fullscreen
        onTap: onTapScreen,
        onDoubleTap: onToggleFullscreen,
        child: Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: _getAspectRatio(playerController.aspectRatioMode) ??
                      (MediaQuery.of(context).size.width / MediaQuery.of(context).size.height),
                  child: Video(
                    controller: playerController.videoController!,
                    fit: _getBoxFit(playerController.aspectRatioMode),
                    controls: NoVideoControls,
                  ),
                ),
              ),
              // Synchronized Caption Overlay
              SubtitleOverlay(captionController: captionController),
            ],
          ),
        ),
      ),
    );
  }
}
