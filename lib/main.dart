import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/storage_paths.dart';
import 'l10n/app_localizations.dart';
import 'services/audio_handler.dart';
import 'services/database_service.dart';
import 'services/settings_service.dart';
import 'ui/screens/player_screen.dart';

EasyAudioHandler? globalAudioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Safely initialize AudioService for Lock Screen Media Controls & Background Playback
  try {
    globalAudioHandler = await AudioService.init(
      builder: () => EasyAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.pandasoft.easyplayer.audio',
        androidNotificationChannelName: 'EasyPlayer Playback',
        androidNotificationChannelDescription: 'EasyPlayer lock screen media controls',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
        androidShowNotificationBadge: true,
      ),
    );
  } catch (e, stack) {
    debugPrint('AudioService initialization error: $e\n$stack');
  }

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        size: Size(1280, 720),
        minimumSize: Size(800, 520),
        center: true,
        backgroundColor: Colors.black,
        title: AppConstants.appName,
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  }

  // 1. Initialize deterministic local storage directories
  await StoragePaths.initialize();

  // 2. Initialize SQLite store
  await DatabaseService.instance.database;

  // 3. Load persistent settings
  await SettingsService.instance.loadSettings();

  runApp(const EasyPlayerApp());
}

class EasyPlayerApp extends StatelessWidget {
  const EasyPlayerApp({super.key});

  Locale? _resolveLocale(String uiLanguage) {
    if (uiLanguage == 'zh_CN' || uiLanguage == 'zh') {
      return const Locale('zh', 'CN');
    } else if (uiLanguage == 'en') {
      return const Locale('en', 'US');
    }
    return null; // Follow system
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SettingsService.instance,
      builder: (context, _) {
        final String uiLanguage = SettingsService.instance.settings.uiLanguage;

        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          locale: _resolveLocale(uiLanguage),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const PlayerScreen(),
        );
      },
    );
  }
}
