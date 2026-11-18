import 'dart:io';
import 'dart:typed_data';
import '../core/utils/charset_detector.dart';
import '../models/subtitle_cue.dart';

class SubtitleParser {
  static final RegExp _vttTimestampRegex = RegExp(r'(?:(\d{2}):)?(\d{2}):(\d{2})[\.,](\d{3})\s*-->\s*(?:(\d{2}):)?(\d{2}):(\d{2})[\.,](\d{3})');
  static final RegExp _audioEventRegex = RegExp(r'\[(Laughter|Applause|Music|Sigh|Gasp|Cough)\]', caseSensitive: false);

  /// Parse a subtitle file (.srt or .vtt)
  static Future<List<SubtitleCue>> parseFile(File file, {String encoding = 'auto'}) async {
    final Uint8List bytes = await file.readAsBytes();
    final String content = CharsetDetector.decodeSubtitleBytes(bytes, forcedEncoding: encoding);
    return parseContent(content);
  }

  /// Parse subtitle string content
  static List<SubtitleCue> parseContent(String content) {
    final List<String> lines = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
    final List<SubtitleCue> cues = [];

    int currentId = 1;
    int? currentStart;
    int? currentEnd;
    final List<String> currentTextLines = [];
    bool isEdited = false;
    String? audioEventTag;

    for (int i = 0; i < lines.length; i++) {
      final String rawLine = lines[i];
      final String line = rawLine.trim();

      if (line.isEmpty) {
        if (currentStart != null && currentEnd != null && currentTextLines.isNotEmpty) {
          final String fullText = currentTextLines.join('\n').trim();
          cues.add(SubtitleCue(
            id: currentId++,
            startMs: currentStart,
            endMs: currentEnd,
            text: fullText,
            isEdited: isEdited,
            audioEventTag: audioEventTag,
          ));
        }
        currentStart = null;
        currentEnd = null;
        currentTextLines.clear();
        isEdited = false;
        audioEventTag = null;
        continue;
      }

      // Check VTT header / NOTE
      if (line.startsWith('WEBVTT') || line.startsWith('X-TIMESTAMP-MAP')) {
        continue;
      }
      if (line.startsWith('NOTE')) {
        if (line.contains('edited=true')) {
          isEdited = true;
        }
        continue;
      }

      // Check timestamp line
      final Match? match = _vttTimestampRegex.firstMatch(line);
      if (match != null) {
        currentStart = _parseTimeGroup(match.group(1), match.group(2)!, match.group(3)!, match.group(4)!);
        currentEnd = _parseTimeGroup(match.group(5), match.group(6)!, match.group(7)!, match.group(8)!);
        continue;
      }

      // If line is just integer index (SRT numbering) before timestamps
      if (currentStart == null && int.tryParse(line) != null) {
        continue;
      }

      // Content line
      if (currentStart != null) {
        final Match? eventMatch = _audioEventRegex.firstMatch(line);
        if (eventMatch != null) {
          audioEventTag = eventMatch.group(0);
        }
        currentTextLines.add(line);
      }
    }

    // Add trailing cue if any
    if (currentStart != null && currentEnd != null && currentTextLines.isNotEmpty) {
      final String fullText = currentTextLines.join('\n').trim();
      cues.add(SubtitleCue(
        id: currentId,
        startMs: currentStart,
        endMs: currentEnd,
        text: fullText,
        isEdited: isEdited,
        audioEventTag: audioEventTag,
      ));
    }

    return cues;
  }

  static int _parseTimeGroup(String? hoursStr, String minutesStr, String secondsStr, String millisStr) {
    final int hours = hoursStr != null ? int.parse(hoursStr) : 0;
    final int minutes = int.parse(minutesStr);
    final int seconds = int.parse(secondsStr);
    final int millis = int.parse(millisStr);

    return (hours * 3600000) + (minutes * 60000) + (seconds * 1000) + millis;
  }

  /// Serialize cues to WebVTT (.vtt)
  static String toVtt(List<SubtitleCue> cues) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('WEBVTT\n');

    for (int i = 0; i < cues.length; i++) {
      final SubtitleCue cue = cues[i];
      if (cue.isEdited) {
        buffer.writeln('NOTE edited=true');
      }
      buffer.writeln('${_formatVttTimestamp(cue.startMs)} --> ${_formatVttTimestamp(cue.endMs)}');
      buffer.writeln(cue.text);
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Serialize cues to SubRip (.srt)
  static String toSrt(List<SubtitleCue> cues) {
    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < cues.length; i++) {
      final SubtitleCue cue = cues[i];
      buffer.writeln('${i + 1}');
      buffer.writeln('${_formatSrtTimestamp(cue.startMs)} --> ${_formatSrtTimestamp(cue.endMs)}');
      buffer.writeln(cue.text);
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Serialize cues to plain text (.txt)
  static String toPlainText(List<SubtitleCue> cues) {
    final StringBuffer buffer = StringBuffer();
    for (final SubtitleCue cue in cues) {
      buffer.writeln('[${cue.displayStartTime}] ${cue.text}');
    }
    return buffer.toString();
  }

  static String _formatVttTimestamp(int ms) {
    final int hours = ms ~/ 3600000;
    final int minutes = (ms % 3600000) ~/ 60000;
    final int seconds = (ms % 60000) ~/ 1000;
    final int millis = ms % 1000;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}.'
        '${millis.toString().padLeft(3, '0')}';
  }

  static String _formatSrtTimestamp(int ms) {
    final int hours = ms ~/ 3600000;
    final int minutes = (ms % 3600000) ~/ 60000;
    final int seconds = (ms % 60000) ~/ 1000;
    final int millis = ms % 1000;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')},'
        '${millis.toString().padLeft(3, '0')}';
  }
}
