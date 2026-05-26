import 'package:flutter/foundation.dart';

import 'prefs_service.dart';

class SharedService {
  SharedService._();

  /// Persist auth token from the login API response.
  ///
  /// Token presence is the single source of truth for "logged in" — no
  /// separate flag is stored. Identity fields are refetched from the
  /// profile endpoint when needed.
  static Future<void> setLoginDetails(Map<String, dynamic> response) async {
    final data = response['data'] ?? {};
    final String token = data['token'] ?? '';

    if (token.isEmpty) {
      debugPrint('setLoginDetails called with empty token — skipping persist');
      return;
    }

    await PrefsService.setToken(token);
    debugPrint('Auth token persisted');
  }

  /// Clear auth/session state only. Remember-me credentials and any
  /// future non-auth preferences are preserved.
  static Future<void> logout() async {
    await PrefsService.clearAuth();
    debugPrint('Auth state cleared on logout');
  }
}
