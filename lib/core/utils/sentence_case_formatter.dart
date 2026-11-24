class SentenceCaseFormatter {
  static const Set<int> _sentenceTerminators = {
    0x002E,
    0x0021,
    0x003F,
    0x2026,
    0x3002,
    0xFF01,
    0xFF1F,
  };

  bool _capitalizeNextLetter = true;

  String format(String text, {bool preserveCase = false}) {
    final String source = preserveCase ? text : text.toLowerCase();
    final StringBuffer formatted = StringBuffer();

    for (final int rune in source.runes) {
      final String character = String.fromCharCode(rune);
      if (_capitalizeNextLetter && _isCasedCharacter(character)) {
        formatted.write(preserveCase ? character : character.toUpperCase());
        _capitalizeNextLetter = false;
      } else {
        formatted.write(character);
      }

      if (_sentenceTerminators.contains(rune)) {
        _capitalizeNextLetter = true;
      }
    }

    return formatted.toString();
  }

  bool _isCasedCharacter(String character) => character.toLowerCase() != character.toUpperCase();
}
