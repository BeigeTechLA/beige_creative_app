import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/telemetry_client.dart';
import '../notifications/push_notification_service.dart';
import '../restoration/restoration_providers.dart';
import '../utils/app_logger.dart';
import 'core_providers.dart';
import 'account_status_provider.dart';
import '../../features/notification/presentation/providers/notification_list_providers.dart';
import '../../features/profile/presentation/providers/delete_account_providers.dart';
import '../session/temporary_auth_session.dart';
import '../../features/profile/presentation/providers/notification_settings_providers.dart';

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
  /// Flips the auth state so the router redirect re-evaluates.
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
    // Invalidate immediately so pending requests cannot repopulate another
    // session's deletion state. The success receipt survives until screen exit.
    ref.invalidate(deletionProvider);
    ref.read(temporaryAuthSessionProvider.notifier).clear();
    ref.invalidate(notificationSettingsProvider);
    // Deregister the FCM token BEFORE clearing the session so the DELETE still
    // carries a valid Bearer token (AuthInterceptor reads the token live at
    // request time). Clearing the session first would strip the header and the
    // backend would reject the removal, leaving the device registered after
    // logout. Guarded so a removal failure never strands the session teardown.
    await _cleanUp('fcm token', () => _removeFcmToken(deleteToken: emitLogoutEvent));
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
      'account status',
      () => ref.read(prefsProvider).remove('account_status'),
    );
    ref.invalidate(accountStatusProvider);
    await _cleanUp(
      'telemetry',
      () => ref
          .read(telemetryClientProvider)
          .clearUserIdentity(emitLogoutEvent: emitLogoutEvent),
    );
  }

  /// Removes the device's FCM token from the backend for the session it was
  /// registered under. Uses the session id remembered in memory by
  /// [PushNotificationService] so it is still available after prefs are wiped.
  /// No-op when no token was ever registered this session.
  ///
  /// [deleteToken] is true only for an explicit user logout: it additionally
  /// invalidates the device token with Firebase so the old token fully dies.
  /// Transient session expiry passes false to avoid token churn.
  Future<void> _removeFcmToken({required bool deleteToken}) async {
    final PushNotificationService pushService;
    try {
      pushService = PushNotificationService.instance;
    } catch (_) {
      // The singleton constructs FirebaseMessaging on first access; in
      // environments without Firebase (unit/widget tests) nothing was ever
      // registered, so there is no token to remove.
      return;
    }
    final lastSession = pushService.lastSessionId;
    if (lastSession == null || lastSession.isEmpty) {
      // Nothing registered on the backend, but still rotate/clear local token
      // state on an explicit logout.
      await pushService.resetToken(deleteFromFirebase: deleteToken);
      return;
    }
    await ref
        .read(notificationRepositoryProvider)
        .removeFcmToken(sessionId: lastSession);
    await pushService.resetToken(deleteFromFirebase: deleteToken);
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
