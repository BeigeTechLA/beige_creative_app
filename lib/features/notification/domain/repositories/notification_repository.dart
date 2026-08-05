import '../../data/models/notification_settings_dto.dart';

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

  /// Updates topic and push preferences (`PATCH /push-notifications/preferences`).
  Future<void> updateNotificationPreferences(
    NotificationSettingsRequestDto dto,
  );
}
