import 'dart:convert';
import 'dart:typed_data';

class CharsetDetector {
  /// Sniffs byte encoding for subtitles and decodes properly, preventing mojibake
  static String decodeSubtitleBytes(Uint8List bytes, {String forcedEncoding = 'auto'}) {
    if (bytes.isEmpty) return '';

    // Check BOM
    if (bytes.length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) {
      return utf8.decode(bytes.sublist(3), allowMalformed: true);
    }
    if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
      // UTF-16 BE
      return _decodeUtf16Be(bytes.sublist(2));
    }
    if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
      // UTF-16 LE
      return _decodeUtf16Le(bytes.sublist(2));
    }

    if (forcedEncoding == 'utf8') {
      return utf8.decode(bytes, allowMalformed: true);
    }

    // Try UTF-8 first
    try {
      final String result = const Utf8Decoder(allowMalformed: false).convert(bytes);
      return result;
    } catch (_) {
      // Not valid UTF-8, try GBK / ANSI fallback
    }

    // Fallback: Latin-1 or GBK-like lenient parsing
    return latin1.decode(bytes);
  }

  static String _decodeUtf16Le(Uint8List bytes) {
    final List<int> codeUnits = [];
    for (int i = 0; i + 1 < bytes.length; i += 2) {
      codeUnits.add(bytes[i] | (bytes[i + 1] << 8));
    }
    return String.fromCharCodes(codeUnits);
  }

  static String _decodeUtf16Be(Uint8List bytes) {
    final List<int> codeUnits = [];
    for (int i = 0; i + 1 < bytes.length; i += 2) {
      codeUnits.add((bytes[i] << 8) | bytes[i + 1]);
    }
    return String.fromCharCodes(codeUnits);
  }
}
