import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/storage_paths.dart';
import 'services/database_service.dart';
import 'services/settings_service.dart';
import 'ui/screens/player_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('zh', 'CN'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const PlayerScreen(),
        );
      },
    );
  }
}
