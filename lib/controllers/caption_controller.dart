import 'package:flutter/foundation.dart';
import '../models/subtitle_cue.dart';
import '../services/asr_service.dart';
import '../services/sidecar_detector.dart';
import '../services/subtitle_sync_engine.dart';
import 'ab_repeat_controller.dart';

enum SubtitleSourceType {
  off,
  embedded,
  sidecar,
  autoASR,
}

class CaptionController extends ChangeNotifier {
  final SubtitleSyncEngine _syncEngine = SubtitleSyncEngine();
  final ASRService _asrService = ASRService.instance;

  SubtitleSourceType _sourceType = SubtitleSourceType.off;
  List<SidecarSubtitle> _sidecars = [];
  SidecarSubtitle? _selectedSidecar;
  SubtitleCue? _currentCue;
  int _subtitleDelayMs = 0;
  double _fontSize = 18.0;
  double _bottomMarginPercent = 8.0;
  bool _overrideAssStyling = false;

  // Transcript sidebar state
  bool _isAutoScrollLocked = true;
  String _searchQuery = '';
  final List<int> _searchMatchIndices = [];
  int _currentSearchMatchIndex = -1;

  CaptionController() {
    _asrService.addListener(_onASRServiceChanged);
  }

  void _onASRServiceChanged() {
    final asrState = _asrService.state;
    if (_sourceType == SubtitleSourceType.autoASR || (asrState.cues.isNotEmpty && _sourceType != SubtitleSourceType.off)) {
      if (asrState.cues.isNotEmpty && _syncEngine.cues != asrState.cues) {
        setCues(asrState.cues);
      }
    }
  }

  SubtitleSourceType get sourceType => _sourceType;
  List<SidecarSubtitle> get sidecars => _sidecars;
  SidecarSubtitle? get selectedSidecar => _selectedSidecar;
  SubtitleCue? get currentCue => _currentCue;
  List<SubtitleCue> get cues => _syncEngine.cues;
  int get subtitleDelayMs => _subtitleDelayMs;
  double get fontSize => _fontSize;
  double get bottomMarginPercent => _bottomMarginPercent;
  bool get overrideAssStyling => _overrideAssStyling;
  bool get isAutoScrollLocked => _isAutoScrollLocked;
  String get searchQuery => _searchQuery;
  List<int> get searchMatchIndices => _searchMatchIndices;
  int get currentSearchMatchIndex => _currentSearchMatchIndex;

  void configure({
    double? fontSize,
    double? bottomMarginPercent,
    int? delayMs,
    bool? overrideAssStyling,
  }) {
    if (fontSize != null) _fontSize = fontSize;
    if (bottomMarginPercent != null) _bottomMarginPercent = bottomMarginPercent;
    if (delayMs != null) _subtitleDelayMs = delayMs;
    if (overrideAssStyling != null) _overrideAssStyling = overrideAssStyling;
    notifyListeners();
  }

  void setSidecars(List<SidecarSubtitle> sidecars) {
    _sidecars = sidecars;
    notifyListeners();
  }

  void setSourceType(SubtitleSourceType type, {SidecarSubtitle? sidecar}) {
    _sourceType = type;
    _selectedSidecar = sidecar;
    if (type == SubtitleSourceType.off) {
      _syncEngine.setCues([]);
      _currentCue = null;
    } else if (type == SubtitleSourceType.autoASR) {
      if (_asrService.state.cues.isNotEmpty) {
        setCues(_asrService.state.cues);
      }
    }
    notifyListeners();
  }

  void setCues(List<SubtitleCue> cues) {
    _syncEngine.setCues(cues);
    _performSearch();
    notifyListeners();
  }

  /// Called on player position updates
  void updatePosition(int positionMs) {
    if (_sourceType == SubtitleSourceType.off) {
      if (_currentCue != null) {
        _currentCue = null;
        notifyListeners();
      }
      return;
    }

    final SubtitleCue? active = _syncEngine.findActiveCue(positionMs, subtitleDelayMs: _subtitleDelayMs);
    if (active?.id != _currentCue?.id) {
      _currentCue = active;
      notifyListeners();
    }
  }

  void setDelayMs(int delayMs) {
    _subtitleDelayMs = delayMs;
    notifyListeners();
  }

  void setBottomMarginPercent(double percent) {
    _bottomMarginPercent = percent.clamp(4.0, 35.0);
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }

  // --- Transcript Interaction ---

  void setAutoScrollLocked(bool locked) {
    _isAutoScrollLocked = locked;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    _performSearch();
    notifyListeners();
  }

  void _performSearch() {
    _searchMatchIndices.clear();
    _currentSearchMatchIndex = -1;

    if (_searchQuery.isEmpty) return;

    final allCues = _syncEngine.cues;
    for (int i = 0; i < allCues.length; i++) {
      if (allCues[i].text.toLowerCase().contains(_searchQuery)) {
        _searchMatchIndices.add(i);
      }
    }

    if (_searchMatchIndices.isNotEmpty) {
      _currentSearchMatchIndex = 0;
    }
  }

  void nextSearchMatch() {
    if (_searchMatchIndices.isEmpty) return;
    _currentSearchMatchIndex = (_currentSearchMatchIndex + 1) % _searchMatchIndices.length;
    notifyListeners();
  }

  void previousSearchMatch() {
    if (_searchMatchIndices.isEmpty) return;
    _currentSearchMatchIndex = (_currentSearchMatchIndex - 1 + _searchMatchIndices.length) % _searchMatchIndices.length;
    notifyListeners();
  }

  Future<void> editCueText(int cueId, String newText) async {
    await _asrService.updateCueText(cueId, newText);
    setCues(_asrService.state.cues);
  }

  void loopSentence(SubtitleCue cue, ABRepeatController abController) {
    abController.setSentenceLoop(cue.startMs, cue.endMs);
  }

  @override
  void dispose() {
    _asrService.removeListener(_onASRServiceChanged);
    super.dispose();
  }
}
