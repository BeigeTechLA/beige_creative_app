import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/session/session_store.dart';

class NotificationSettingsRemoteSource {
  NotificationSettingsRemoteSource(this._client, this._sessionStore);

  final DioClient _client;
  final SessionStore _sessionStore;

  /// Fetches notification settings flags (`GET /notification-preferences/settings?session_id=...`).
  Future<Map<String, dynamic>> getNotificationSettingsFlags() async {
    try {
      final sessionId = await _sessionStore.getAppSessionId();
      final endpoint = ApiEndpoints.notificationsSettingsFlags(sessionId);
      final response = await _client.dio.get(endpoint);
      AppLogger.i('[NOTIFICATION SETTINGS API] GET /$endpoint - Response: ${response.data}');
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      AppLogger.e('[NOTIFICATION SETTINGS API] GET /notificationsSettingsFlags - Error: $e');
      rethrow;
    }
  }

  /// Fetches push notifications preferences (`GET /push-notifications/preferences`).
  Future<Map<String, dynamic>> getPushNotificationsPreferences() async {
    try {
      final sessionId = await _sessionStore.getAppSessionId();
      final endpoint = ApiEndpoints.pushNotificationsPreferences(sessionId);
      final response = await _client.dio.get(endpoint);
      AppLogger.i('[NOTIFICATION SETTINGS API] GET /$endpoint - Response: ${response.data}');
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      AppLogger.e('[NOTIFICATION SETTINGS API] GET /pushNotificationsPreferences - Error: $e');
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
      final sessionId = await _sessionStore.getAppSessionId();
      final endpoint = ApiEndpoints.emailNotificationsPreferences(sessionId);
      final response = await _client.dio.get(endpoint);
      AppLogger.i('[NOTIFICATION SETTINGS API] GET /$endpoint - Response: ${response.data}');
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      AppLogger.e('[NOTIFICATION SETTINGS API] GET /emailNotificationsPreferences - Error: $e');
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
