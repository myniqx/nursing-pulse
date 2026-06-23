import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../shared/dev_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';
import '../models/diaper_log.dart';
import '../models/weight_entry.dart';
import '../models/baby_profile.dart';

class MockDataSeeder {
  // Bump this version whenever seed data changes — forces a re-seed
  static const _seededVersion = 2;
  static const _seededKey = 'np_mock_seeded_v';

  // Feed times clustered around realistic newborn schedule (hour of day)
  static const _feedHours = [1, 4, 7, 10, 13, 16, 19, 22];

  static Future<void> forceSeed() async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('[MockDataSeeder] Force seeding...');
    await _seedSessions(prefs);
    await _seedDiapers(prefs);
    await _seedWeights(prefs);
    await _seedProfile(prefs);
    await prefs.setInt(_seededKey, _seededVersion);
    debugPrint('[MockDataSeeder] Done.');
  }

  static Future<void> seedIfNeeded() async {
    // Only runs on Windows debug builds
    if (!_shouldSeed) return;

    final prefs = await SharedPreferences.getInstance();
    final seededVersion = prefs.getInt(_seededKey) ?? 0;
    if (seededVersion >= _seededVersion) return;

    debugPrint('[MockDataSeeder] Seeding mock data (v$_seededVersion)...');
    await _seedSessions(prefs);
    await _seedDiapers(prefs);
    await _seedWeights(prefs);
    await _seedProfile(prefs);

    await prefs.setInt(_seededKey, _seededVersion);
    debugPrint('[MockDataSeeder] Done.');
  }

  static bool get _shouldSeed => isDev;

  static Future<void> _seedSessions(SharedPreferences prefs) async {
    final rng = Random(42);
    final now = DateTime.now();
    final sessions = <Session>[];

    for (int day = 180; day >= 0; day--) {
      final date = now.subtract(Duration(days: day));

      // 7–10 sessions per day
      final sessionCount = 7 + rng.nextInt(4);
      // Pick that many hours from the schedule, adding small jitter
      final hours = List<int>.from(_feedHours)..shuffle(rng);
      final dayHours = hours.take(sessionCount).toList()..sort();

      // Alternate sides across the day, with occasional repeats
      NursingSide side = rng.nextBool() ? NursingSide.left : NursingSide.right;

      for (final hour in dayHours) {
        final minuteJitter = rng.nextInt(40) - 20; // ±20 min
        final start = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          30 + minuteJitter,
        );

        // Skip future times
        if (start.isAfter(now)) continue;

        // Duration: 8–25 minutes, night feeds slightly shorter
        final isNight = hour >= 22 || hour <= 5;
        final durationMin = isNight
            ? 8 + rng.nextInt(10)
            : 12 + rng.nextInt(14);
        final end = start.add(Duration(minutes: durationMin));

        sessions.add(Session(
          id: '${start.millisecondsSinceEpoch}_mock',
          startTime: start,
          endTime: end,
          side: side,
        ));

        // Alternate side most of the time
        if (rng.nextInt(5) != 0) {
          side = side == NursingSide.left ? NursingSide.right : NursingSide.left;
        }
      }
    }

    final encoded = sessions.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList('np_sessions', encoded);
    debugPrint('[MockDataSeeder] ${sessions.length} sessions seeded.');
  }

  static Future<void> _seedDiapers(SharedPreferences prefs) async {
    final rng = Random(43);
    final now = DateTime.now();
    final logs = <DiaperLog>[];

    for (int day = 180; day >= 0; day--) {
      final date = now.subtract(Duration(days: day));
      final count = 6 + rng.nextInt(3); // 6–8 per day

      for (int i = 0; i < count; i++) {
        final isToday = day == 0;
        // For today cap hours to current hour, for past days use full range
        final maxHour = isToday ? now.hour : 23;
        if (maxHour < 6) continue; // too early today, skip
        final hour = 6 + rng.nextInt((maxHour - 6).clamp(1, 18));
        final time = DateTime(date.year, date.month, date.day, hour,
            rng.nextInt(60));

        if (time.isAfter(now)) continue;

        // Weighted: wet 50%, dirty 30%, both 20%
        final roll = rng.nextInt(10);
        final type = roll < 5
            ? DiaperType.wet
            : roll < 8
                ? DiaperType.dirty
                : DiaperType.both;

        logs.add(DiaperLog(
          id: '${time.millisecondsSinceEpoch}_mock',
          time: time,
          type: type,
        ));
      }
    }

    final encoded = logs.map((l) => jsonEncode(l.toJson())).toList();
    await prefs.setStringList('np_diapers', encoded);
    debugPrint('[MockDataSeeder] ${logs.length} diaper logs seeded.');
  }

  static Future<void> _seedWeights(SharedPreferences prefs) async {
    final rng = Random(44);
    final now = DateTime.now();
    final entries = <WeightEntry>[];

    // Baby born ~6 months ago at 3200g, gains ~150–200g/week
    int grams = 3200;
    for (int week = 26; week >= 0; week--) {
      final date = now.subtract(Duration(days: week * 7));
      if (date.isAfter(now)) continue;

      entries.add(WeightEntry(
        id: '${date.millisecondsSinceEpoch}_mock',
        date: date,
        grams: grams,
      ));

      grams += 150 + rng.nextInt(70); // 150–220g gain per week
    }

    final encoded = entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('np_weights', encoded);
    debugPrint('[MockDataSeeder] ${entries.length} weight entries seeded.');
  }

  static Future<void> _seedProfile(SharedPreferences prefs) async {
    final existing = prefs.getString('np_baby_profile');
    if (existing != null) return; // don't overwrite real profile

    final profile = BabyProfile(
      name: 'Emma',
      birthDate: DateTime.now().subtract(const Duration(days: 180)),
    );
    await prefs.setString(
        'np_baby_profile', jsonEncode(profile.toJson()));
    debugPrint('[MockDataSeeder] Baby profile seeded.');
  }
}
