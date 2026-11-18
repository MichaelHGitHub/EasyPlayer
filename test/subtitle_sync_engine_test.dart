import 'package:easy_player/models/subtitle_cue.dart';
import 'package:easy_player/services/subtitle_sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubtitleSyncEngine Tests', () {
    late SubtitleSyncEngine engine;

    setUp(() {
      engine = SubtitleSyncEngine();
      engine.setCues([
        const SubtitleCue(id: 1, startMs: 1000, endMs: 3000, text: 'Hello world'),
        const SubtitleCue(id: 2, startMs: 4000, endMs: 6000, text: 'EasyPlayer ASR test'),
        const SubtitleCue(id: 3, startMs: 8000, endMs: 10000, text: 'PandaSoft captions'),
      ]);
    });

    test('finds active cue in O(log n)', () {
      final cue = engine.findActiveCue(2000);
      expect(cue, isNotNull);
      expect(cue!.id, 1);
      expect(cue.text, 'Hello world');
    });

    test('returns null when between cues', () {
      final cue = engine.findActiveCue(3500);
      expect(cue, isNull);
    });

    test('respects subtitle delay offset', () {
      // 3500ms with +500ms delay -> effective time = 3000ms (end of cue 1)
      final cue = engine.findActiveCue(3500, subtitleDelayMs: 500);
      expect(cue, isNotNull);
      expect(cue!.id, 1);
    });
  });
}
