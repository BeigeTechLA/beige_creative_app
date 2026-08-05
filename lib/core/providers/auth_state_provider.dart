import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/fcm_service.dart';
import '../firebase/telemetry_client.dart';
import '../restoration/restoration_providers.dart';
import '../../features/notification/presentation/providers/notification_list_providers.dart';
import 'core_providers.dart';

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

  /// Call after a successful login flow has already written the session.
  /// Flips the auth state so the router redirect re-evaluates.
  void markLoggedIn() {
    state = true;
    try {
      ref.read(fcmServiceProvider).ensureFcmTokenRegistered();
    } catch (_) {}
  }

  /// Clears the session and flips auth state to `false`. Caller is
  /// responsible for `context.goNamed(Routes.login.name)`; the redirect will
  /// also enforce the bounce if anything resurrects the authed tree.
  Future<void> logout() async {
    try {
      final session = ref.read(sessionStoreProvider);
      final token = await session.readToken();
      if (token != null && token.isNotEmpty) {
        await ref.read(notificationRepositoryProvider).removeFcmToken(sessionId: token);
      }
    } catch (e) {
      // Best-effort push token removal on logout
    }

    await ref.read(sessionStoreProvider).clearSession();
    await ref.read(routeRestorationServiceProvider).clearAll();
    await ref.read(draftStoreProvider).clearAll();
    // Clear telemetry identity + emit `logout`. Best-effort — never fail
    // logout on a wrapper error.
    try {
      await ref
          .read(telemetryClientProvider)
          .clearUserIdentity(emitLogoutEvent: true);
    } catch (_) {
      // Swallow — logout must complete regardless.
    }
    state = false;
  }
}

final authStateProvider = NotifierProvider<AuthStateNotifier, bool>(
  AuthStateNotifier.new,
);
