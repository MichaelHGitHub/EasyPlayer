import 'package:easy_player/core/utils/natural_sort.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NaturalSort Tests', () {
    test('sorts numbers naturally (1, 2, 10 instead of 1, 10, 2)', () {
      final list = ['Track 10.mp3', 'Track 2.mp3', 'Track 1.mp3', 'Track 20.mp3'];
      list.sort(NaturalSort.compare);

      expect(list, equals(['Track 1.mp3', 'Track 2.mp3', 'Track 10.mp3', 'Track 20.mp3']));
    });

    test('handles mixed strings with case insensitivity', () {
      final list = ['ep02.mp4', 'EP01.mp4', 'ep10.mp4'];
      list.sort(NaturalSort.compare);

      expect(list, equals(['EP01.mp4', 'ep02.mp4', 'ep10.mp4']));
    });
  });
}
