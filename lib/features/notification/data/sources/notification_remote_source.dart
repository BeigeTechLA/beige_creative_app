import 'dart:io' show Platform;

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_logger.dart';

/// REST remote data source for Push Notification endpoints.
class NotificationRemoteSource {
  NotificationRemoteSource(this._client);

  // ignore: unused_field
  final DioClient _client;

  /// Updates topic and push preferences (`PATCH /push-notifications/preferences`).
  Future<void> updateNotificationPreferences(Map<String, dynamic> body) async {
    AppLogger.i('[NOTIFICATION API] PATCH /${ApiEndpoints.pushPreferences} - Body (Local mock): $body');
  }

  /// Registers/saves the device FCM token (`POST /push-notifications/tokens`).
  Future<void> saveFcmToken({
    required String fcmToken,
    required String sessionId,
    String? deviceType,
  }) async {
    final effectiveDeviceType = deviceType ?? (Platform.isIOS ? 'iOS' : 'android');
    final payload = {
      'fcm_token': fcmToken,
      'session_id': sessionId,
      'device_type': effectiveDeviceType,
    };
    AppLogger.i('[NOTIFICATION API] POST /${ApiEndpoints.pushTokens} - Payload (Local mock): $payload');
  }

  /// Removes the device FCM token on logout (`DELETE /push-notifications/tokens`).
  Future<void> removeFcmToken({
    required String sessionId,
  }) async {
    final payload = {
      'session_id': sessionId,
    };
    AppLogger.i('[NOTIFICATION API] DELETE /${ApiEndpoints.pushTokens} - Payload (Local mock): $payload');
  }
}
