import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/routes.dart';
import 'restoration_keys.dart';

/// Persists the user's current GoRouter location to SharedPreferences so the
/// app can restore it after process death.
///
/// Pure logic in [shouldPersist] / [readRestorable] is testable without a
/// real SharedPreferences instance — see `test/core/restoration/`.
class RouteRestorationService {
  RouteRestorationService(this._prefs) {
    _migrateSchema();
  }

  final SharedPreferences _prefs;

  /// Routes that must never be persisted on top of the public-path block
  /// list. OTP / success / change-password screens would land the user on
  /// dead-end screens after restore.
  static const Set<String> _extraSkipPaths = {
    '/profile-otp',
    '/new-password',
    '/change-password',
    '/profile-password-success',
    '/delete-account-otp',
    '/delete-account-success',
  };

  /// Pure helper — true if [location] is eligible for persistence.
  /// `Routes.publicPaths` covers splash + onboarding + auth + signup +
  /// forgot/reset; [_extraSkipPaths] adds OTP/success surfaces.
  static bool shouldPersist(String location) {
    if (Routes.publicPaths.contains(location)) return false;
    if (_extraSkipPaths.contains(location)) return false;
    return true;
  }

  /// Persists [matchedLocation] with query + path params.
  Future<void> persist({
    required String matchedLocation,
    Map<String, String> queryParameters = const {},
    Map<String, String> pathParameters = const {},
  }) async {
    if (!kRestorationEnabled) return;
    if (!shouldPersist(matchedLocation)) return;

    try {
      await _prefs.setString(RestorationKeys.lastRoute, matchedLocation);
      await _prefs.setString(
        RestorationKeys.lastQueryJson,
        jsonEncode(queryParameters),
      );
      await _prefs.setString(
        RestorationKeys.lastPathParamsJson,
        jsonEncode(pathParameters),
      );
      await _prefs.setInt(
        RestorationKeys.lastActiveTs,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e, st) {
      debugPrint('RouteRestorationService.persist failed: $e\n$st');
    }
  }

  /// Reads the persisted location if [kRestorationTtl] has not expired.
  RestoredLocation? readRestorable({DateTime? now}) {
    if (!kRestorationEnabled) return null;

    final route = _prefs.getString(RestorationKeys.lastRoute);
    final ts = _prefs.getInt(RestorationKeys.lastActiveTs);
    if (route == null || route.isEmpty || ts == null) return null;

    final nowMs = (now ?? DateTime.now()).millisecondsSinceEpoch;
    if (nowMs - ts > kRestorationTtl.inMilliseconds) {
      return null;
    }

    Map<String, String> query = const {};
    Map<String, String> pathParams = const {};
    try {
      final qRaw = _prefs.getString(RestorationKeys.lastQueryJson);
      if (qRaw != null && qRaw.isNotEmpty) {
        query = Map<String, String>.from(
          (jsonDecode(qRaw) as Map).map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          ),
        );
      }
      final pRaw = _prefs.getString(RestorationKeys.lastPathParamsJson);
      if (pRaw != null && pRaw.isNotEmpty) {
        pathParams = Map<String, String>.from(
          (jsonDecode(pRaw) as Map).map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          ),
        );
      }
    } catch (e) {
      debugPrint('RouteRestorationService.readRestorable parse failed: $e');
      clearAll();
      return null;
    }

    return RestoredLocation(
      location: route,
      query: query,
      pathParams: pathParams,
      timestampMs: ts,
    );
  }

  /// Stamp `lastActiveTs` without touching the route — called when the app
  /// is paused so a quick foreground does not pick up a stale write.
  Future<void> stampLastActive() async {
    if (!kRestorationEnabled) return;
    await _prefs.setInt(
      RestorationKeys.lastActiveTs,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Wipes every restoration key. Safe to call on logout / TTL expiry.
  Future<void> clearAll() async {
    for (final key in RestorationKeys.allKeys) {
      await _prefs.remove(key);
    }
  }

  void _migrateSchema() {
    final stored = _prefs.getInt(RestorationKeys.schemaVersion) ?? 0;
    if (stored != RestorationKeys.currentSchemaVersion) {
      for (final key in RestorationKeys.allKeys) {
        _prefs.remove(key);
      }
      _prefs.setInt(
        RestorationKeys.schemaVersion,
        RestorationKeys.currentSchemaVersion,
      );
    }
  }
}

@immutable
class RestoredLocation {
  const RestoredLocation({
    required this.location,
    required this.query,
    required this.pathParams,
    required this.timestampMs,
  });

  final String location;
  final Map<String, String> query;
  final Map<String, String> pathParams;
  final int timestampMs;

  /// Reconstructs the full URI string with query parameters.
  String toUri() {
    if (query.isEmpty) return location;
    final qs = query.entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return '$location?$qs';
  }
}
