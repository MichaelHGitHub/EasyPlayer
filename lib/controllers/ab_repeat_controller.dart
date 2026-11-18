import 'package:flutter/foundation.dart';

class ABRepeatController extends ChangeNotifier {
  int? _markerA; // milliseconds
  int? _markerB; // milliseconds
  bool _isActive = false;

  int? get markerA => _markerA;
  int? get markerB => _markerB;
  bool get isActive => _isActive;
  bool get hasMarkerA => _markerA != null;
  bool get hasMarkerB => _markerB != null;

  void setMarkerA(int positionMs) {
    _markerA = positionMs;
    if (_markerB != null && _markerB! <= _markerA!) {
      _markerB = null;
      _isActive = false;
    }
    notifyListeners();
  }

  void setMarkerB(int positionMs) {
    if (_markerA != null && positionMs > _markerA!) {
      _markerB = positionMs;
      _isActive = true;
      notifyListeners();
    }
  }

  /// Automatically activates loop spanning a sentence cue
  void setSentenceLoop(int startMs, int endMs) {
    _markerA = startMs;
    _markerB = endMs;
    _isActive = true;
    notifyListeners();
  }

  /// Toggle activation with current position handling (Spec §2.2)
  bool toggleActive(int currentPositionMs) {
    if (_isActive) {
      _isActive = false;
      notifyListeners();
      return false;
    }

    if (_markerA != null && _markerB != null) {
      _isActive = true;
      notifyListeners();
      return true;
    }

    // Incomplete marker: if only A is set, set B to current position if pos > A
    if (_markerA != null && _markerB == null) {
      if (currentPositionMs > _markerA!) {
        _markerB = currentPositionMs;
        _isActive = true;
        notifyListeners();
        return true;
      }
    }

    return false;
  }

  /// Checks if current position reached B and should loop back to A
  /// Returns target seek position (markerA) if loop triggered, or null
  int? checkLoop(int currentPositionMs) {
    if (_isActive && _markerA != null && _markerB != null) {
      if (currentPositionMs >= _markerB!) {
        return _markerA;
      }
    }
    return null;
  }

  void clear() {
    _markerA = null;
    _markerB = null;
    _isActive = false;
    notifyListeners();
  }
}
