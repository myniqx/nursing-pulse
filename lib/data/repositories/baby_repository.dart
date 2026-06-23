import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/baby_profile.dart';
import '../models/diaper_log.dart';
import '../models/weight_entry.dart';

class BabyRepository {
  static const _profileKey = 'np_baby_profile';
  static const _diapersKey = 'np_diapers';
  static const _weightsKey = 'np_weights';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // --- Profile ---

  Future<BabyProfile?> getProfile() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_profileKey);
    if (raw == null) return null;
    return BabyProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveProfile(BabyProfile profile) async {
    final prefs = await _prefs;
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  // --- Diapers ---

  Future<List<DiaperLog>> getDiapers() async {
    final prefs = await _prefs;
    final raw = prefs.getStringList(_diapersKey) ?? [];
    return raw
        .map((e) => DiaperLog.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.time.compareTo(a.time));
  }

  Future<void> addDiaper(DiaperLog log) async {
    final prefs = await _prefs;
    final existing = prefs.getStringList(_diapersKey) ?? [];
    existing.add(jsonEncode(log.toJson()));
    await prefs.setStringList(_diapersKey, existing);
  }

  Future<void> deleteDiaper(String id) async {
    final prefs = await _prefs;
    final existing = prefs.getStringList(_diapersKey) ?? [];
    existing.removeWhere((e) {
      final decoded = jsonDecode(e) as Map<String, dynamic>;
      return decoded['id'] == id;
    });
    await prefs.setStringList(_diapersKey, existing);
  }

  // --- Weights ---

  Future<List<WeightEntry>> getWeights() async {
    final prefs = await _prefs;
    final raw = prefs.getStringList(_weightsKey) ?? [];
    return raw
        .map((e) => WeightEntry.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addWeight(WeightEntry entry) async {
    final prefs = await _prefs;
    final existing = prefs.getStringList(_weightsKey) ?? [];
    existing.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(_weightsKey, existing);
  }

  Future<void> deleteWeight(String id) async {
    final prefs = await _prefs;
    final existing = prefs.getStringList(_weightsKey) ?? [];
    existing.removeWhere((e) {
      final decoded = jsonDecode(e) as Map<String, dynamic>;
      return decoded['id'] == id;
    });
    await prefs.setStringList(_weightsKey, existing);
  }
}
