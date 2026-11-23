import 'package:flutter/material.dart';
import '../../controllers/caption_controller.dart';
import '../../controllers/player_controller.dart';
import '../../models/playback_mode.dart';

class TrackSettingsDialog extends StatefulWidget {
  final PlayerController playerController;
  final CaptionController captionController;

  const TrackSettingsDialog({
    super.key,
    required this.playerController,
    required this.captionController,
  });

  @override
  State<TrackSettingsDialog> createState() => _TrackSettingsDialogState();
}

class _TrackSettingsDialogState extends State<TrackSettingsDialog> {
  @override
  Widget build(BuildContext context) {
    final player = widget.playerController;
    final caption = widget.captionController;

    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: const Text('Track & Video Settings', style: TextStyle(color: Colors.white, fontSize: 16)),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Aspect Ratio
              const Text('Aspect Ratio Mode', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
              DropdownButton<AspectRatioMode>(
                value: player.aspectRatioMode,
                isExpanded: true,
                dropdownColor: const Color(0xFF0F172A),
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: AspectRatioMode.fit, child: Text('Fit (Letterbox)')),
                  DropdownMenuItem(value: AspectRatioMode.fill, child: Text('Fill (Crop)')),
                  DropdownMenuItem(value: AspectRatioMode.stretch, child: Text('Stretch')),
                  DropdownMenuItem(value: AspectRatioMode.fixed16_9, child: Text('Fixed 16:9')),
                  DropdownMenuItem(value: AspectRatioMode.fixed4_3, child: Text('Fixed 4:3')),
                ],
                onChanged: (mode) {
                  if (mode != null) {
                    setState(() => player.setAspectRatioMode(mode));
                  }
                },
              ),
              const Divider(color: Colors.white24, height: 24),

              // Subtitle Source Selection
              const Text('Subtitle Source', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
              RadioListTile<SubtitleSourceType>(
                dense: true,
                title: const Text('Off', style: TextStyle(color: Colors.white)),
                value: SubtitleSourceType.off,
                groupValue: caption.sourceType,
                onChanged: (val) {
                  setState(() => caption.setSourceType(SubtitleSourceType.off));
                },
              ),
              RadioListTile<SubtitleSourceType>(
                dense: true,
                title: const Text('Auto-Generated ASR Captions', style: TextStyle(color: Colors.white)),
                value: SubtitleSourceType.autoASR,
                groupValue: caption.sourceType,
                onChanged: (val) async {
                  if (caption.cues.isNotEmpty) {
                    setState(() => caption.setSourceType(SubtitleSourceType.autoASR));
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No transcript file found. Please use the "Start AI Transcription" button to generate script.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
              ),
              if (caption.sidecars.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 4.0),
                  child: Text('Sidecar Files:', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ),
                ...caption.sidecars.map((sidecar) {
                  return RadioListTile<SubtitleSourceType>(
                    dense: true,
                    title: Text(sidecar.name, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    value: SubtitleSourceType.sidecar,
                    groupValue: caption.selectedSidecar?.path == sidecar.path ? SubtitleSourceType.sidecar : null,
                    onChanged: (val) {
                      setState(() => caption.setSourceType(SubtitleSourceType.sidecar, sidecar: sidecar));
                    },
                  );
                }),
              ],

              const Divider(color: Colors.white24, height: 24),

              // Subtitle Timing Delay Offset
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtitle Timing Offset', style: TextStyle(color: Colors.white70)),
                  Text('${caption.subtitleDelayMs} ms', style: const TextStyle(color: Color(0xFF818CF8))),
                ],
              ),
              Slider(
                value: caption.subtitleDelayMs.toDouble().clamp(-10000.0, 10000.0),
                min: -10000.0,
                max: 10000.0,
                divisions: 200,
                onChanged: (val) {
                  setState(() => caption.setDelayMs(val.toInt()));
                },
              ),

              // Subtitle Vertical Bottom Margin
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtitle Vertical Position', style: TextStyle(color: Colors.white70)),
                  Text('${caption.bottomMarginPercent.toInt()}%', style: const TextStyle(color: Color(0xFF818CF8))),
                ],
              ),
              Slider(
                value: caption.bottomMarginPercent.clamp(4.0, 35.0),
                min: 4.0,
                max: 35.0,
                divisions: 31,
                onChanged: (val) {
                  setState(() => caption.setBottomMarginPercent(val));
                },
              ),

              // Subtitle Font Size
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtitle Font Size', style: TextStyle(color: Colors.white70)),
                  Text('${caption.fontSize.toInt()} pt', style: const TextStyle(color: Color(0xFF818CF8))),
                ],
              ),
              Slider(
                value: caption.fontSize.clamp(12.0, 36.0),
                min: 12.0,
                max: 36.0,
                divisions: 24,
                onChanged: (val) {
                  setState(() => caption.setFontSize(val));
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          child: const Text('Done'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
