import 'package:easy_player/models/subtitle_cue.dart';
import 'package:easy_player/services/subtitle_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubtitleParser Tests', () {
    test('parses WebVTT content with NOTE edited=true and timestamps', () {
      const vtt = '''
WEBVTT

NOTE edited=true
00:00:01.500 --> 00:00:04.200
[Laughter] Welcome to EasyPlayer!

00:00:05.000 --> 00:00:08.500
Engineered by PandaSoft.
''';

      final cues = SubtitleParser.parseContent(vtt);
      expect(cues.length, 2);

      expect(cues[0].startMs, 1500);
      expect(cues[0].endMs, 4200);
      expect(cues[0].text, '[Laughter] Welcome to EasyPlayer!');
      expect(cues[0].isEdited, true);
      expect(cues[0].audioEventTag, '[Laughter]');

      expect(cues[1].startMs, 5000);
      expect(cues[1].endMs, 8500);
      expect(cues[1].text, 'Engineered by PandaSoft.');
      expect(cues[1].isEdited, false);
    });

    test('parses SubRip (.srt) content', () {
      const srt = '''
1
00:01:10,250 --> 00:01:15,750
Line 1 of subtitle

2
00:01:16,000 --> 00:01:20,000
Line 2 of subtitle
''';

      final cues = SubtitleParser.parseContent(srt);
      expect(cues.length, 2);
      expect(cues[0].startMs, 70250);
      expect(cues[0].endMs, 75750);
      expect(cues[0].text, 'Line 1 of subtitle');
    });

    test('serializes to WebVTT format', () {
      final cues = [
        const SubtitleCue(id: 1, startMs: 1000, endMs: 3000, text: 'Hello', isEdited: true),
      ];
      final output = SubtitleParser.toVtt(cues);

      expect(output.contains('WEBVTT'), true);
      expect(output.contains('NOTE edited=true'), true);
      expect(output.contains('00:00:01.000 --> 00:00:03.000'), true);
      expect(output.contains('Hello'), true);
    });
  });
}
