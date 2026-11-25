import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'EasyPlayer'**
  String get appTitle;

  /// No description provided for @developerName.
  ///
  /// In en, this message translates to:
  /// **'PandaSoft'**
  String get developerName;

  /// No description provided for @openFile.
  ///
  /// In en, this message translates to:
  /// **'Open File'**
  String get openFile;

  /// No description provided for @openFolder.
  ///
  /// In en, this message translates to:
  /// **'Open Folder'**
  String get openFolder;

  /// No description provided for @recentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recently Played'**
  String get recentlyPlayed;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear Playback History'**
  String get clearHistory;

  /// No description provided for @emptyRecentHistory.
  ///
  /// In en, this message translates to:
  /// **'No recently played files'**
  String get emptyRecentHistory;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @nextTrack.
  ///
  /// In en, this message translates to:
  /// **'Next Track'**
  String get nextTrack;

  /// No description provided for @previousTrack.
  ///
  /// In en, this message translates to:
  /// **'Previous Track'**
  String get previousTrack;

  /// No description provided for @seekForward.
  ///
  /// In en, this message translates to:
  /// **'Seek Forward'**
  String get seekForward;

  /// No description provided for @seekBackward.
  ///
  /// In en, this message translates to:
  /// **'Seek Backward'**
  String get seekBackward;

  /// No description provided for @playbackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get playbackSpeed;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// No description provided for @fullscreen.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get fullscreen;

  /// No description provided for @exitFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Exit Fullscreen'**
  String get exitFullscreen;

  /// No description provided for @aspectRatio.
  ///
  /// In en, this message translates to:
  /// **'Aspect Ratio'**
  String get aspectRatio;

  /// No description provided for @aspectFit.
  ///
  /// In en, this message translates to:
  /// **'Fit (Letterbox)'**
  String get aspectFit;

  /// No description provided for @aspectFill.
  ///
  /// In en, this message translates to:
  /// **'Fill (Crop)'**
  String get aspectFill;

  /// No description provided for @aspectStretch.
  ///
  /// In en, this message translates to:
  /// **'Stretch'**
  String get aspectStretch;

  /// No description provided for @aspect16_9.
  ///
  /// In en, this message translates to:
  /// **'Fixed 16:9'**
  String get aspect16_9;

  /// No description provided for @aspect4_3.
  ///
  /// In en, this message translates to:
  /// **'Fixed 4:3'**
  String get aspect4_3;

  /// No description provided for @audioTracks.
  ///
  /// In en, this message translates to:
  /// **'Audio Track'**
  String get audioTracks;

  /// No description provided for @subtitleTracks.
  ///
  /// In en, this message translates to:
  /// **'Subtitles'**
  String get subtitleTracks;

  /// No description provided for @subtitleOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get subtitleOff;

  /// No description provided for @subtitleAutoASR.
  ///
  /// In en, this message translates to:
  /// **'Auto-Generated Captions'**
  String get subtitleAutoASR;

  /// No description provided for @subtitleDelay.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Delay'**
  String get subtitleDelay;

  /// No description provided for @subtitleSize.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Size'**
  String get subtitleSize;

  /// No description provided for @subtitleMargin.
  ///
  /// In en, this message translates to:
  /// **'Vertical Position'**
  String get subtitleMargin;

  /// No description provided for @captions.
  ///
  /// In en, this message translates to:
  /// **'Captions'**
  String get captions;

  /// No description provided for @transcribing.
  ///
  /// In en, this message translates to:
  /// **'Transcribing speech...'**
  String get transcribing;

  /// No description provided for @modelLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading speech model...'**
  String get modelLoading;

  /// No description provided for @modelDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading speech model (about 226 MiB)'**
  String get modelDownloading;

  /// No description provided for @scriptGenerationNotice.
  ///
  /// In en, this message translates to:
  /// **'Generating transcript script. Please wait until generation completes.'**
  String get scriptGenerationNotice;

  /// No description provided for @transcriptReady.
  ///
  /// In en, this message translates to:
  /// **'Transcript ready'**
  String get transcriptReady;

  /// No description provided for @transcriptSidebar.
  ///
  /// In en, this message translates to:
  /// **'Transcript Panel'**
  String get transcriptSidebar;

  /// No description provided for @searchTranscript.
  ///
  /// In en, this message translates to:
  /// **'Search transcript...'**
  String get searchTranscript;

  /// No description provided for @loopSentence.
  ///
  /// In en, this message translates to:
  /// **'Loop Sentence'**
  String get loopSentence;

  /// No description provided for @resumeAutoScroll.
  ///
  /// In en, this message translates to:
  /// **'Resume Auto-scroll'**
  String get resumeAutoScroll;

  /// No description provided for @exportTranscript.
  ///
  /// In en, this message translates to:
  /// **'Export Transcript'**
  String get exportTranscript;

  /// No description provided for @abRepeat.
  ///
  /// In en, this message translates to:
  /// **'A-B Repeat'**
  String get abRepeat;

  /// No description provided for @markerA.
  ///
  /// In en, this message translates to:
  /// **'Point A'**
  String get markerA;

  /// No description provided for @markerB.
  ///
  /// In en, this message translates to:
  /// **'Point B'**
  String get markerB;

  /// No description provided for @clearLoop.
  ///
  /// In en, this message translates to:
  /// **'Clear Loop'**
  String get clearLoop;

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep Timer'**
  String get sleepTimer;

  /// No description provided for @sleepOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get sleepOff;

  /// No description provided for @sleep15m.
  ///
  /// In en, this message translates to:
  /// **'15 Minutes'**
  String get sleep15m;

  /// No description provided for @sleep30m.
  ///
  /// In en, this message translates to:
  /// **'30 Minutes'**
  String get sleep30m;

  /// No description provided for @sleep45m.
  ///
  /// In en, this message translates to:
  /// **'45 Minutes'**
  String get sleep45m;

  /// No description provided for @sleep60m.
  ///
  /// In en, this message translates to:
  /// **'60 Minutes'**
  String get sleep60m;

  /// No description provided for @sleepEndOfTrack.
  ///
  /// In en, this message translates to:
  /// **'End of Track'**
  String get sleepEndOfTrack;

  /// No description provided for @sleepCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom Duration'**
  String get sleepCustom;

  /// No description provided for @snapshot.
  ///
  /// In en, this message translates to:
  /// **'Snapshot'**
  String get snapshot;

  /// No description provided for @snapshotSaved.
  ///
  /// In en, this message translates to:
  /// **'Frame saved to Pictures/Screenshots'**
  String get snapshotSaved;

  /// No description provided for @snapshotUnavailableAudio.
  ///
  /// In en, this message translates to:
  /// **'Snapshot unavailable for audio files'**
  String get snapshotUnavailableAudio;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'UI Language'**
  String get language;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get followSystem;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get chinese;

  /// No description provided for @hardwareAcceleration.
  ///
  /// In en, this message translates to:
  /// **'Hardware Acceleration (GPU)'**
  String get hardwareAcceleration;

  /// No description provided for @loudnessNormalization.
  ///
  /// In en, this message translates to:
  /// **'Dynamic Loudness Normalization'**
  String get loudnessNormalization;

  /// No description provided for @vocalClarityBoost.
  ///
  /// In en, this message translates to:
  /// **'Vocal Clarity Boost'**
  String get vocalClarityBoost;

  /// No description provided for @overrideAssStyling.
  ///
  /// In en, this message translates to:
  /// **'Override Complex Subtitle Styles'**
  String get overrideAssStyling;

  /// No description provided for @storageAndCache.
  ///
  /// In en, this message translates to:
  /// **'Storage & Cache'**
  String get storageAndCache;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About EasyPlayer'**
  String get about;

  /// No description provided for @selectFolder.
  ///
  /// In en, this message translates to:
  /// **'Select Folder'**
  String get selectFolder;

  /// No description provided for @failedToOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to open file: {error}'**
  String failedToOpenFile(Object error);

  /// No description provided for @failedToOpenFolder.
  ///
  /// In en, this message translates to:
  /// **'Failed to open folder: {error}'**
  String failedToOpenFolder(Object error);

  /// No description provided for @unsupportedMediaFiles.
  ///
  /// In en, this message translates to:
  /// **'No supported media files found in the selected folder.'**
  String get unsupportedMediaFiles;

  /// No description provided for @extractingAudio.
  ///
  /// In en, this message translates to:
  /// **'Extracting audio...'**
  String get extractingAudio;

  /// No description provided for @speechRecognitionFailed.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition failed.'**
  String get speechRecognitionFailed;

  /// No description provided for @transcriptMissing.
  ///
  /// In en, this message translates to:
  /// **'No transcript file found, use the next button to specify one or generate the script with AI.'**
  String get transcriptMissing;

  /// No description provided for @loadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Load Subtitle'**
  String get loadSubtitle;

  /// No description provided for @subtitleFiles.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Files'**
  String get subtitleFiles;

  /// No description provided for @failedToLoadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Failed to load subtitle: {error}'**
  String failedToLoadSubtitle(Object error);

  /// No description provided for @invalidSubtitleFile.
  ///
  /// In en, this message translates to:
  /// **'No timed subtitles were found in the selected file.'**
  String get invalidSubtitleFile;

  /// No description provided for @startAiTranscription.
  ///
  /// In en, this message translates to:
  /// **'Start AI Transcription'**
  String get startAiTranscription;

  /// No description provided for @noTranscriptAvailable.
  ///
  /// In en, this message translates to:
  /// **'No subtitles or transcript available'**
  String get noTranscriptAvailable;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get edited;

  /// No description provided for @editCue.
  ///
  /// In en, this message translates to:
  /// **'Edit Cue ({time})'**
  String editCue(Object time);

  /// No description provided for @editText.
  ///
  /// In en, this message translates to:
  /// **'Edit Text'**
  String get editText;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @exportAsVtt.
  ///
  /// In en, this message translates to:
  /// **'Export as WebVTT (.vtt)'**
  String get exportAsVtt;

  /// No description provided for @exportAsSrt.
  ///
  /// In en, this message translates to:
  /// **'Export as SubRip (.srt)'**
  String get exportAsSrt;

  /// No description provided for @exportAsText.
  ///
  /// In en, this message translates to:
  /// **'Export as Plain Text (.txt)'**
  String get exportAsText;

  /// No description provided for @exportedTo.
  ///
  /// In en, this message translates to:
  /// **'Exported to: {path}'**
  String exportedTo(Object path);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to export: {error}'**
  String exportFailed(Object error);

  /// No description provided for @searchMatches.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total} matches'**
  String searchMatches(Object current, Object total);

  /// No description provided for @settingsGeneralLocalization.
  ///
  /// In en, this message translates to:
  /// **'General & Localization'**
  String get settingsGeneralLocalization;

  /// No description provided for @playbackNavigation.
  ///
  /// In en, this message translates to:
  /// **'Playback & Navigation'**
  String get playbackNavigation;

  /// No description provided for @audioEnhancements.
  ///
  /// In en, this message translates to:
  /// **'Audio Enhancements'**
  String get audioEnhancements;

  /// No description provided for @subtitlesAndAsr.
  ///
  /// In en, this message translates to:
  /// **'Subtitles & Speech Recognition (ASR)'**
  String get subtitlesAndAsr;

  /// No description provided for @recordPlaybackHistory.
  ///
  /// In en, this message translates to:
  /// **'Record Playback History'**
  String get recordPlaybackHistory;

  /// No description provided for @recordPlaybackHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Save recently opened media to the Recently Played shelf'**
  String get recordPlaybackHistoryDescription;

  /// No description provided for @hardwareAccelerationDescription.
  ///
  /// In en, this message translates to:
  /// **'Direct3D / MediaCodec hardware decoding with safe CPU fallback'**
  String get hardwareAccelerationDescription;

  /// No description provided for @fastBackwardDuration.
  ///
  /// In en, this message translates to:
  /// **'Fast Backward Duration'**
  String get fastBackwardDuration;

  /// No description provided for @fastForwardDuration.
  ///
  /// In en, this message translates to:
  /// **'Fast Forward Duration'**
  String get fastForwardDuration;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @loudnessNormalizationDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically levels out audio volume across tracks (loudnorm)'**
  String get loudnessNormalizationDescription;

  /// No description provided for @vocalClarityBoostDescription.
  ///
  /// In en, this message translates to:
  /// **'High-pass filter and vocal EQ boost to clarify dialogue'**
  String get vocalClarityBoostDescription;

  /// No description provided for @overrideAssStylingDescription.
  ///
  /// In en, this message translates to:
  /// **'Forces standard EasyPlayer typography over ASS/SSA fansub styles'**
  String get overrideAssStylingDescription;

  /// No description provided for @showAudioEventTags.
  ///
  /// In en, this message translates to:
  /// **'Show Audio Event Tags'**
  String get showAudioEventTags;

  /// No description provided for @showAudioEventTagsDescription.
  ///
  /// In en, this message translates to:
  /// **'Display tags such as [Laughter] and [Applause] in captions'**
  String get showAudioEventTagsDescription;

  /// No description provided for @includeSubtitlesInSnapshots.
  ///
  /// In en, this message translates to:
  /// **'Include Subtitles in Snapshots'**
  String get includeSubtitlesInSnapshots;

  /// No description provided for @includeSubtitlesInSnapshotsDescription.
  ///
  /// In en, this message translates to:
  /// **'Composite active subtitle text when capturing video frames'**
  String get includeSubtitlesInSnapshotsDescription;

  /// No description provided for @calculatingStorage.
  ///
  /// In en, this message translates to:
  /// **'Calculating storage...'**
  String get calculatingStorage;

  /// No description provided for @cachedTranscriptsAndThumbnails.
  ///
  /// In en, this message translates to:
  /// **'Cached Transcripts & Thumbnails'**
  String get cachedTranscriptsAndThumbnails;

  /// No description provided for @cacheSizeUsed.
  ///
  /// In en, this message translates to:
  /// **'{size} MB used'**
  String cacheSizeUsed(Object size);

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully.'**
  String get cacheCleared;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get aboutVersion;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Cross-platform audio and video player with on-device offline Automatic Speech Recognition (ASR). Zero server dependencies.'**
  String get aboutDescription;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright © 2026 PandaSoft. All rights reserved.'**
  String get copyright;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @playlistQueue.
  ///
  /// In en, this message translates to:
  /// **'Playlist Queue'**
  String get playlistQueue;

  /// No description provided for @showQueuePanel.
  ///
  /// In en, this message translates to:
  /// **'Show Queue Panel'**
  String get showQueuePanel;

  /// No description provided for @hideQueuePanel.
  ///
  /// In en, this message translates to:
  /// **'Hide Queue Panel'**
  String get hideQueuePanel;

  /// No description provided for @sequential.
  ///
  /// In en, this message translates to:
  /// **'Sequential'**
  String get sequential;

  /// No description provided for @single.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get single;

  /// No description provided for @shuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// No description provided for @noRepeat.
  ///
  /// In en, this message translates to:
  /// **'No Repeat'**
  String get noRepeat;

  /// No description provided for @repeatTrack.
  ///
  /// In en, this message translates to:
  /// **'Repeat Track'**
  String get repeatTrack;

  /// No description provided for @repeatFolder.
  ///
  /// In en, this message translates to:
  /// **'Repeat Folder'**
  String get repeatFolder;

  /// No description provided for @queueEmpty.
  ///
  /// In en, this message translates to:
  /// **'Queue is empty'**
  String get queueEmpty;

  /// No description provided for @sleepTimerActiveTrack.
  ///
  /// In en, this message translates to:
  /// **'Timer active: Will stop after current track'**
  String get sleepTimerActiveTrack;

  /// No description provided for @sleepTimerActiveRemaining.
  ///
  /// In en, this message translates to:
  /// **'Timer active: {minutes}m {seconds}s remaining'**
  String sleepTimerActiveRemaining(Object minutes, Object seconds);

  /// No description provided for @turnOffSleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Turn Off Sleep Timer'**
  String get turnOffSleepTimer;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @trackVideoSettings.
  ///
  /// In en, this message translates to:
  /// **'Track & Video Settings'**
  String get trackVideoSettings;

  /// No description provided for @audioSubtitleTracks.
  ///
  /// In en, this message translates to:
  /// **'Audio & Subtitle Tracks'**
  String get audioSubtitleTracks;

  /// No description provided for @aspectRatioMode.
  ///
  /// In en, this message translates to:
  /// **'Aspect Ratio Mode'**
  String get aspectRatioMode;

  /// No description provided for @subtitleSource.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Source'**
  String get subtitleSource;

  /// No description provided for @sidecarFiles.
  ///
  /// In en, this message translates to:
  /// **'Sidecar Files:'**
  String get sidecarFiles;

  /// No description provided for @subtitleTimingOffset.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Timing Offset'**
  String get subtitleTimingOffset;

  /// No description provided for @milliseconds.
  ///
  /// In en, this message translates to:
  /// **'ms'**
  String get milliseconds;

  /// No description provided for @subtitleVerticalPosition.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Vertical Position'**
  String get subtitleVerticalPosition;

  /// No description provided for @subtitleFontSizePoints.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Font Size'**
  String get subtitleFontSizePoints;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'pt'**
  String get points;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @seekBackwardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Seek backward {seconds}s'**
  String seekBackwardTooltip(Object seconds);

  /// No description provided for @seekForwardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Seek forward {seconds}s'**
  String seekForwardTooltip(Object seconds);

  /// No description provided for @playShortcut.
  ///
  /// In en, this message translates to:
  /// **'Play (Space)'**
  String get playShortcut;

  /// No description provided for @pauseShortcut.
  ///
  /// In en, this message translates to:
  /// **'Pause (Space)'**
  String get pauseShortcut;

  /// No description provided for @abLoopActive.
  ///
  /// In en, this message translates to:
  /// **'A-B Loop Active (R to toggle)'**
  String get abLoopActive;

  /// No description provided for @setAbRepeat.
  ///
  /// In en, this message translates to:
  /// **'Set A-B Repeat (R)'**
  String get setAbRepeat;

  /// No description provided for @pointASetAt.
  ///
  /// In en, this message translates to:
  /// **'Point A set at {time}'**
  String pointASetAt(Object time);

  /// No description provided for @pointBSetAt.
  ///
  /// In en, this message translates to:
  /// **'Point B set at {time}. Looping.'**
  String pointBSetAt(Object time);

  /// No description provided for @abLoopCleared.
  ///
  /// In en, this message translates to:
  /// **'A-B Loop Cleared'**
  String get abLoopCleared;

  /// No description provided for @closedCaptionsShortcut.
  ///
  /// In en, this message translates to:
  /// **'Closed Captions (C)'**
  String get closedCaptionsShortcut;

  /// No description provided for @interactiveTranscriptPanel.
  ///
  /// In en, this message translates to:
  /// **'Interactive Transcript Panel'**
  String get interactiveTranscriptPanel;

  /// No description provided for @snapshotFrameShortcut.
  ///
  /// In en, this message translates to:
  /// **'Snapshot Frame (S)'**
  String get snapshotFrameShortcut;

  /// No description provided for @snapshotSavedPath.
  ///
  /// In en, this message translates to:
  /// **'Snapshot saved: {path}'**
  String snapshotSavedPath(Object path);

  /// No description provided for @snapshotSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save screenshot: {error}'**
  String snapshotSaveFailed(Object error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
