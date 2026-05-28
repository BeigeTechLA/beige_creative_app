import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/session/prefs_session_store.dart';
import '../core/session/secure_session_store.dart';
import '../core/session/session_store.dart';

/// Deprecated facade — forwards to [SessionStore].
///
/// Existing call sites continue to use the static
/// `SharedService.setLoginDetails(...)` / `SharedService.logout()` surface.
/// Each method delegates to a bound `SessionStore`. `startApp` binds the
/// composite via [bind] right after `Env.init`.
///
/// **Phase 5.01** deletes this file once Phase 4 migrates the last consumer.
@Deprecated(
  'Use SessionStore (via sessionStoreProvider) instead. '
  'This shim is removed in Phase 5.01.',
)
class SharedService {
  SharedService._();

  static SessionStore? _bound;

  /// Wires the shim to a `SessionStore` instance. Call once during `startApp`.
  static void bind(SessionStore session) {
    _bound = session;
  }

  /// Lazy fallback — builds a `CompositeSessionStore` from defaults if [bind]
  /// hasn't been called. Safety net during migration; startup path always
  /// binds explicitly.
  static Future<SessionStore> _session() async {
    final existing = _bound;
    if (existing != null) return existing;
    final prefs = await SharedPreferences.getInstance();
    final session = CompositeSessionStore(
      secure: SecureSessionStore(),
      prefs: PrefsSessionStore(prefs),
    );
    _bound = session;
    return session;
  }

  /// Persist auth token from the login API response. Token presence is the
  /// single source of truth for "logged in"; user-snapshot fields are also
  /// captured if present.
  static Future<void> setLoginDetails(Map<String, dynamic> response) async {
    final data = response['data'] ?? const {};
    final String token = data['token']?.toString() ?? '';
    if (token.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          'setLoginDetails called with empty token — skipping persist',
        );
      }
      return;
    }

    final session = await _session();
    await session.writeToken(token);

    final user = data['user'];
    if (user is Map<String, dynamic>) {
      try {
        await session.writeUser(UserSnapshot.fromJson(user));
      } catch (_) {
        // Snapshot fields are best-effort — never block login on parse error.
      }
    }
    await session.writeLastLoginAt(DateTime.now().toUtc());
    if (kDebugMode) debugPrint('Auth token persisted via SessionStore');
  }

  /// Clear auth/session state only. Remember-me credentials and any future
  /// non-auth preferences are preserved (no `prefs.clear()` — keyed deletes
  /// only). Closes the AUDIT_SEC finding about blanket-wipe-on-logout.
  static Future<void> logout() async {
    final session = await _session();
    await session.clearSession();
    if (kDebugMode) debugPrint('Auth state cleared on logout');
  }
}
