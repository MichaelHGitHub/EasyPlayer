import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/playback_mode.dart';
import '../../services/sleep_timer_service.dart';

class SleepTimerDialog extends StatelessWidget {
  final SleepTimerService sleepTimerService;
  final double currentVolume;

  const SleepTimerDialog({
    super.key,
    required this.sleepTimerService,
    required this.currentVolume,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: Text(l10n.sleepTimer, style: const TextStyle(color: Colors.white, fontSize: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sleepTimerService.isActive)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                sleepTimerService.isEndOfTrackMode
                    ? l10n.sleepTimerActiveTrack
                    : l10n.sleepTimerActiveRemaining(
                        sleepTimerService.remainingSeconds ~/ 60,
                        sleepTimerService.remainingSeconds % 60,
                      ),
                style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
              ),
            ),
          ListTile(
            dense: true,
            title: Text(l10n.sleep15m, style: const TextStyle(color: Colors.white)),
            onTap: () {
              sleepTimerService.startTimer(SleepTimerMode.m15, currentVolume: currentVolume);
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            title: Text(l10n.sleep30m, style: const TextStyle(color: Colors.white)),
            onTap: () {
              sleepTimerService.startTimer(SleepTimerMode.m30, currentVolume: currentVolume);
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            title: Text(l10n.sleep45m, style: const TextStyle(color: Colors.white)),
            onTap: () {
              sleepTimerService.startTimer(SleepTimerMode.m45, currentVolume: currentVolume);
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            title: Text(l10n.sleep60m, style: const TextStyle(color: Colors.white)),
            onTap: () {
              sleepTimerService.startTimer(SleepTimerMode.m60, currentVolume: currentVolume);
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            title: Text(l10n.sleepEndOfTrack, style: const TextStyle(color: Colors.white)),
            onTap: () {
              sleepTimerService.startTimer(SleepTimerMode.endOfTrack, currentVolume: currentVolume);
              Navigator.pop(context);
            },
          ),
          if (sleepTimerService.isActive)
            ListTile(
              dense: true,
              title: Text(l10n.turnOffSleepTimer, style: const TextStyle(color: Colors.redAccent)),
              onTap: () {
                sleepTimerService.cancelTimer();
                Navigator.pop(context);
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(l10n.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
