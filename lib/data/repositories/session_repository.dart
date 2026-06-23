import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';

class SessionRepository {
  static const _sessionsKey = 'np_sessions';
  static const _activeSessionKey = 'np_active_session';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<Session>> getSessions() async {
    final prefs = await _prefs;
    final raw = prefs.getStringList(_sessionsKey) ?? [];
    return raw
        .map((e) => Session.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  Future<Session?> getActiveSession() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_activeSessionKey);
    if (raw == null) return null;
    return Session.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> startSession(Session session) async {
    final prefs = await _prefs;
    await prefs.setString(_activeSessionKey, jsonEncode(session.toJson()));
  }

  Future<Session> finishActiveSession(DateTime endTime) async {
    final prefs = await _prefs;
    final active = await getActiveSession();
    if (active == null) throw StateError('No active session');

    final finished = active.copyWith(endTime: endTime);
    await prefs.remove(_activeSessionKey);

    final existing = prefs.getStringList(_sessionsKey) ?? [];
    existing.add(jsonEncode(finished.toJson()));
    await prefs.setStringList(_sessionsKey, existing);

    return finished;
  }

  Future<void> updateSession(Session session) async {
    final prefs = await _prefs;
    final existing = prefs.getStringList(_sessionsKey) ?? [];
    final updated = existing.map((e) {
      final decoded = jsonDecode(e) as Map<String, dynamic>;
      return decoded['id'] == session.id ? jsonEncode(session.toJson()) : e;
    }).toList();
    await prefs.setStringList(_sessionsKey, updated);
  }
}
