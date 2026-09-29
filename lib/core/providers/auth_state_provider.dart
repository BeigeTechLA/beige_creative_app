import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/telemetry_client.dart';
import '../restoration/restoration_providers.dart';
import '../utils/app_logger.dart';
import 'core_providers.dart';
import '../session/temporary_auth_session.dart';

/// Boolean derived from session presence — single source of truth for
/// "is the user logged in?". Router redirect reads it; login/logout flows
/// mutate via [AuthStateNotifier.markLoggedIn] / [AuthStateNotifier.logout].
///
/// `build()` returns the seed from the override. `startApp` overrides with
/// `AuthStateNotifier(initial: PrefsService.isLoggedIn)` so the value is
/// correct from the first router redirect.
class AuthStateNotifier extends Notifier<bool> {
  AuthStateNotifier({this.initial = false});

  final bool initial;

  @override
  bool build() => initial;

  Future<void>? _endingSession;

  /// Call after a successful login flow has already written the session.
  void markLoggedIn() {
    _endingSession = null;
    state = true;
  }

  /// Shared backend session-expiry path. The router observes auth state and returns to Login.
  /// Repeated failures for the same session share one cleanup operation.
  Future<void> expireSession() =>
      _endingSession ??= _endSession(emitLogoutEvent: false);

  /// Explicit user logout uses the same cleanup and records the logout event.
  Future<void> logout() =>
      _endingSession ??= _endSession(emitLogoutEvent: true);

  Future<void> _endSession({required bool emitLogoutEvent}) async {
    // Revoke access immediately, even if storage or telemetry cleanup fails.
    state = false;
    ref.read(temporaryAuthSessionProvider.notifier).clear();
    await _cleanUp(
      'session',
      () => ref.read(sessionStoreProvider).clearSession(),
    );
    ref.invalidate(currentSessionUserProvider);
    await _cleanUp(
      'route restoration',
      () => ref.read(routeRestorationServiceProvider).clearAll(),
    );
    await _cleanUp('drafts', () => ref.read(draftStoreProvider).clearAll());
    await _cleanUp(
      'telemetry',
      () => ref
          .read(telemetryClientProvider)
          .clearUserIdentity(emitLogoutEvent: emitLogoutEvent),
    );
  }

  Future<void> _cleanUp(String label, Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stack) {
      // A cleanup failure must not strand the original API request or prevent
      // the remaining cleanup operations and the router's auth redirect.
      AppLogger.e('Failed to clear $label on session end', error, stack);
    }
  }
}

final authStateProvider = NotifierProvider<AuthStateNotifier, bool>(
  AuthStateNotifier.new,
);
