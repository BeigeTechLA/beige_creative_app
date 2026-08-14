import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_logger.dart';

class NotificationSettingsRemoteSource {
  NotificationSettingsRemoteSource(this._client);

  final DioClient _client;

  /// Fetches notification settings flags (`GET /notification-preferences/settings?session_id=...`).
  Future<Map<String, dynamic>> getNotificationSettingsFlags() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.notifications_settings_flags);
      AppLogger.i('[NOTIFICATION SETTINGS API] GET /${ApiEndpoints.notifications_settings_flags} - Response: ${response.data}');
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      AppLogger.e('[NOTIFICATION SETTINGS API] GET /${ApiEndpoints.notifications_settings_flags} - Error: $e');
      rethrow;
    }
  }

  /// Fetches push notifications preferences (`GET /push-notifications/preferences`).
  Future<Map<String, dynamic>> getPushNotificationsPreferences() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.push_notifications_preferences);
      AppLogger.i('[NOTIFICATION SETTINGS API] GET /${ApiEndpoints.push_notifications_preferences} - Response: ${response.data}');
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      AppLogger.e('[NOTIFICATION SETTINGS API] GET /${ApiEndpoints.push_notifications_preferences} - Error: $e');
      rethrow;
    }
  }

  /// Updates topic and push preferences (`PATCH /push-notifications/preferences`).
  Future<void> updateNotificationPreferences(Map<String, dynamic> body) async {
    try {
      await _client.dio.patch(ApiEndpoints.pushPreferences, data: body);
      AppLogger.i('[NOTIFICATION SETTINGS API] PATCH /${ApiEndpoints.pushPreferences} - Success');
    } catch (e) {
      AppLogger.e('[NOTIFICATION SETTINGS API] PATCH /${ApiEndpoints.pushPreferences} - Error: $e');
      rethrow;
    }
  }

  /// Fetches email notifications preferences.
  Future<Map<String, dynamic>> getEmailNotificationsPreferences() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.email_notifications_preferences);
      AppLogger.i('[NOTIFICATION SETTINGS API] GET /${ApiEndpoints.email_notifications_preferences} - Response: ${response.data}');
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      AppLogger.e('[NOTIFICATION SETTINGS API] GET /${ApiEndpoints.email_notifications_preferences} - Error: $e');
      rethrow;
    }
  }

  /// Updates email notification preferences.
  Future<void> updateEmailNotificationPreferences(Map<String, dynamic> body) async {
    try {
      await _client.dio.patch(ApiEndpoints.emailPreferences, data: body);
      AppLogger.i('[NOTIFICATION SETTINGS API] PATCH /${ApiEndpoints.emailPreferences} - Success');
    } catch (e) {
      AppLogger.e('[NOTIFICATION SETTINGS API] PATCH /${ApiEndpoints.emailPreferences} - Error: $e');
      rethrow;
    }
  }
}
