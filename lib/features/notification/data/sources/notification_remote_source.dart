import 'dart:io' show Platform;
import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/exceptions.dart';
import '../../../../core/utils/app_logger.dart';

/// REST remote data source for Push Notification endpoints.
class NotificationRemoteSource {
  NotificationRemoteSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DioException catch (e, st) {
      AppLogger.e('[NOTIFICATION API] Request failed: ${e.message}', e, st);
      throw ExceptionHandler.mapDioException(e, st);
    }
  }

  /// Updates topic and push preferences (`PATCH /push-notifications/preferences`).
  Future<void> updateNotificationPreferences(Map<String, dynamic> body) {
    return _guard(() async {
      AppLogger.i('[NOTIFICATION API] PATCH /${ApiEndpoints.pushPreferences} - Body: $body');
      await _dio.patch<dynamic>(ApiEndpoints.pushPreferences, data: body);
    });
  }

  /// Registers/saves the device FCM token (`POST /push-notifications/tokens`).
  Future<void> saveFcmToken({
    required String fcmToken,
    required String sessionId,
    String? deviceType,
  }) {
    final effectiveDeviceType = deviceType ?? (Platform.isIOS ? 'iOS' : 'android');
    return _guard(() async {
      final payload = {
        'fcm_token': fcmToken,
        'session_id': sessionId,
        'device_type': effectiveDeviceType,
      };
      AppLogger.i('[NOTIFICATION API] POST /${ApiEndpoints.pushTokens} - Payload: $payload');
      await _dio.post<dynamic>(
        ApiEndpoints.pushTokens,
        data: payload,
      );
    });
  }

  /// Removes the device FCM token on logout (`DELETE /push-notifications/tokens`).
  Future<void> removeFcmToken({
    required String sessionId,
  }) {
    return _guard(() async {
      final payload = {
        'session_id': sessionId,
      };
      AppLogger.i('[NOTIFICATION API] DELETE /${ApiEndpoints.pushTokens} - Payload: $payload');
      await _dio.delete<dynamic>(
        ApiEndpoints.pushTokens,
        data: payload,
      );
    });
  }
}
