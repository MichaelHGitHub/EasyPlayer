import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/playback_mode.dart';

class SleepTimerService extends ChangeNotifier {
  Timer? _timer;
  Timer? _fadeTimer;
  int _remainingSeconds = 0;
  bool _isEndOfTrackMode = false;
  double? _preFadeVolume;
  Function(double volume)? _volumeSetter;
  VoidCallback? _onStopPlayback;

  int get remainingSeconds => _remainingSeconds;
  bool get isActive => _timer != null || _isEndOfTrackMode;
  bool get isEndOfTrackMode => _isEndOfTrackMode;

  void configure({
    required Function(double volume) volumeSetter,
    required VoidCallback onStopPlayback,
  }) {
    _volumeSetter = volumeSetter;
    _onStopPlayback = onStopPlayback;
  }

  void startTimer(SleepTimerMode mode, {int customMinutes = 20, double currentVolume = 100.0}) {
    cancelTimer();

    if (mode == SleepTimerMode.off) {
      return;
    }

    if (mode == SleepTimerMode.endOfTrack) {
      _isEndOfTrackMode = true;
      notifyListeners();
      return;
    }

    int minutes = 0;
    switch (mode) {
      case SleepTimerMode.m15:
        minutes = 15;
        break;
      case SleepTimerMode.m30:
        minutes = 30;
        break;
      case SleepTimerMode.m45:
        minutes = 45;
        break;
      case SleepTimerMode.m60:
        minutes = 60;
        break;
      case SleepTimerMode.custom:
        minutes = customMinutes;
        break;
      default:
        return;
    }

    _preFadeVolume = currentVolume;
    _remainingSeconds = minutes * 60;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();

        // 15 seconds fade out
        if (_remainingSeconds <= 15 && _remainingSeconds > 0) {
          _performFadeStep(_remainingSeconds / 15.0);
        }
      } else {
        _triggerStop();
      }
    });
  }

  void _performFadeStep(double ratio) {
    if (_volumeSetter != null && _preFadeVolume != null) {
      final double faded = (_preFadeVolume! * ratio).clamp(0.0, 100.0);
      _volumeSetter!(faded);
    }
  }

  void _triggerStop() {
    cancelTimer();
    _onStopPlayback?.call();
    if (_volumeSetter != null && _preFadeVolume != null) {
      // Restore volume setting for future playbacks
      _volumeSetter!(_preFadeVolume!);
    }
  }

  void onTrackEnded() {
    if (_isEndOfTrackMode) {
      _triggerStop();
    }
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _fadeTimer?.cancel();
    _fadeTimer = null;
    _isEndOfTrackMode = false;
    _remainingSeconds = 0;

    // Restore volume if cancelled during fade
    if (_volumeSetter != null && _preFadeVolume != null) {
      _volumeSetter!(_preFadeVolume!);
      _preFadeVolume = null;
    }

    notifyListeners();
  }
}
