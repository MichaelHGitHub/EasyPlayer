import 'package:flutter/material.dart';
import '../../controllers/caption_controller.dart';
import '../../models/subtitle_cue.dart';

class SubtitleOverlay extends StatelessWidget {
  final CaptionController captionController;

  const SubtitleOverlay({
    super.key,
    required this.captionController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: captionController,
      builder: (context, child) {
        if (captionController.sourceType == SubtitleSourceType.off) {
          return const SizedBox.shrink();
        }

        final SubtitleCue? cue = captionController.currentCue;
        if (cue == null || cue.text.isEmpty) {
          return const SizedBox.shrink();
        }

        // Bottom margin percentage calculation (4% - 35%)
        final double bottomFraction = captionController.bottomMarginPercent / 100.0;

        return Align(
          alignment: Alignment(0.0, 1.0 - (bottomFraction * 2.0)),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Text(
              cue.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: captionController.fontSize,
                fontWeight: FontWeight.w600,
                shadows: const [
                  Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
