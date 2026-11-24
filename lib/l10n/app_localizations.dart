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
  /// **'Frame saved to Pictures/EasyPlayer'**
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
