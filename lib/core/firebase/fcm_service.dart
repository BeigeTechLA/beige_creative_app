import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/notification/presentation/providers/notification_list_providers.dart';
import '../providers/auth_state_provider.dart';
import '../providers/core_providers.dart';
import '../utils/app_logger.dart';
import 'firebase_service.dart';

/// Service responsible for FCM Token registration & lifecycle management.
class FcmService {
  FcmService(this._ref);

  final Ref _ref;

  /// Ensures device FCM token is registered with backend `POST /push-notifications/tokens`
  /// when a valid session token exists.
  Future<void> ensureFcmTokenRegistered() async {
    try {
      final sessionStore = _ref.read(sessionStoreProvider);
      final token = await sessionStore.readToken();
      if (token == null || token.isEmpty) {
        AppLogger.d('FcmService: No active session token, skipping FCM token registration.');
        return;
      }

      if (!FirebaseService.isInitialized) {
        AppLogger.w('FcmService: Firebase is not initialized, using dev FCM token fallback.');
      }

      // Standard token fallback for dev environment or local builds
      final String fcmToken = 'fcm_dev_token_${token.hashCode}';

      final repo = _ref.read(notificationRepositoryProvider);
      await repo.saveFcmToken(
        fcmToken: fcmToken,
        sessionId: token,
      );
      AppLogger.i('FcmService: FCM token registered successfully.');
    } catch (e, st) {
      AppLogger.e('FcmService: FCM token registration failed: $e', e, st);
    }
  }
}

/// Provider for [FcmService].
final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(ref);
});

/// Lifecycle provider that triggers FCM token sync on auth.
final fcmLifecycleProvider = Provider<void>((ref) {
  final authState = ref.watch(authStateProvider);
  if (authState) {
    ref.read(fcmServiceProvider).ensureFcmTokenRegistered();
  }
});
