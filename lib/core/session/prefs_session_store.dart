import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'session_store.dart';

/// Non-secrets backend — user snapshot + lastLoginAt in `SharedPreferences`.
///
/// Narrow contract — `CompositeSessionStore` wires it alongside
/// `SecureSessionStore` to satisfy the full `SessionStore` interface.
class PrefsSessionStore implements PrefsSessionBackend {
  static const String _kUser = 'session_user_snapshot';
  static const String _kLastLoginAt = 'session_last_login_at';
  static const String _kOnboardingSeen = 'session_onboarding_seen';

  static const String _kFcmToken = 'session_fcm_token';

  static String get onboardingSeenKey => _kOnboardingSeen;

  final SharedPreferences _prefs;

  PrefsSessionStore(this._prefs);

  @override
  Future<UserSnapshot?> readUser() async {
    final raw = _prefs.getString(_kUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return UserSnapshot.fromJson(decoded);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  @override
  Future<void> writeUser(UserSnapshot user) async {
    await _prefs.setString(_kUser, jsonEncode(user.toJson()));
  }

  @override
  Future<void> clearUser() async {
    await _prefs.remove(_kUser);
  }

  @override
  Future<DateTime?> readLastLoginAt() async {
    final raw = _prefs.getString(_kLastLoginAt);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  @override
  Future<void> writeLastLoginAt(DateTime when) async {
    await _prefs.setString(_kLastLoginAt, when.toIso8601String());
  }

  @override
  Future<void> clearLastLoginAt() async {
    await _prefs.remove(_kLastLoginAt);
  }

  @override
  Future<bool> readOnboardingSeen() async {
    return _prefs.getBool(_kOnboardingSeen) ?? false;
  }

  @override
  Future<void> writeOnboardingSeen(bool seen) async {
    await _prefs.setBool(_kOnboardingSeen, seen);
  }

  @override
  Future<String?> readFcmToken() async {
    return _prefs.getString(_kFcmToken);
  }

  @override
  Future<void> writeFcmToken(String fcmToken) async {
    await _prefs.setString(_kFcmToken, fcmToken);
  }

  @override
  Future<void> clearFcmToken() async {
    await _prefs.remove(_kFcmToken);
  }

  @override
  Future<String> getAppSessionId() async {
    final user = await readUser();
    final userSuffix = user != null ? '_${user.id}' : '';
    final key = 'app_session_id$userSuffix';

    final existingId = _prefs.getString(key);
    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }
    final newId = const Uuid().v4();
    await _prefs.setString(key, newId);
    return newId;
  }

  @override
  Future<void> clearAppSessionId() async {
    await _prefs.remove('app_session_id');
  }
}
