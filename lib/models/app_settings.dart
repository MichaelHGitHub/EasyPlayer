import 'playback_mode.dart';

class AppSettings {
  String uiLanguage; // 'system', 'en', 'zh_CN'
  int skipBackwardSeconds; // 5
  int skipForwardSeconds; // 10
  double playbackSpeed; // 1.0
  double subtitleFontSize; // 18.0
  double subtitleBottomMarginPercent; // 8.0 (range 4.0 - 35.0)
  int subtitleDelayMs; // 0
  SubtitleEncoding subtitleEncoding; // auto
  bool overrideAssStyling; // false
  bool snapshotIncludeSubtitles; // false
  AspectRatioMode aspectRatioMode; // fit
  OrientationLock orientationLock; // auto
  bool hardwareAcceleration; // true
  bool audioNormalization; // false
  bool voiceClarityBoost; // false
  bool showAudioEventTags; // true
  PlayMode playMode; // sequential
  RepeatMode repeatMode; // none
  String queueSortOrder; // 'natural_name', 'date_modified', 'file_size'
  bool includeSubfolders; // false
  String asrLanguageMode; // 'auto', 'en', 'zh'
  List<String> recentDirectories; // max 10
  Map<String, int> playbackPositions; // hash -> position_ms, max 500
  SleepTimerMode sleepTimerMode; // off
  int sleepTimerCustomMinutes; // 20
  bool miniPlayerAlwaysOnTop; // false
  bool recordPlaybackHistory; // true

  AppSettings({
    this.uiLanguage = 'system',
    this.skipBackwardSeconds = 5,
    this.skipForwardSeconds = 10,
    this.playbackSpeed = 1.0,
    this.subtitleFontSize = 18.0,
    this.subtitleBottomMarginPercent = 8.0,
    this.subtitleDelayMs = 0,
    this.subtitleEncoding = SubtitleEncoding.auto,
    this.overrideAssStyling = false,
    this.snapshotIncludeSubtitles = false,
    this.aspectRatioMode = AspectRatioMode.fit,
    this.orientationLock = OrientationLock.auto,
    this.hardwareAcceleration = true,
    this.audioNormalization = false,
    this.voiceClarityBoost = false,
    this.showAudioEventTags = true,
    this.playMode = PlayMode.sequential,
    this.repeatMode = RepeatMode.none,
    this.queueSortOrder = 'natural_name',
    this.includeSubfolders = false,
    this.asrLanguageMode = 'auto',
    List<String>? recentDirectories,
    Map<String, int>? playbackPositions,
    this.sleepTimerMode = SleepTimerMode.off,
    this.sleepTimerCustomMinutes = 20,
    this.miniPlayerAlwaysOnTop = false,
    this.recordPlaybackHistory = true,
  })  : recentDirectories = recentDirectories ?? [],
        playbackPositions = playbackPositions ?? {};
}
