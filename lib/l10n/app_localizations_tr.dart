// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Nursing Pulse';

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navStats => 'İstatistik';

  @override
  String get navBaby => 'Bebek';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get lastNursingLabel => 'SON EMZİRME';

  @override
  String get lastNursingNoSessions => 'Henüz kayıt yok';

  @override
  String lastNursingAgo(String time, String side) {
    return '$time önce • $side';
  }

  @override
  String lastNursingMinAgo(int minutes, String side, int duration) {
    return '$minutes dakika önce • $side • $duration dk';
  }

  @override
  String lastNursingHourAgo(
    int hours,
    int remainingMinutes,
    String side,
    int duration,
  ) {
    return '$hours:$remainingMinutes önce • $side • $duration dk';
  }

  @override
  String get sideLeft => 'Sol';

  @override
  String get sideRight => 'Sağ';

  @override
  String get sideLeftFull => 'Sol taraf';

  @override
  String get sideRightFull => 'Sağ taraf';

  @override
  String get startNursing => 'Emzirmeye Başla';

  @override
  String get finishSession => 'Seansı Bitir';

  @override
  String get nursing => 'Emziriliyor...';

  @override
  String get nextSuggestedFeed => 'Sonraki önerilen besleme';

  @override
  String nextFeedAround(String time) {
    return 'Yaklaşık $time';
  }

  @override
  String get dailyTotal => 'Günlük Toplam';

  @override
  String get diapers => 'Bezler';

  @override
  String diapersToday(int count) {
    return 'Bugün $count adet';
  }

  @override
  String diapersMoreInStats(int count) {
    return 'Bugün +$count daha — tam geçmiş İstatistik\'te';
  }

  @override
  String get statsTodaySummary => 'Bugünün Özeti';

  @override
  String get statsTotalNursing => 'bugün toplam emzirme';

  @override
  String get statsNoSessionsYet => 'Henüz kayıt yok';

  @override
  String get statsLateralBalance => 'TARAF DENGESİ';

  @override
  String get statsLeftSide => 'Sol Taraf';

  @override
  String get statsRightSide => 'Sağ Taraf';

  @override
  String get statsTodaySessions => 'Bugünkü Seanslar';

  @override
  String get statsNoSessionsToday => 'Bugün kayıtlı seans yok';

  @override
  String get statsAvgDuration => 'Ort. Süre';

  @override
  String get statsNightFeeds => 'Gece Beslemesi';

  @override
  String get statsHoldToEdit => 'düzenlemek için basılı tut';

  @override
  String get statsEditSession => 'Seansı Düzenle';

  @override
  String get sessionAddTitle => 'Seans Ekle';

  @override
  String get statsEditHint => 'Değiştirmek için saate dokunun';

  @override
  String get statsStart => 'Başlangıç';

  @override
  String get statsEnd => 'Bitiş';

  @override
  String statsDuration(int minutes) {
    return 'Süre: $minutes dakika';
  }

  @override
  String get statsNursingHistory => 'Emzirme Geçmişi';

  @override
  String get statsNoSessionsInPeriod => 'Bu dönemde seans yok';

  @override
  String get statsNightLabel => 'Gece (00:00–06:00)';

  @override
  String get statsTotalNursingLabel => 'Toplam emzirme';

  @override
  String get statsWeightLabel => 'Kilo';

  @override
  String get statsUnitMin => 'dk';

  @override
  String get statsUnitTimes => 'kez';

  @override
  String get statsToday => 'Bugün';

  @override
  String get statsYesterday => 'Dün';

  @override
  String get statsLast7Days => 'Son 7 gün';

  @override
  String get statsLast14Days => 'Son 14 gün';

  @override
  String get statsDaytimeLabel => 'Gündüz';

  @override
  String get statsDiapersLabel => 'Bez';

  @override
  String get statsSelectPeriod => 'Dönem Seç';

  @override
  String get statsCustomRange => 'Özel aralık';

  @override
  String get weightMinEntries =>
      'Grafiği görmek için en az 2 kilo kaydı ekleyin';

  @override
  String get diaperLogTitle => 'Bez Kaydı';

  @override
  String get diaperType => 'Tür';

  @override
  String get diaperTime => 'Saat';

  @override
  String get diaperWet => 'Islak';

  @override
  String get diaperDirty => 'Kirli';

  @override
  String get diaperBoth => 'İkisi de';

  @override
  String get diaperJustNow => 'Az önce';

  @override
  String diaperMinAgo(int minutes) {
    return '$minutes dakika önce';
  }

  @override
  String diaperHourAgo(int hours) {
    return '$hours saat önce';
  }

  @override
  String get diaperNow => 'Şimdi';

  @override
  String get diaperChangeTime => 'Değiştir';

  @override
  String get weightTitle => 'Kilo';

  @override
  String get weightLogButton => 'Kilo gir';

  @override
  String get weightEmpty =>
      'Henüz kilo kaydı yok.\nİlk kaydı eklemek için \"Kilo gir\"e dokun.';

  @override
  String get weightLatest => 'Son kilo';

  @override
  String weightSinceLast(String sign, int grams) {
    return 'Son kayıttan $sign${grams}g';
  }

  @override
  String get weightLogTitle => 'Kilo Gir';

  @override
  String weightMoreInStats(int count) {
    return '+$count daha — tam geçmiş İstatistik\'te';
  }

  @override
  String get weightProgress => 'Kilo Gelişimi';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'İptal';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsLanguageHint => 'Uygulamada kullanılan dili seçin';

  @override
  String get settingsLanguageSystem => 'Sistem varsayılanı';

  @override
  String get settingsNotifications => 'Bildirimler';

  @override
  String get settingsNotificationsHint =>
      'Emzirme seansı sırasında nelerin görüneceğini ayarlar';

  @override
  String get settingsNotifTimer => 'Bildirimlerde zamanlayıcıyı göster';

  @override
  String get settingsNotifTimerHint =>
      'Emzirme sırasında bildirim çubuğunda Bitir butonu ile kalıcı bildirim gösterir';

  @override
  String get settingsOverlay => 'Yüzen zamanlayıcı';

  @override
  String get settingsOverlayHint =>
      'Emzirme sırasında diğer uygulamaların üzerinde rozet gösterir — bindirme izni gerektirir';

  @override
  String get settingsBabyProfile => 'Bebek Profili';

  @override
  String get settingsBabyProfileHint =>
      'Önerilen besleme aralığını hesaplamak için kullanılır';

  @override
  String get settingsBabyName => 'Bebeğin adı';

  @override
  String get settingsBabyNameHint => 'örn. Defne';

  @override
  String get settingsBirthDate => 'Doğum tarihi';

  @override
  String get settingsBirthDateSelect => 'Tarih seçin';

  @override
  String get settingsSaveProfile => 'Profili Kaydet';

  @override
  String get settingsSaved => 'Kaydedildi!';

  @override
  String get settingsFeedInterval => 'Önerilen besleme aralığı';

  @override
  String settingsFeedIntervalEvery(double min, double max) {
    return 'Her $min–$max saatte bir';
  }

  @override
  String get settingsClearStats => 'Tüm Verileri Sil';

  @override
  String get settingsClearStatsHint =>
      'Tüm seansları, bezleri ve kilo kayıtlarını kalıcı olarak siler. Bebek profili korunur.';

  @override
  String get settingsClearStatsConfirmTitle => 'Tüm veriler silinsin mi?';

  @override
  String get settingsClearStatsConfirmHint =>
      'Tüm emzirme seansları, bezler ve kilo kayıtları silinecek. Bu işlem geri alınamaz.';

  @override
  String get settingsClearStatsCancel => 'İptal';

  @override
  String get settingsClearStatsConfirm => 'Sil';

  @override
  String get settingsFeedIntervalLabel => 'Besleme aralığı';

  @override
  String get settingsFeedIntervalMin => '1s';

  @override
  String get settingsFeedIntervalMax => '6s';

  @override
  String get settingsFeedIntervalDisclaimer =>
      'Besleme aralıkları tahminidir. Her zaman sağlık uzmanınızın önerilerine uyun.';

  @override
  String get settingsResetToRecommended => 'Öneriye sıfırla';

  @override
  String settingsRecommendedForAge(double min, double max) {
    return 'Yaşa göre öneri: her $min–${max}s';
  }

  @override
  String settingsCustomInterval(String interval) {
    return 'Özel: her $interval';
  }

  @override
  String get settingsEnterBirthDate =>
      'Öneriyi görmek için doğum tarihini girin';

  @override
  String weeksOld(int weeks) {
    return '$weeks haftalık';
  }

  @override
  String monthsOld(int months) {
    return '$months aylık';
  }
}
