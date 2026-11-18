import 'package:flutter/material.dart';
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
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: const Text('Sleep Timer', style: TextStyle(color: Colors.white, fontSize: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sleepTimerService.isActive)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                sleepTimerService.isEndOfTrackMode
                    ? 'Timer Active: Will stop after current track'
                    : 'Timer Active: ${sleepTimerService.remainingSeconds ~/ 60}m ${sleepTimerService.remainingSeconds % 60}s remaining',
                style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
              ),
            ),
          ListTile(
            dense: true,
            title: const Text('15 Minutes', style: TextStyle(color: Colors.white)),
            onTap: () {
              sleepTimerService.startTimer(SleepTimerMode.m15, currentVolume: currentVolume);
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            title: const Text('30 Minutes', style: TextStyle(color: Colors.white)),
            onTap: () {
              sleepTimerService.startTimer(SleepTimerMode.m30, currentVolume: currentVolume);
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            title: const Text('45 Minutes', style: TextStyle(color: Colors.white)),
            onTap: () {
              sleepTimerService.startTimer(SleepTimerMode.m45, currentVolume: currentVolume);
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            title: const Text('60 Minutes', style: TextStyle(color: Colors.white)),
            onTap: () {
              sleepTimerService.startTimer(SleepTimerMode.m60, currentVolume: currentVolume);
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: true,
            title: const Text('Stop after current track finishes', style: TextStyle(color: Colors.white)),
            onTap: () {
              sleepTimerService.startTimer(SleepTimerMode.endOfTrack, currentVolume: currentVolume);
              Navigator.pop(context);
            },
          ),
          if (sleepTimerService.isActive)
            ListTile(
              dense: true,
              title: const Text('Turn Off Sleep Timer', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                sleepTimerService.cancelTimer();
                Navigator.pop(context);
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
