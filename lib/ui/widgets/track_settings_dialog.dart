import 'package:flutter/material.dart';
import '../../controllers/caption_controller.dart';
import '../../controllers/player_controller.dart';
import '../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: Text(l10n.trackVideoSettings, style: const TextStyle(color: Colors.white, fontSize: 16)),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Aspect Ratio
              Text(l10n.aspectRatioMode, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
              DropdownButton<AspectRatioMode>(
                value: player.aspectRatioMode,
                isExpanded: true,
                dropdownColor: const Color(0xFF0F172A),
                style: const TextStyle(color: Colors.white),
                items: [
                  DropdownMenuItem(value: AspectRatioMode.fit, child: Text(l10n.aspectFit)),
                  DropdownMenuItem(value: AspectRatioMode.fill, child: Text(l10n.aspectFill)),
                  DropdownMenuItem(value: AspectRatioMode.stretch, child: Text(l10n.aspectStretch)),
                  DropdownMenuItem(value: AspectRatioMode.fixed16_9, child: Text(l10n.aspect16_9)),
                  DropdownMenuItem(value: AspectRatioMode.fixed4_3, child: Text(l10n.aspect4_3)),
                ],
                onChanged: (mode) {
                  if (mode != null) {
                    setState(() => player.setAspectRatioMode(mode));
                  }
                },
              ),
              const Divider(color: Colors.white24, height: 24),

              // Subtitle Source Selection
              Text(l10n.subtitleSource, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
              RadioListTile<SubtitleSourceType>(
                dense: true,
                title: Text(l10n.subtitleOff, style: const TextStyle(color: Colors.white)),
                value: SubtitleSourceType.off,
                groupValue: caption.sourceType,
                onChanged: (val) {
                  setState(() => caption.setSourceType(SubtitleSourceType.off));
                },
              ),
              RadioListTile<SubtitleSourceType>(
                dense: true,
                title: Text(l10n.subtitleAutoASR, style: const TextStyle(color: Colors.white)),
                value: SubtitleSourceType.autoASR,
                groupValue: caption.sourceType,
                onChanged: (val) async {
                  if (caption.cues.isNotEmpty) {
                    setState(() => caption.setSourceType(SubtitleSourceType.autoASR));
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
                },
              ),
              if (caption.sidecars.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                  child: Text(l10n.sidecarFiles, style: const TextStyle(color: Colors.white54, fontSize: 12)),
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
                  Text(l10n.subtitleTimingOffset, style: const TextStyle(color: Colors.white70)),
                  Text('${caption.subtitleDelayMs} ${l10n.milliseconds}',
                      style: const TextStyle(color: Color(0xFF818CF8))),
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
                  Text(l10n.subtitleVerticalPosition, style: const TextStyle(color: Colors.white70)),
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
                  Text(l10n.subtitleFontSizePoints, style: const TextStyle(color: Colors.white70)),
                  Text('${caption.fontSize.toInt()} ${l10n.points}', style: const TextStyle(color: Color(0xFF818CF8))),
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
          child: Text(l10n.done),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
