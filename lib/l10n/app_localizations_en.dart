// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Nursing Pulse';

  @override
  String get navHome => 'Home';

  @override
  String get navStats => 'Stats';

  @override
  String get navBaby => 'Baby';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get lastNursingLabel => 'LAST NURSING';

  @override
  String get lastNursingNoSessions => 'No sessions yet';

  @override
  String lastNursingAgo(String time, String side) {
    return '$time ago • $side';
  }

  @override
  String lastNursingMinAgo(int minutes, String side, int duration) {
    return '$minutes min ago • $side • $duration min';
  }

  @override
  String lastNursingHourAgo(int hours, String side, int duration) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'hours',
      one: 'hour',
    );
    return '$hours $_temp0 ago • $side • $duration min';
  }

  @override
  String get sideLeft => 'Left';

  @override
  String get sideRight => 'Right';

  @override
  String get sideLeftFull => 'Left side';

  @override
  String get sideRightFull => 'Right side';

  @override
  String get startNursing => 'Start Nursing';

  @override
  String get finishSession => 'Finish Session';

  @override
  String get nursing => 'Nursing...';

  @override
  String get nextSuggestedFeed => 'Next suggested feed';

  @override
  String nextFeedAround(String time) {
    return 'Around $time';
  }

  @override
  String get dailyTotal => 'Daily Total';

  @override
  String get diapers => 'Diapers';

  @override
  String diapersToday(int count) {
    return '$count today';
  }

  @override
  String diapersMoreInStats(int count) {
    return '+$count more today — full history in Stats';
  }

  @override
  String get statsTodaySummary => 'Today\'s Summary';

  @override
  String get statsTotalNursing => 'total nursing today';

  @override
  String get statsNoSessionsYet => 'No sessions yet';

  @override
  String get statsLateralBalance => 'LATERAL BALANCE';

  @override
  String get statsLeftSide => 'Left Side';

  @override
  String get statsRightSide => 'Right Side';

  @override
  String get statsTodaySessions => 'Today\'s Sessions';

  @override
  String get statsNoSessionsToday => 'No sessions recorded today';

  @override
  String get statsAvgDuration => 'Avg. Duration';

  @override
  String get statsNightFeeds => 'Night Feeds';

  @override
  String get statsHoldToEdit => 'hold to edit';

  @override
  String get statsEditSession => 'Edit Session';

  @override
  String get sessionAddTitle => 'Add Session';

  @override
  String get statsEditHint => 'Tap a time to adjust it';

  @override
  String get statsStart => 'Start';

  @override
  String get statsEnd => 'End';

  @override
  String statsDuration(int minutes) {
    return 'Duration: $minutes min';
  }

  @override
  String get statsNursingHistory => 'Nursing History';

  @override
  String get statsNoSessionsInPeriod => 'No sessions in this period';

  @override
  String get statsNightLabel => 'Night (12a–6a)';

  @override
  String get statsTotalNursingLabel => 'Total nursing';

  @override
  String get statsWeightLabel => 'Weight';

  @override
  String get statsUnitMin => 'min';

  @override
  String get statsUnitTimes => 'times';

  @override
  String get statsToday => 'Today';

  @override
  String get statsYesterday => 'Yesterday';

  @override
  String get statsLast7Days => 'Last 7 days';

  @override
  String get statsLast14Days => 'Last 14 days';

  @override
  String get statsDaytimeLabel => 'Daytime';

  @override
  String get statsDiapersLabel => 'Diapers';

  @override
  String get statsSelectPeriod => 'Select Period';

  @override
  String get statsCustomRange => 'Custom range';

  @override
  String get weightMinEntries =>
      'Add at least 2 weight entries to see the chart';

  @override
  String get diaperLogTitle => 'Log Diaper';

  @override
  String get diaperType => 'Type';

  @override
  String get diaperTime => 'Time';

  @override
  String get diaperWet => 'Wet';

  @override
  String get diaperDirty => 'Dirty';

  @override
  String get diaperBoth => 'Both';

  @override
  String get diaperJustNow => 'Just now';

  @override
  String diaperMinAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String diaperHourAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String get diaperNow => 'Now';

  @override
  String get diaperChangeTime => 'Change';

  @override
  String get weightTitle => 'Weight';

  @override
  String get weightLogButton => 'Log weight';

  @override
  String get weightEmpty =>
      'No weight entries yet.\nTap \"Log weight\" to add the first one.';

  @override
  String get weightLatest => 'Latest weight';

  @override
  String weightSinceLast(String sign, int grams) {
    return '$sign${grams}g since last entry';
  }

  @override
  String get weightLogTitle => 'Log Weight';

  @override
  String weightMoreInStats(int count) {
    return '+$count more — full history in Stats';
  }

  @override
  String get weightProgress => 'Weight Progress';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageHint =>
      'Choose the language used throughout the app';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsHint =>
      'Controls what appears while a nursing session is active';

  @override
  String get settingsNotifTimer => 'Show timer in notification bar';

  @override
  String get settingsNotifTimerHint =>
      'Displays a persistent notification while nursing with a Finish button';

  @override
  String get settingsOverlay => 'Floating timer';

  @override
  String get settingsOverlayHint =>
      'Shows a badge over other apps while nursing — requires overlay permission';

  @override
  String get settingsBabyProfile => 'Baby Profile';

  @override
  String get settingsBabyProfileHint =>
      'Used to calculate recommended feed intervals';

  @override
  String get settingsBabyName => 'Baby\'s name';

  @override
  String get settingsBabyNameHint => 'e.g. Emma';

  @override
  String get settingsBirthDate => 'Date of birth';

  @override
  String get settingsBirthDateSelect => 'Select date';

  @override
  String get settingsSaveProfile => 'Save Profile';

  @override
  String get settingsSaved => 'Saved!';

  @override
  String get settingsFeedInterval => 'Recommended feed interval';

  @override
  String settingsFeedIntervalEvery(double min, double max) {
    return 'Every $min–$max hours';
  }

  @override
  String get settingsClearStats => 'Clear All Stats';

  @override
  String get settingsClearStatsHint =>
      'Permanently deletes all sessions, diapers and weight entries. Baby profile is kept.';

  @override
  String get settingsClearStatsConfirmTitle => 'Clear all stats?';

  @override
  String get settingsClearStatsConfirmHint =>
      'This will delete all nursing sessions, diapers and weight entries. This cannot be undone.';

  @override
  String get settingsClearStatsCancel => 'Cancel';

  @override
  String get settingsClearStatsConfirm => 'Clear';

  @override
  String get settingsFeedIntervalLabel => 'Feed interval';

  @override
  String get settingsFeedIntervalMin => '1h';

  @override
  String get settingsFeedIntervalMax => '6h';

  @override
  String get settingsFeedIntervalDisclaimer =>
      'Feeding intervals are estimates. Always follow your healthcare provider\'s advice.';

  @override
  String get settingsResetToRecommended => 'Reset to recommended';

  @override
  String settingsRecommendedForAge(double min, double max) {
    return 'Recommended for age: every $min–${max}h';
  }

  @override
  String settingsCustomInterval(String interval) {
    return 'Custom: every $interval';
  }

  @override
  String get settingsEnterBirthDate => 'Enter birth date to see recommendation';

  @override
  String weeksOld(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'weeks',
      one: 'week',
    );
    return '$weeks $_temp0 old';
  }

  @override
  String monthsOld(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'months',
      one: 'month',
    );
    return '$months $_temp0 old';
  }
}
