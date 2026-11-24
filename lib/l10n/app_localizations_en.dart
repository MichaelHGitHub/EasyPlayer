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
}
