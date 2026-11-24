import 'package:easy_player/controllers/ab_repeat_controller.dart';
import 'package:easy_player/controllers/caption_controller.dart';
import 'package:easy_player/controllers/player_controller.dart';
import 'package:easy_player/l10n/app_localizations.dart';
import 'package:easy_player/models/subtitle_cue.dart';
import 'package:easy_player/ui/widgets/transcript_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePlayerController implements PlayerController {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('follows active cues off-screen without disabling auto-scroll', (tester) async {
    final captionController = CaptionController();
    final cues = List<SubtitleCue>.generate(
      40,
      (index) => SubtitleCue(
        id: index + 1,
        startMs: index * 1000,
        endMs: (index + 1) * 1000,
        text: 'Transcript cue $index',
      ),
    );
    captionController.setCues(cues);
    captionController.updatePosition(30000);
    final abRepeatController = ABRepeatController();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TranscriptSidebar(
            captionController: captionController,
            playerController: _FakePlayerController(),
            abRepeatController: abRepeatController,
            onClose: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(scrollable.position.pixels, greaterThan(0));
    expect(captionController.isAutoScrollLocked, isTrue);

    await tester.drag(find.byType(ListView), const Offset(0, -100));
    await tester.pumpAndSettle();
    expect(captionController.isAutoScrollLocked, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
    captionController.dispose();
    abRepeatController.dispose();
  });
}
