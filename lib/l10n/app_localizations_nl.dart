// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Nursing Pulse';

  @override
  String get navHome => 'Home';

  @override
  String get navStats => 'Statistieken';

  @override
  String get navBaby => 'Baby';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get lastNursingLabel => 'LAATSTE VOEDING';

  @override
  String get lastNursingNoSessions => 'Nog geen sessies';

  @override
  String lastNursingAgo(String time, String side) {
    return '$time geleden • $side';
  }

  @override
  String lastNursingMinAgo(int minutes, String side, int duration) {
    return '$minutes min geleden • $side • $duration min';
  }

  @override
  String lastNursingHourAgo(
    int hours,
    int remainingMinutes,
    String side,
    int duration,
  ) {
    return '$hours:$remainingMinutes geleden • $side • $duration min';
  }

  @override
  String get sideLeft => 'Links';

  @override
  String get sideRight => 'Rechts';

  @override
  String get sideLeftFull => 'Linkerkant';

  @override
  String get sideRightFull => 'Rechterkant';

  @override
  String get startNursing => 'Voeding starten';

  @override
  String get finishSession => 'Sessie beëindigen';

  @override
  String get nursing => 'Voeden...';

  @override
  String get nextSuggestedFeed => 'Volgende aanbevolen voeding';

  @override
  String nextFeedAround(String time) {
    return 'Ongeveer $time';
  }

  @override
  String get dailyTotal => 'Dagelijks totaal';

  @override
  String get diapers => 'Luiers';

  @override
  String diapersToday(int count) {
    return '$count vandaag';
  }

  @override
  String diapersMoreInStats(int count) {
    return '+$count meer vandaag — volledige geschiedenis in Statistieken';
  }

  @override
  String get statsTodaySummary => 'Laatste 24 uur';

  @override
  String get statsTotalNursing => 'totale voeding (laatste 24u)';

  @override
  String get statsNoSessionsYet => 'Nog geen sessies';

  @override
  String get statsLateralBalance => 'ZIJBALANS';

  @override
  String get statsLeftSide => 'Linkerkant';

  @override
  String get statsRightSide => 'Rechterkant';

  @override
  String get statsTodaySessions => 'Laatste 24 uur';

  @override
  String get statsNoSessionsToday => 'Geen sessies in de laatste 24 uur';

  @override
  String get statsAvgDuration => 'Gem. duur';

  @override
  String get statsNightFeeds => 'Nachtvoedingen';

  @override
  String get statsHoldToEdit => 'houd ingedrukt om te bewerken';

  @override
  String get statsEditSession => 'Sessie bewerken';

  @override
  String get sessionAddTitle => 'Sessie toevoegen';

  @override
  String get statsEditHint => 'Tik op een tijd om aan te passen';

  @override
  String get statsStart => 'Start';

  @override
  String get statsEnd => 'Einde';

  @override
  String statsDuration(int minutes) {
    return 'Duur: $minutes min';
  }

  @override
  String get statsNursingHistory => 'Voedingsgeschiedenis';

  @override
  String get statsNoSessionsInPeriod => 'Geen sessies in deze periode';

  @override
  String get statsNightLabel => 'Nacht (00:00–06:00)';

  @override
  String get statsTotalNursingLabel => 'Totale voeding';

  @override
  String get statsWeightLabel => 'Gewicht';

  @override
  String get statsUnitMin => 'min';

  @override
  String get statsUnitTimes => 'keer';

  @override
  String get statsToday => 'Vandaag';

  @override
  String get statsYesterday => 'Gisteren';

  @override
  String get statsLast7Days => 'Laatste 7 dagen';

  @override
  String get statsLast14Days => 'Laatste 14 dagen';

  @override
  String get statsDaytimeLabel => 'Overdag';

  @override
  String get statsDiapersLabel => 'Luiers';

  @override
  String get statsSelectPeriod => 'Periode selecteren';

  @override
  String get statsCustomRange => 'Aangepast bereik';

  @override
  String get weightMinEntries =>
      'Voeg minimaal 2 gewichtsinvoeren toe om de grafiek te zien';

  @override
  String get diaperLogTitle => 'Luier registreren';

  @override
  String get diaperType => 'Type';

  @override
  String get diaperTime => 'Tijd';

  @override
  String get diaperWet => 'Nat';

  @override
  String get diaperDirty => 'Vuil';

  @override
  String get diaperBoth => 'Beide';

  @override
  String get diaperJustNow => 'Zojuist';

  @override
  String diaperMinAgo(int minutes) {
    return '$minutes min geleden';
  }

  @override
  String diaperHourAgo(int hours) {
    return '${hours}u geleden';
  }

  @override
  String get diaperNow => 'Nu';

  @override
  String get diaperChangeTime => 'Wijzigen';

  @override
  String get weightTitle => 'Gewicht';

  @override
  String get weightLogButton => 'Gewicht loggen';

  @override
  String get weightEmpty =>
      'Nog geen gewichtsinvoer.\nTik op \"Gewicht loggen\" om de eerste toe te voegen.';

  @override
  String get weightLatest => 'Laatste gewicht';

  @override
  String weightSinceLast(String sign, int grams) {
    return '$sign${grams}g sinds laatste invoer';
  }

  @override
  String get weightLogTitle => 'Gewicht loggen';

  @override
  String weightMoreInStats(int count) {
    return '+$count meer — volledige geschiedenis in Statistieken';
  }

  @override
  String get weightProgress => 'Gewichtsontwikkeling';

  @override
  String get save => 'Opslaan';

  @override
  String get cancel => 'Annuleren';

  @override
  String get settingsLanguage => 'Taal';

  @override
  String get settingsLanguageHint =>
      'Kies de taal die door de app wordt gebruikt';

  @override
  String get settingsLanguageSystem => 'Systeemstandaard';

  @override
  String get settingsNotifications => 'Meldingen';

  @override
  String get settingsNotificationsHint =>
      'Bepaalt wat er wordt weergegeven tijdens een voedingssessie';

  @override
  String get settingsNotifTimer => 'Timer in meldingenbalk tonen';

  @override
  String get settingsNotifTimerHint =>
      'Toont een permanente melding tijdens het voeden met een Stoppen-knop';

  @override
  String get settingsOverlay => 'Zwevende timer';

  @override
  String get settingsOverlayHint =>
      'Toont een badge over andere apps tijdens het voeden — vereist overlay-toestemming';

  @override
  String get settingsBabyProfile => 'Babyprofiel';

  @override
  String get settingsBabyProfileHint =>
      'Wordt gebruikt om aanbevolen voedingsintervallen te berekenen';

  @override
  String get settingsBabyName => 'Naam van de baby';

  @override
  String get settingsBabyNameHint => 'bijv. Emma';

  @override
  String get settingsBirthDate => 'Geboortedatum';

  @override
  String get settingsBirthDateSelect => 'Datum selecteren';

  @override
  String get settingsSaveProfile => 'Profiel opslaan';

  @override
  String get settingsSaved => 'Opgeslagen!';

  @override
  String get settingsFeedInterval => 'Aanbevolen voedingsinterval';

  @override
  String settingsFeedIntervalEvery(double min, double max) {
    return 'Elke $min–$max uur';
  }

  @override
  String get settingsClearStats => 'Alle gegevens wissen';

  @override
  String get settingsClearStatsHint =>
      'Verwijdert permanent alle sessies, luiers en gewichtsinvoer. Babyprofiel blijft bewaard.';

  @override
  String get settingsClearStatsConfirmTitle => 'Alle statistieken wissen?';

  @override
  String get settingsClearStatsConfirmHint =>
      'Dit verwijdert alle voedingssessies, luiers en gewichtsinvoer. Dit kan niet ongedaan worden gemaakt.';

  @override
  String get settingsClearStatsCancel => 'Annuleren';

  @override
  String get settingsClearStatsConfirm => 'Wissen';

  @override
  String get settingsFeedIntervalLabel => 'Voedingsinterval';

  @override
  String get settingsFeedIntervalMin => '1u';

  @override
  String get settingsFeedIntervalMax => '6u';

  @override
  String get settingsFeedIntervalDisclaimer =>
      'Voedingsintervallen zijn schattingen. Volg altijd het advies van uw zorgverlener.';

  @override
  String get settingsResetToRecommended => 'Terug naar aanbevolen';

  @override
  String settingsRecommendedForAge(double min, double max) {
    return 'Aanbevolen voor leeftijd: elke $min–${max}u';
  }

  @override
  String settingsCustomInterval(String interval) {
    return 'Aangepast: elke $interval';
  }

  @override
  String get settingsEnterBirthDate =>
      'Voer geboortedatum in om aanbeveling te zien';

  @override
  String weeksOld(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'weken',
      one: 'week',
    );
    return '$weeks $_temp0 oud';
  }

  @override
  String monthsOld(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'maanden',
      one: 'maand',
    );
    return '$months $_temp0 oud';
  }
}
