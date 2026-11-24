// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EasyPlayer';

  @override
  String get developerName => 'PandaSoft';

  @override
  String get openFile => 'Open File';

  @override
  String get openFolder => 'Open Folder';

  @override
  String get recentlyPlayed => 'Recently Played';

  @override
  String get clearHistory => 'Clear Playback History';

  @override
  String get emptyRecentHistory => 'No recently played files';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get stop => 'Stop';

  @override
  String get nextTrack => 'Next Track';

  @override
  String get previousTrack => 'Previous Track';

  @override
  String get seekForward => 'Seek Forward';

  @override
  String get seekBackward => 'Seek Backward';

  @override
  String get playbackSpeed => 'Speed';

  @override
  String get volume => 'Volume';

  @override
  String get mute => 'Mute';

  @override
  String get unmute => 'Unmute';

  @override
  String get fullscreen => 'Fullscreen';

  @override
  String get exitFullscreen => 'Exit Fullscreen';

  @override
  String get aspectRatio => 'Aspect Ratio';

  @override
  String get aspectFit => 'Fit (Letterbox)';

  @override
  String get aspectFill => 'Fill (Crop)';

  @override
  String get aspectStretch => 'Stretch';

  @override
  String get aspect16_9 => 'Fixed 16:9';

  @override
  String get aspect4_3 => 'Fixed 4:3';

  @override
  String get audioTracks => 'Audio Track';

  @override
  String get subtitleTracks => 'Subtitles';

  @override
  String get subtitleOff => 'Off';

  @override
  String get subtitleAutoASR => 'Auto-Generated Captions';

  @override
  String get subtitleDelay => 'Subtitle Delay';

  @override
  String get subtitleSize => 'Subtitle Size';

  @override
  String get subtitleMargin => 'Vertical Position';

  @override
  String get captions => 'Captions';

  @override
  String get transcribing => 'Transcribing speech...';

  @override
  String get modelLoading => 'Loading speech model...';

  @override
  String get modelDownloading => 'Downloading speech model (about 226 MiB)';

  @override
  String get scriptGenerationNotice =>
      'Generating transcript script. Please wait until generation completes.';

  @override
  String get transcriptReady => 'Transcript ready';

  @override
  String get transcriptSidebar => 'Transcript Panel';

  @override
  String get searchTranscript => 'Search transcript...';

  @override
  String get loopSentence => 'Loop Sentence';

  @override
  String get resumeAutoScroll => 'Resume Auto-scroll';

  @override
  String get exportTranscript => 'Export Transcript';

  @override
  String get abRepeat => 'A-B Repeat';

  @override
  String get markerA => 'Point A';

  @override
  String get markerB => 'Point B';

  @override
  String get clearLoop => 'Clear Loop';

  @override
  String get sleepTimer => 'Sleep Timer';

  @override
  String get sleepOff => 'Off';

  @override
  String get sleep15m => '15 Minutes';

  @override
  String get sleep30m => '30 Minutes';

  @override
  String get sleep45m => '45 Minutes';

  @override
  String get sleep60m => '60 Minutes';

  @override
  String get sleepEndOfTrack => 'End of Track';

  @override
  String get sleepCustom => 'Custom Duration';

  @override
  String get snapshot => 'Snapshot';

  @override
  String get snapshotSaved => 'Frame saved to Pictures/EasyPlayer';

  @override
  String get snapshotUnavailableAudio => 'Snapshot unavailable for audio files';

  @override
  String get settings => 'Settings';

  @override
  String get generalSettings => 'General';

  @override
  String get language => 'UI Language';

  @override
  String get followSystem => 'Follow System';

  @override
  String get english => 'English';

  @override
  String get chinese => '简体中文';

  @override
  String get hardwareAcceleration => 'Hardware Acceleration (GPU)';

  @override
  String get loudnessNormalization => 'Dynamic Loudness Normalization';

  @override
  String get vocalClarityBoost => 'Vocal Clarity Boost';

  @override
  String get overrideAssStyling => 'Override Complex Subtitle Styles';

  @override
  String get storageAndCache => 'Storage & Cache';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get about => 'About EasyPlayer';

  @override
  String get selectFolder => 'Select Folder';

  @override
  String failedToOpenFile(Object error) {
    return 'Failed to open file: $error';
  }

  @override
  String failedToOpenFolder(Object error) {
    return 'Failed to open folder: $error';
  }

  @override
  String get unsupportedMediaFiles =>
      'No supported media files found in the selected folder.';

  @override
  String get extractingAudio => 'Extracting audio...';

  @override
  String get speechRecognitionFailed => 'Speech recognition failed.';

  @override
  String get transcriptMissing =>
      'No transcript file found. Please use the \"Start AI Transcription\" button to generate a script.';

  @override
  String get startAiTranscription => 'Start AI Transcription';

  @override
  String get noTranscriptAvailable => 'No subtitles or transcript available';

  @override
  String get edited => 'Edited';

  @override
  String editCue(Object time) {
    return 'Edit Cue ($time)';
  }

  @override
  String get editText => 'Edit Text';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get exportAsVtt => 'Export as WebVTT (.vtt)';

  @override
  String get exportAsSrt => 'Export as SubRip (.srt)';

  @override
  String get exportAsText => 'Export as Plain Text (.txt)';

  @override
  String exportedTo(Object path) {
    return 'Exported to: $path';
  }

  @override
  String exportFailed(Object error) {
    return 'Failed to export: $error';
  }

  @override
  String searchMatches(Object current, Object total) {
    return '$current of $total matches';
  }

  @override
  String get settingsGeneralLocalization => 'General & Localization';

  @override
  String get playbackNavigation => 'Playback & Navigation';

  @override
  String get audioEnhancements => 'Audio Enhancements';

  @override
  String get subtitlesAndAsr => 'Subtitles & Speech Recognition (ASR)';

  @override
  String get recordPlaybackHistory => 'Record Playback History';

  @override
  String get recordPlaybackHistoryDescription =>
      'Save recently opened media to the Recently Played shelf';

  @override
  String get hardwareAccelerationDescription =>
      'Direct3D / MediaCodec hardware decoding with safe CPU fallback';

  @override
  String get fastBackwardDuration => 'Fast Backward Duration';

  @override
  String get fastForwardDuration => 'Fast Forward Duration';

  @override
  String get seconds => 'seconds';

  @override
  String get loudnessNormalizationDescription =>
      'Automatically levels out audio volume across tracks (loudnorm)';

  @override
  String get vocalClarityBoostDescription =>
      'High-pass filter and vocal EQ boost to clarify dialogue';

  @override
  String get overrideAssStylingDescription =>
      'Forces standard EasyPlayer typography over ASS/SSA fansub styles';

  @override
  String get showAudioEventTags => 'Show Audio Event Tags';

  @override
  String get showAudioEventTagsDescription =>
      'Display tags such as [Laughter] and [Applause] in captions';

  @override
  String get includeSubtitlesInSnapshots => 'Include Subtitles in Snapshots';

  @override
  String get includeSubtitlesInSnapshotsDescription =>
      'Composite active subtitle text when capturing video frames';

  @override
  String get calculatingStorage => 'Calculating storage...';

  @override
  String get cachedTranscriptsAndThumbnails =>
      'Cached Transcripts & Thumbnails';

  @override
  String cacheSizeUsed(Object size) {
    return '$size MB used';
  }

  @override
  String get cacheCleared => 'Cache cleared successfully.';

  @override
  String get aboutVersion => 'Version 1.0.0';

  @override
  String get aboutDescription =>
      'Cross-platform audio and video player with on-device offline Automatic Speech Recognition (ASR). Zero server dependencies.';

  @override
  String get copyright => 'Copyright © 2026 PandaSoft. All rights reserved.';

  @override
  String get ok => 'OK';

  @override
  String get playlistQueue => 'Playlist Queue';

  @override
  String get sequential => 'Sequential';

  @override
  String get single => 'Single';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get noRepeat => 'No Repeat';

  @override
  String get repeatTrack => 'Repeat Track';

  @override
  String get repeatFolder => 'Repeat Folder';

  @override
  String get queueEmpty => 'Queue is empty';

  @override
  String get sleepTimerActiveTrack =>
      'Timer active: Will stop after current track';

  @override
  String sleepTimerActiveRemaining(Object minutes, Object seconds) {
    return 'Timer active: ${minutes}m ${seconds}s remaining';
  }

  @override
  String get turnOffSleepTimer => 'Turn Off Sleep Timer';

  @override
  String get close => 'Close';

  @override
  String get trackVideoSettings => 'Track & Video Settings';

  @override
  String get audioSubtitleTracks => 'Audio & Subtitle Tracks';

  @override
  String get aspectRatioMode => 'Aspect Ratio Mode';

  @override
  String get subtitleSource => 'Subtitle Source';

  @override
  String get sidecarFiles => 'Sidecar Files:';

  @override
  String get subtitleTimingOffset => 'Subtitle Timing Offset';

  @override
  String get milliseconds => 'ms';

  @override
  String get subtitleVerticalPosition => 'Subtitle Vertical Position';

  @override
  String get subtitleFontSizePoints => 'Subtitle Font Size';

  @override
  String get points => 'pt';

  @override
  String get done => 'Done';

  @override
  String seekBackwardTooltip(Object seconds) {
    return 'Seek backward ${seconds}s';
  }

  @override
  String seekForwardTooltip(Object seconds) {
    return 'Seek forward ${seconds}s';
  }

  @override
  String get playShortcut => 'Play (Space)';

  @override
  String get pauseShortcut => 'Pause (Space)';

  @override
  String get abLoopActive => 'A-B Loop Active (R to toggle)';

  @override
  String get setAbRepeat => 'Set A-B Repeat (R)';

  @override
  String pointASetAt(Object time) {
    return 'Point A set at $time';
  }

  @override
  String pointBSetAt(Object time) {
    return 'Point B set at $time. Looping.';
  }

  @override
  String get abLoopCleared => 'A-B Loop Cleared';

  @override
  String get closedCaptionsShortcut => 'Closed Captions (C)';

  @override
  String get interactiveTranscriptPanel => 'Interactive Transcript Panel';

  @override
  String get snapshotFrameShortcut => 'Snapshot Frame (S)';

  @override
  String snapshotSavedPath(Object path) {
    return 'Snapshot saved: $path';
  }
}
