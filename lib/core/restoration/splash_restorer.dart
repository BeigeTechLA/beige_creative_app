import 'package:flutter/foundation.dart';

import '../../app/routes.dart';

/// Pure decision function for whether the splash screen should redirect the
/// user to a persisted route on cold start.
///
/// Kept pure so every branch is trivial to unit-test.
@immutable
class SplashRestorer {
  const SplashRestorer();

  /// Returns `true` when a stored route should be applied.
  ///
  /// Logic:
  /// - feature flag must be on
  /// - user must be logged in (logged-out users always go through splash gate)
  /// - a non-empty persisted route exists
  /// - persisted route is not one we explicitly forbid (defence in depth —
  ///   mirrors `RouteRestorationService` skip set)
  bool shouldRestore({
    required bool isEnabled,
    required bool isLoggedIn,
    required String? persistedRoute,
  }) {
    if (!isEnabled) return false;
    if (!isLoggedIn) return false;
    if (persistedRoute == null || persistedRoute.isEmpty) return false;
    if (Routes.publicPaths.contains(persistedRoute)) return false;
    if (_forbidden.contains(persistedRoute)) return false;
    return true;
  }

  /// Routes we never restore to even if they somehow ended up persisted.
  /// Mirrors `RouteRestorationService._extraSkipPaths`.
  static const Set<String> _forbidden = {
    '/profile-otp',
    '/new-password',
    '/change-password',
    '/profile-password-success',
    '/delete-account-otp',
    '/delete-account-success',
  };
}
