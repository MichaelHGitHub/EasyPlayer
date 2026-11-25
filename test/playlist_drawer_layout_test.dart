import 'package:easy_player/controllers/player_controller.dart';
import 'package:easy_player/controllers/playlist_controller.dart';
import 'package:easy_player/l10n/app_localizations.dart';
import 'package:easy_player/ui/widgets/playlist_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubPlayerController implements PlayerController {
  @override
  bool get isPlaying => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('English queue panel keeps the open-folder action visible', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final PlaylistController playlistController = PlaylistController();
    bool folderOpened = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: PlaylistDrawer(
            playlistController: playlistController,
            playerController: _StubPlayerController(),
            onOpenFile: () {},
            onOpenFolder: () => folderOpened = true,
            asPanel: true,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    final Finder openFolderButton = find.byTooltip('Open Folder');
    expect(openFolderButton, findsOneWidget);
    expect(tester.getRect(openFolderButton).right, lessThanOrEqualTo(320));

    await tester.tap(openFolderButton);
    expect(folderOpened, isTrue);
  });
}
