import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'session_store.dart';

/// One-time migration of legacy auth state into [SessionStore].
///
/// Older builds persisted the auth token in `SharedPreferences['token']`.
/// That key is a security finding (`AUDIT_SEC.md`) — prefs are world-readable
/// on rooted devices. This helper moves the legacy token into the secure
/// backend on first boot after upgrade, then drops the prefs key.
///
/// Idempotent — guarded by a sentinel (`session_migration_v1_done`) so it runs
/// at most once per install.
class SessionMigration {
  SessionMigration._();

  /// Sentinel key — bumping the suffix re-triggers migration if the schema
  /// changes in a future release.
  static const String _sentinelKey = 'session_migration_v1_done';
  static const String _legacyTokenKey = 'token';

  /// Run before `runApp`. Safe to call every launch — exits early after the
  /// first successful pass.
  static Future<void> runOnce({
    required SharedPreferences prefs,
    required SessionStore session,
  }) async {
    if (prefs.getBool(_sentinelKey) == true) return;

    final legacyToken = prefs.getString(_legacyTokenKey);
    if (legacyToken != null && legacyToken.isNotEmpty) {
      final existingSecureToken = await session.readToken();
      if (existingSecureToken == null || existingSecureToken.isEmpty) {
        await session.writeToken(legacyToken);
        if (kDebugMode) {
          debugPrint('SessionMigration: token moved prefs → secure storage');
        }
      }
      await prefs.remove(_legacyTokenKey);
    }

    await prefs.setBool(_sentinelKey, true);
  }
}
