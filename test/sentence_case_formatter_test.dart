import 'package:easy_player/core/utils/sentence_case_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes uppercase speech and capitalizes sentence starts', () {
    final formatter = SentenceCaseFormatter();

    expect(
      formatter.format('HELLO WORLD! THIS IS A TEST.'),
      'Hello world! This is a test.',
    );
  });

  test('keeps sentence casing across transcription chunks', () {
    final formatter = SentenceCaseFormatter();

    expect(formatter.format('THE FIRST SENTENCE CONTINUES'), 'The first sentence continues');
    expect(formatter.format('IN THIS CHUNK. NEXT SENTENCE'), 'in this chunk. Next sentence');
  });

  test('leaves text without letter case unchanged', () {
    final formatter = SentenceCaseFormatter();

    expect(formatter.format('你好。再见！'), '你好。再见！');
  });

  test('preserves manually edited capitalization', () {
    final formatter = SentenceCaseFormatter();

    expect(formatter.format('iPhone and iOS.', preserveCase: true), 'iPhone and iOS.');
    expect(formatter.format('THIS IS NEXT.'), 'This is next.');
  });
}
