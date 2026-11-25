import 'package:easy_player/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _LocalizationHarness extends StatefulWidget {
  const _LocalizationHarness();

  @override
  State<_LocalizationHarness> createState() => _LocalizationHarnessState();
}

class _LocalizationHarnessState extends State<_LocalizationHarness> {
  Locale _locale = const Locale('en');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) => Scaffold(
          body: Column(
            children: [
              Text(AppLocalizations.of(context)!.settings),
              DropdownButton<Locale>(
                value: _locale,
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text('English')),
                  DropdownMenuItem(
                      value: Locale('zh', 'CN'), child: Text('简体中文')),
                ],
                onChanged: (locale) {
                  if (locale != null) setState(() => _locale = locale);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('updates application strings when locale changes to Chinese',
      (tester) async {
    await tester.pumpWidget(const _LocalizationHarness());
    expect(find.text('Settings'), findsOneWidget);
    expect(
      AppLocalizations.of(tester.element(find.text('Settings')))!
          .transcriptMissing,
      'No transcript file found, use the next button to specify one or generate the script with AI.',
    );

    await tester.tap(find.byType(DropdownButton<Locale>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('简体中文').last);
    await tester.pumpAndSettle();

    expect(find.text('设置'), findsOneWidget);
    expect(
      AppLocalizations.of(tester.element(find.text('设置')))!.loadSubtitle,
      '加载字幕',
    );
  });
}
