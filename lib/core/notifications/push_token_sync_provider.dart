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

  // Listen to auth state changes to trigger manual token sync on login
  ref.listen<bool>(authStateProvider, (previous, next) async {
    if (next && previous != next) {
      // User just logged in

      final token = pushService.fcmToken;
      if (token != null && token.isNotEmpty) {
        final sessionStore = ref.read(sessionStoreProvider);
        final sessionId = await sessionStore.getAppSessionId();
        if (sessionId.isNotEmpty) {
          pushService.rememberSession(sessionId);
          await ref.read(notificationRepositoryProvider).saveFcmToken(
            fcmToken: token,
            sessionId: sessionId,
          );
        }
      }
    } else if (!next && previous == true) {
      // User just logged out, token deletion is handled by auth_state_provider during logout flow
      pushService.clearSession();
    }
  }, fireImmediately: true);
});
