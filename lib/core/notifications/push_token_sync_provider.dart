import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/notification/presentation/providers/notification_list_providers.dart';
import '../providers/auth_state_provider.dart';
import '../providers/core_providers.dart';
import 'push_notification_service.dart';

final pushTokenSyncProvider = Provider<void>((ref) {
  final pushService = PushNotificationService.instance;
  
  // Wire up the token refresh callback directly to our backend sync logic
  pushService.onTokenRefreshed = (String token) async {
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
  };

  // T2.1: Re-push cached token after provider wires callback to catch any pre-login fetches
  if (pushService.fcmToken != null && pushService.fcmToken!.isNotEmpty && ref.read(authStateProvider)) {
    pushService.onTokenRefreshed!(pushService.fcmToken!);
  }

  // Listen to auth state changes to trigger manual token sync on login
  ref.listen<bool>(authStateProvider, (previous, next) async {
    if (next && previous != next) {
      // User just logged in

      final token = await pushService.ensureToken();
      if (token != null && token.isNotEmpty) {
        if (pushService.onTokenRefreshed != null) {
          pushService.onTokenRefreshed!(token);
        }
      }
    } else if (!next && previous == true) {
      // User just logged out, remove token from backend
      final lastSession = pushService.lastSessionId;
      if (lastSession != null && lastSession.isNotEmpty) {
        await ref.read(notificationRepositoryProvider).removeFcmToken(sessionId: lastSession);
      }
      pushService.clearSession();
    }
  }, fireImmediately: true);
});
