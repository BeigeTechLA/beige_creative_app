import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/notification/presentation/providers/notification_list_providers.dart';
import '../providers/auth_state_provider.dart';
import '../providers/core_providers.dart';
import '../utils/app_logger.dart';
import 'push_notification_service.dart';

final pushTokenSyncProvider = Provider<void>((ref) {
  final pushService = PushNotificationService.instance;

  // Wire up the token refresh callback directly to our backend sync logic
  pushService.onTokenRefreshed = (String token) async {
    try {
      final isAuth = ref.read(authStateProvider);
      if (!isAuth) return;

      final sessionStore = ref.read(sessionStoreProvider);
      final sessionId = await sessionStore.getAppSessionId();
      if (sessionId.isNotEmpty) {
        pushService.rememberSession(sessionId);
        await ref.read(notificationRepositoryProvider).saveFcmToken(
          fcmToken: token,
          sessionId: sessionId,
        );
      }
    } catch (e, st) {
      AppLogger.e('pushTokenSyncProvider: Failed to sync FCM token', e, st);
    }
  };

  // Re-push cached token after provider wires callback to catch any pre-login fetches
  if (pushService.fcmToken != null && pushService.fcmToken!.isNotEmpty && ref.read(authStateProvider)) {
    pushService.onTokenRefreshed!(pushService.fcmToken!);
  }

  // Listen to auth state changes to trigger manual token sync on login.
  //
  // Logout/expiry token removal is intentionally NOT handled here: it lives in
  // `AuthStateNotifier._endSession`, which deregisters the token BEFORE clearing
  // the session so the DELETE still carries a valid Bearer token. Doing it here
  // would race the session clear (token stripped → 401 → token orphaned) and
  // double-fire the DELETE.
  ref.listen<bool>(authStateProvider, (previous, next) async {
    if (next && previous != next) {
      // User just logged in
      try {
        final token = await pushService.ensureToken();
        if (token != null && token.isNotEmpty) {
          if (pushService.onTokenRefreshed != null) {
            await pushService.onTokenRefreshed!(token);
          }
        }
      } catch (e, st) {
        AppLogger.e('pushTokenSyncProvider: Error fetching/syncing token on login', e, st);
      }
    }
  }, fireImmediately: true);
});
