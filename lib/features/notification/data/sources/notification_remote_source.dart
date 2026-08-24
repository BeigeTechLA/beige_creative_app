import 'dart:io' show Platform;

import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_logger.dart';

/// REST remote data source for Push Notification endpoints.
class NotificationRemoteSource {
  NotificationRemoteSource(this._client);

  final DioClient _client;

  /// Removes the device FCM token on logout (`DELETE /push-notifications/tokens`).
  Future<void> removeFcmToken({
    required String sessionId,
  }) async {
    final payload = {
      'session_id': sessionId,
    };
    await _client.dio.delete(
      ApiEndpoints.pushTokens,
      data: payload,
    );
    AppLogger.i('[NOTIFICATION API] DELETE /${ApiEndpoints.pushTokens} - Removed token for session: $sessionId');
  }

  /// Registers the device FCM token (`POST /push-notifications/tokens`).
  Future<void> saveFcmToken({
    required String fcmToken,
    required String sessionId,
  }) async {
    final payload = {
      'fcm_token': fcmToken,
      'session_id': sessionId,
    };
    await _client.dio.post(
      ApiEndpoints.pushTokens,
      data: payload,
      options: Options(
        headers: {
          'device_type': Platform.isIOS ? 'ios' : 'android',
        },
      ),
    );
    AppLogger.i('[NOTIFICATION API] POST /${ApiEndpoints.pushTokens} - Registered token for session: $sessionId');
  }

  /// Fetches the list of notifications (`GET /app-notifications`)
  Future<Map<String, dynamic>> getNotifications({int page = 1, int limit = 20}) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.notifications,
       /* queryParameters: {
          'page': page,
          'limit': limit,
        },*/
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      AppLogger.e('[NOTIFICATION API] GET /${ApiEndpoints.notifications} - Error: $e');
      rethrow;
    }
  }
}
