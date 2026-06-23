import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_tr.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('nl'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Nursing Pulse'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navBaby.
  ///
  /// In en, this message translates to:
  /// **'Baby'**
  String get navBaby;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @lastNursingLabel.
  ///
  /// In en, this message translates to:
  /// **'LAST NURSING'**
  String get lastNursingLabel;

  /// No description provided for @lastNursingNoSessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get lastNursingNoSessions;

  /// No description provided for @lastNursingAgo.
  ///
  /// In en, this message translates to:
  /// **'{time} ago • {side}'**
  String lastNursingAgo(String time, String side);

  /// No description provided for @lastNursingMinAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago • {side} • {duration} min'**
  String lastNursingMinAgo(int minutes, String side, int duration);

  /// No description provided for @lastNursingHourAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} {hours, plural, =1{hour} other{hours}} ago • {side} • {duration} min'**
  String lastNursingHourAgo(int hours, String side, int duration);

  /// No description provided for @sideLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get sideLeft;

  /// No description provided for @sideRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get sideRight;

  /// No description provided for @sideLeftFull.
  ///
  /// In en, this message translates to:
  /// **'Left side'**
  String get sideLeftFull;

  /// No description provided for @sideRightFull.
  ///
  /// In en, this message translates to:
  /// **'Right side'**
  String get sideRightFull;

  /// No description provided for @startNursing.
  ///
  /// In en, this message translates to:
  /// **'Start Nursing'**
  String get startNursing;

  /// No description provided for @finishSession.
  ///
  /// In en, this message translates to:
  /// **'Finish Session'**
  String get finishSession;

  /// No description provided for @nursing.
  ///
  /// In en, this message translates to:
  /// **'Nursing...'**
  String get nursing;

  /// No description provided for @nextSuggestedFeed.
  ///
  /// In en, this message translates to:
  /// **'Next suggested feed'**
  String get nextSuggestedFeed;

  /// No description provided for @nextFeedAround.
  ///
  /// In en, this message translates to:
  /// **'Around {time}'**
  String nextFeedAround(String time);

  /// No description provided for @dailyTotal.
  ///
  /// In en, this message translates to:
  /// **'Daily Total'**
  String get dailyTotal;

  /// No description provided for @diapers.
  ///
  /// In en, this message translates to:
  /// **'Diapers'**
  String get diapers;

  /// No description provided for @diapersToday.
  ///
  /// In en, this message translates to:
  /// **'{count} today'**
  String diapersToday(int count);

  /// No description provided for @diapersMoreInStats.
  ///
  /// In en, this message translates to:
  /// **'+{count} more today — full history in Stats'**
  String diapersMoreInStats(int count);

  /// No description provided for @statsTodaySummary.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get statsTodaySummary;

  /// No description provided for @statsTotalNursing.
  ///
  /// In en, this message translates to:
  /// **'total nursing today'**
  String get statsTotalNursing;

  /// No description provided for @statsNoSessionsYet.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get statsNoSessionsYet;

  /// No description provided for @statsLateralBalance.
  ///
  /// In en, this message translates to:
  /// **'LATERAL BALANCE'**
  String get statsLateralBalance;

  /// No description provided for @statsLeftSide.
  ///
  /// In en, this message translates to:
  /// **'Left Side'**
  String get statsLeftSide;

  /// No description provided for @statsRightSide.
  ///
  /// In en, this message translates to:
  /// **'Right Side'**
  String get statsRightSide;

  /// No description provided for @statsTodaySessions.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Sessions'**
  String get statsTodaySessions;

  /// No description provided for @statsNoSessionsToday.
  ///
  /// In en, this message translates to:
  /// **'No sessions recorded today'**
  String get statsNoSessionsToday;

  /// No description provided for @statsAvgDuration.
  ///
  /// In en, this message translates to:
  /// **'Avg. Duration'**
  String get statsAvgDuration;

  /// No description provided for @statsNightFeeds.
  ///
  /// In en, this message translates to:
  /// **'Night Feeds'**
  String get statsNightFeeds;

  /// No description provided for @statsHoldToEdit.
  ///
  /// In en, this message translates to:
  /// **'hold to edit'**
  String get statsHoldToEdit;

  /// No description provided for @statsEditSession.
  ///
  /// In en, this message translates to:
  /// **'Edit Session'**
  String get statsEditSession;

  /// No description provided for @statsEditHint.
  ///
  /// In en, this message translates to:
  /// **'Adjust end time if you forgot to stop the timer'**
  String get statsEditHint;

  /// No description provided for @statsStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get statsStart;

  /// No description provided for @statsEnd.
  ///
  /// In en, this message translates to:
  /// **'End (tap to change)'**
  String get statsEnd;

  /// No description provided for @statsDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration: {minutes} min'**
  String statsDuration(int minutes);

  /// No description provided for @statsNursingHistory.
  ///
  /// In en, this message translates to:
  /// **'Nursing History'**
  String get statsNursingHistory;

  /// No description provided for @statsNoSessionsInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No sessions in this period'**
  String get statsNoSessionsInPeriod;

  /// No description provided for @statsNightLabel.
  ///
  /// In en, this message translates to:
  /// **'Night (12a–6a)'**
  String get statsNightLabel;

  /// No description provided for @statsTotalNursingLabel.
  ///
  /// In en, this message translates to:
  /// **'Total nursing'**
  String get statsTotalNursingLabel;

  /// No description provided for @statsWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get statsWeightLabel;

  /// No description provided for @statsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get statsToday;

  /// No description provided for @statsSelectPeriod.
  ///
  /// In en, this message translates to:
  /// **'Select Period'**
  String get statsSelectPeriod;

  /// No description provided for @statsCustomRange.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get statsCustomRange;

  /// No description provided for @diaperLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Diaper'**
  String get diaperLogTitle;

  /// No description provided for @diaperType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get diaperType;

  /// No description provided for @diaperTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get diaperTime;

  /// No description provided for @diaperWet.
  ///
  /// In en, this message translates to:
  /// **'Wet'**
  String get diaperWet;

  /// No description provided for @diaperDirty.
  ///
  /// In en, this message translates to:
  /// **'Dirty'**
  String get diaperDirty;

  /// No description provided for @diaperBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get diaperBoth;

  /// No description provided for @diaperJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get diaperJustNow;

  /// No description provided for @diaperMinAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String diaperMinAgo(int minutes);

  /// No description provided for @diaperHourAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String diaperHourAgo(int hours);

  /// No description provided for @diaperNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get diaperNow;

  /// No description provided for @diaperChangeTime.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get diaperChangeTime;

  /// No description provided for @weightTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightTitle;

  /// No description provided for @weightLogButton.
  ///
  /// In en, this message translates to:
  /// **'Log weight'**
  String get weightLogButton;

  /// No description provided for @weightEmpty.
  ///
  /// In en, this message translates to:
  /// **'No weight entries yet.\nTap \"Log weight\" to add the first one.'**
  String get weightEmpty;

  /// No description provided for @weightLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest weight'**
  String get weightLatest;

  /// No description provided for @weightSinceLast.
  ///
  /// In en, this message translates to:
  /// **'{sign}{grams}g since last entry'**
  String weightSinceLast(String sign, int grams);

  /// No description provided for @weightLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Weight'**
  String get weightLogTitle;

  /// No description provided for @weightMoreInStats.
  ///
  /// In en, this message translates to:
  /// **'+{count} more — full history in Stats'**
  String weightMoreInStats(int count);

  /// No description provided for @weightProgress.
  ///
  /// In en, this message translates to:
  /// **'Weight Progress'**
  String get weightProgress;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the language used throughout the app'**
  String get settingsLanguageHint;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Controls what appears while a nursing session is active'**
  String get settingsNotificationsHint;

  /// No description provided for @settingsNotifTimer.
  ///
  /// In en, this message translates to:
  /// **'Show timer in notification bar'**
  String get settingsNotifTimer;

  /// No description provided for @settingsNotifTimerHint.
  ///
  /// In en, this message translates to:
  /// **'Displays a persistent notification while nursing with a Finish button'**
  String get settingsNotifTimerHint;

  /// No description provided for @settingsOverlay.
  ///
  /// In en, this message translates to:
  /// **'Floating timer'**
  String get settingsOverlay;

  /// No description provided for @settingsOverlayHint.
  ///
  /// In en, this message translates to:
  /// **'Shows a badge over other apps while nursing — requires overlay permission'**
  String get settingsOverlayHint;

  /// No description provided for @settingsBabyProfile.
  ///
  /// In en, this message translates to:
  /// **'Baby Profile'**
  String get settingsBabyProfile;

  /// No description provided for @settingsBabyProfileHint.
  ///
  /// In en, this message translates to:
  /// **'Used to calculate recommended feed intervals'**
  String get settingsBabyProfileHint;

  /// No description provided for @settingsBabyName.
  ///
  /// In en, this message translates to:
  /// **'Baby\'s name'**
  String get settingsBabyName;

  /// No description provided for @settingsBabyNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Emma'**
  String get settingsBabyNameHint;

  /// No description provided for @settingsBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get settingsBirthDate;

  /// No description provided for @settingsBirthDateSelect.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get settingsBirthDateSelect;

  /// No description provided for @settingsSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get settingsSaveProfile;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved!'**
  String get settingsSaved;

  /// No description provided for @settingsFeedInterval.
  ///
  /// In en, this message translates to:
  /// **'Recommended feed interval'**
  String get settingsFeedInterval;

  /// No description provided for @settingsFeedIntervalEvery.
  ///
  /// In en, this message translates to:
  /// **'Every {min}–{max} hours'**
  String settingsFeedIntervalEvery(double min, double max);

  /// No description provided for @settingsClearStats.
  ///
  /// In en, this message translates to:
  /// **'Clear All Stats'**
  String get settingsClearStats;

  /// No description provided for @settingsClearStatsHint.
  ///
  /// In en, this message translates to:
  /// **'Permanently deletes all sessions, diapers and weight entries. Baby profile is kept.'**
  String get settingsClearStatsHint;

  /// No description provided for @settingsClearStatsConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all stats?'**
  String get settingsClearStatsConfirmTitle;

  /// No description provided for @settingsClearStatsConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'This will delete all nursing sessions, diapers and weight entries. This cannot be undone.'**
  String get settingsClearStatsConfirmHint;

  /// No description provided for @settingsClearStatsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsClearStatsCancel;

  /// No description provided for @settingsClearStatsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get settingsClearStatsConfirm;

  /// No description provided for @settingsFeedIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Feed interval'**
  String get settingsFeedIntervalLabel;

  /// No description provided for @settingsFeedIntervalMin.
  ///
  /// In en, this message translates to:
  /// **'1h'**
  String get settingsFeedIntervalMin;

  /// No description provided for @settingsFeedIntervalMax.
  ///
  /// In en, this message translates to:
  /// **'6h'**
  String get settingsFeedIntervalMax;

  /// No description provided for @settingsResetToRecommended.
  ///
  /// In en, this message translates to:
  /// **'Reset to recommended'**
  String get settingsResetToRecommended;

  /// No description provided for @settingsRecommendedForAge.
  ///
  /// In en, this message translates to:
  /// **'Recommended for age: every {min}–{max}h'**
  String settingsRecommendedForAge(double min, double max);

  /// No description provided for @settingsCustomInterval.
  ///
  /// In en, this message translates to:
  /// **'Custom: every {interval}'**
  String settingsCustomInterval(String interval);

  /// No description provided for @settingsEnterBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Enter birth date to see recommendation'**
  String get settingsEnterBirthDate;

  /// No description provided for @weeksOld.
  ///
  /// In en, this message translates to:
  /// **'{weeks} {weeks, plural, =1{week} other{weeks}} old'**
  String weeksOld(int weeks);

  /// No description provided for @monthsOld.
  ///
  /// In en, this message translates to:
  /// **'{months} {months, plural, =1{month} other{months}} old'**
  String monthsOld(int months);
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
      <String>['en', 'nl', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
