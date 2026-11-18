import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/constants/settings_keys.dart';
import '../models/app_settings.dart';
import '../models/playback_mode.dart';
import 'database_service.dart';

class SettingsService extends ChangeNotifier {
  static SettingsService? _instance;
  late AppSettings _settings;

  SettingsService._() {
    _settings = AppSettings();
  }

  static SettingsService get instance {
    _instance ??= SettingsService._();
    return _instance!;
  }

  AppSettings get settings => _settings;

  Future<void> loadSettings() async {
    final Map<String, String> dbSettings = await DatabaseService.instance.getAllSettings();

    _settings = AppSettings(
      uiLanguage: dbSettings[SettingsKeys.uiLanguage] ?? 'system',
      skipBackwardSeconds: int.tryParse(dbSettings[SettingsKeys.skipBackwardSeconds] ?? '') ?? 5,
      skipForwardSeconds: int.tryParse(dbSettings[SettingsKeys.skipForwardSeconds] ?? '') ?? 10,
      playbackSpeed: double.tryParse(dbSettings[SettingsKeys.playbackSpeed] ?? '') ?? 1.0,
      subtitleFontSize: double.tryParse(dbSettings[SettingsKeys.subtitleFontSize] ?? '') ?? 18.0,
      subtitleBottomMarginPercent: double.tryParse(dbSettings[SettingsKeys.subtitleBottomMarginPercent] ?? '') ?? 8.0,
      subtitleDelayMs: int.tryParse(dbSettings[SettingsKeys.subtitleDelayMs] ?? '') ?? 0,
      subtitleEncoding: SubtitleEncoding.values.firstWhere(
        (e) => e.name == dbSettings[SettingsKeys.subtitleEncoding],
        orElse: () => SubtitleEncoding.auto,
      ),
      overrideAssStyling: dbSettings[SettingsKeys.overrideAssStyling] == 'true',
      snapshotIncludeSubtitles: dbSettings[SettingsKeys.snapshotIncludeSubtitles] == 'true',
      aspectRatioMode: AspectRatioMode.values.firstWhere(
        (e) => e.name == dbSettings[SettingsKeys.aspectRatioMode],
        orElse: () => AspectRatioMode.fit,
      ),
      orientationLock: OrientationLock.values.firstWhere(
        (e) => e.name == dbSettings[SettingsKeys.orientationLock],
        orElse: () => OrientationLock.auto,
      ),
      hardwareAcceleration: dbSettings[SettingsKeys.hardwareAcceleration] != 'false',
      audioNormalization: dbSettings[SettingsKeys.audioNormalization] == 'true',
      voiceClarityBoost: dbSettings[SettingsKeys.voiceClarityBoost] == 'true',
      showAudioEventTags: dbSettings[SettingsKeys.showAudioEventTags] != 'false',
      playMode: PlayMode.values.firstWhere(
        (e) => e.name == dbSettings[SettingsKeys.playMode],
        orElse: () => PlayMode.sequential,
      ),
      repeatMode: RepeatMode.values.firstWhere(
        (e) => e.name == dbSettings[SettingsKeys.repeatMode],
        orElse: () => RepeatMode.none,
      ),
      queueSortOrder: dbSettings[SettingsKeys.queueSortOrder] ?? 'natural_name',
      includeSubfolders: dbSettings[SettingsKeys.includeSubfolders] == 'true',
      asrLanguageMode: dbSettings[SettingsKeys.asrLanguageMode] ?? 'auto',
      recentDirectories: dbSettings[SettingsKeys.recentDirectories] != null
          ? List<String>.from(jsonDecode(dbSettings[SettingsKeys.recentDirectories]!))
          : [],
      sleepTimerMode: SleepTimerMode.values.firstWhere(
        (e) => e.name == dbSettings[SettingsKeys.sleepTimerMode],
        orElse: () => SleepTimerMode.off,
      ),
      sleepTimerCustomMinutes: int.tryParse(dbSettings[SettingsKeys.sleepTimerCustomMinutes] ?? '') ?? 20,
      miniPlayerAlwaysOnTop: dbSettings[SettingsKeys.miniPlayerAlwaysOnTop] == 'true',
      recordPlaybackHistory: dbSettings[SettingsKeys.recordPlaybackHistory] != 'false',
    );

    notifyListeners();
  }

  Future<void> update<T>(String key, T value, void Function(AppSettings) updater) async {
    updater(_settings);
    notifyListeners();

    String stringValue;
    if (value is Enum) {
      stringValue = value.name;
    } else if (value is List || value is Map) {
      stringValue = jsonEncode(value);
    } else {
      stringValue = value.toString();
    }

    await DatabaseService.instance.setSetting(key, stringValue);
  }

  Future<void> addRecentDirectory(String path) async {
    final list = List<String>.from(_settings.recentDirectories);
    list.remove(path);
    list.insert(0, path);
    if (list.length > 10) list.removeLast();

    await update(SettingsKeys.recentDirectories, list, (s) => s.recentDirectories = list);
  }
}
