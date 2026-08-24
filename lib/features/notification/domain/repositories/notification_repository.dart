import 'package:beige_creative_app/features/notification/domain/models/notification_item.dart';

/// Abstract contract for push notification operations.
abstract class NotificationRepository {
  /// Saves the device FCM token on the server (`POST /push-notifications/tokens`).
  Future<void> saveFcmToken({
    required String fcmToken,
    required String sessionId,
    String? deviceType,
  });

  /// Removes the device FCM token on logout (`DELETE /push-notifications/tokens`).
  Future<void> removeFcmToken({
    required String sessionId,
  });

  /// Fetches the list of notifications
  Future<List<NotificationItem>> getNotifications({int page = 1, int limit = 20});
}
