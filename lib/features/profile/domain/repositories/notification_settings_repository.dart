import '../../data/models/notification_settings_dto.dart';

abstract class NotificationSettingsRepository {
  /// Fetches notification settings flags (`GET /notification-preferences/settings`).
  Future<Map<String, dynamic>> getNotificationSettingsFlags();

  /// Fetches push notifications preferences.
  Future<Map<String, dynamic>> getPushNotificationsPreferences();

  /// Updates topic and push preferences (`PATCH /push-notifications/preferences`).
  Future<void> updateNotificationPreferences(
    NotificationSettingsRequestDto dto,
  );

  /// Fetches email notifications preferences.
  Future<Map<String, dynamic>> getEmailNotificationsPreferences();

  /// Updates email notification preferences (`PATCH /notification-preferences/email`).
  Future<void> updateEmailNotificationPreferences(
    Map<String, dynamic> payload,
  );
}
