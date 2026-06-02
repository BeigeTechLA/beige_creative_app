import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_events.dart';
import 'analytics_service.dart';
import 'crashlytics_keys.dart';
import 'crashlytics_service.dart';

/// Thin test-seam over the two static Firebase wrappers.
///
/// The notifiers we want to unit-test (auth, profile, shoots, ...) shouldn't
/// import `AnalyticsService` / `CrashlyticsService` directly — those are
/// static singletons that can't be stubbed cleanly. Instead they depend on
/// [TelemetryClient] through [telemetryClientProvider] and tests override the
/// provider with a fake.
///
/// The default implementation just forwards to the existing static services.
/// Keep this surface narrow — add a method only when a real call site needs
/// it, and prefer typed wrappers (e.g. [setUserIdentity], [clearUserIdentity])
/// over raw `setCustomKey` to keep telemetry centralised.
abstract class TelemetryClient {
  /// Sets analytics user id + Crashlytics user identifier + `user_role`
  /// custom key, then emits `login` with the given method. Use on every
  /// authenticated entry point (login success, signup completion).
  Future<void> setUserIdentity({
    required String userId,
    String? userRole,
    String loginMethod = 'password',
  });

  /// Clears analytics user id + Crashlytics user identifier. Use on logout
  /// and on 401 / token-expiry paths. Optionally emits `logout` event when
  /// [emitLogoutEvent] is true (skip on 401 paths where the user didn't
  /// initiate the action).
  Future<void> clearUserIdentity({bool emitLogoutEvent = false});

  /// Pass-through to [AnalyticsService.logEvent]. Prefer named helpers
  /// ([setUserIdentity], [clearUserIdentity], ...) over this when one exists.
  Future<void> logEvent(String name, {Map<String, Object>? parameters});

  /// Pass-through to [CrashlyticsService.recordError]. `fatal: false` is the
  /// expected default for repository-funnel errors.
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  });
}

/// Default implementation backed by the static [AnalyticsService] /
/// [CrashlyticsService] wrappers. Stays static-singleton-friendly at the call
/// site — `ref.read(telemetryClientProvider)` returns the same instance every
/// time and the underlying Firebase calls remain idempotent / no-op when
/// Firebase isn't configured.
class FirebaseTelemetryClient implements TelemetryClient {
  const FirebaseTelemetryClient();

  @override
  Future<void> setUserIdentity({
    required String userId,
    String? userRole,
    String loginMethod = 'password',
  }) async {
    await AnalyticsService.setUserId(userId);
    await CrashlyticsService.setUserIdentifier(userId);
    await CrashlyticsService.setCustomKey(CrashlyticsKeys.userId, userId);
    if (userRole != null && userRole.isNotEmpty) {
      await CrashlyticsService.setCustomKey(
        CrashlyticsKeys.userRole,
        userRole,
      );
    }
    await AnalyticsService.logLogin(method: loginMethod);
  }

  @override
  Future<void> clearUserIdentity({bool emitLogoutEvent = false}) async {
    await AnalyticsService.setUserId(null);
    await CrashlyticsService.setUserIdentifier('');
    if (emitLogoutEvent) {
      await AnalyticsService.logEvent(AnalyticsEvents.logout);
    }
  }

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) =>
      AnalyticsService.logEvent(name, parameters: parameters);

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) =>
      CrashlyticsService.recordError(
        error,
        stack,
        reason: reason,
        fatal: fatal,
      );
}

/// App-wide [TelemetryClient]. Tests override with a fake.
final telemetryClientProvider = Provider<TelemetryClient>(
  (_) => const FirebaseTelemetryClient(),
);
