import '../models/subtitle_cue.dart';

class SubtitleSyncEngine {
  List<SubtitleCue> _cues = [];

  void setCues(List<SubtitleCue> cues) {
    // Ensure cues are sorted by startMs
    _cues = List<SubtitleCue>.from(cues)
      ..sort((a, b) => a.startMs.compareTo(b.startMs));
  }

  List<SubtitleCue> get cues => _cues;

  /// Binary search finding the cue active at [positionMs], with delay offset applied
  /// Returns null if no cue is active at that moment
  SubtitleCue? findActiveCue(int positionMs, {int subtitleDelayMs = 0}) {
    if (_cues.isEmpty) return null;

    final int target = positionMs - subtitleDelayMs;
    if (target < _cues.first.startMs || target > _cues.last.endMs) {
      // Check if inside last cue bounds
      if (_cues.last.startMs <= target && target <= _cues.last.endMs) {
        return _cues.last;
      }
      return null;
    }

    int low = 0;
    int high = _cues.length - 1;

    while (low <= high) {
      final int mid = (low + high) ~/ 2;
      final SubtitleCue cue = _cues[mid];

      if (cue.startMs <= target && target <= cue.endMs) {
        return cue;
      } else if (target < cue.startMs) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }

    return null;
  }

  /// Binary search to find the index of the closest cue at or after [positionMs]
  int findClosestCueIndex(int positionMs, {int subtitleDelayMs = 0}) {
    if (_cues.isEmpty) return -1;
    final int target = positionMs - subtitleDelayMs;

    int low = 0;
    int high = _cues.length - 1;
    int bestIndex = 0;

    while (low <= high) {
      final int mid = (low + high) ~/ 2;
      final SubtitleCue cue = _cues[mid];

      if (cue.startMs <= target && target <= cue.endMs) {
        return mid;
      } else if (target < cue.startMs) {
        bestIndex = mid;
        high = mid - 1;
      } else {
        bestIndex = mid;
        low = mid + 1;
      }
    }

    return bestIndex.clamp(0, _cues.length - 1);
  }
}
