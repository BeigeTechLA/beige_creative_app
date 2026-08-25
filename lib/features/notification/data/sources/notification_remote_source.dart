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
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
    String? category,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category.isNotEmpty) queryParams['category'] = category;

      final response = await _client.dio.get(
        ApiEndpoints.notifications,
        queryParameters: queryParams,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      AppLogger.e('[NOTIFICATION API] GET /${ApiEndpoints.notifications} - Error: $e');
      rethrow;
    }
  }

  /// Fetches unread notification count (`GET /app-notifications/counts`)
  Future<Map<String, dynamic>> getNotificationCounts() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.notificationCounts);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      AppLogger.e('[NOTIFICATION API] GET /${ApiEndpoints.notificationCounts} - Error: $e');
      rethrow;
    }
  }

  /// Fetches details of a single notification (`GET /app-notifications/{id}`)
  Future<Map<String, dynamic>> getNotificationDetails(String id) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.notificationDetails(id));
      return response.data as Map<String, dynamic>;
    } catch (e) {
      AppLogger.e('[NOTIFICATION API] GET /${ApiEndpoints.notificationDetails(id)} - Error: $e');
      rethrow;
    }
  }

  /// Marks a single notification as read (`PATCH /app-notifications/{id}/read`)
  Future<void> markAsRead(String id) async {
    try {
      await _client.dio.patch(ApiEndpoints.notificationRead(id));
    } catch (e) {
      AppLogger.e('[NOTIFICATION API] PATCH /${ApiEndpoints.notificationRead(id)} - Error: $e');
      rethrow;
    }
  }

  /// Marks a single notification as unread (`PATCH /app-notifications/{id}/unread`)
  Future<void> markAsUnread(String id) async {
    try {
      await _client.dio.patch(ApiEndpoints.notificationUnread(id));
    } catch (e) {
      AppLogger.e('[NOTIFICATION API] PATCH /${ApiEndpoints.notificationUnread(id)} - Error: $e');
      rethrow;
    }
  }

  /// Marks all notifications as read (`PATCH /app-notifications/read-all`)
  Future<void> markAllAsRead() async {
    try {
      await _client.dio.patch(ApiEndpoints.notificationsReadAll);
    } catch (e) {
      AppLogger.e('[NOTIFICATION API] PATCH /${ApiEndpoints.notificationsReadAll} - Error: $e');
      rethrow;
    }
  }

  /// Deletes a notification (`DELETE /app-notifications/{id}`)
  Future<void> deleteNotification(String id) async {
    try {
      await _client.dio.delete(ApiEndpoints.notificationDelete(id));
    } catch (e) {
      AppLogger.e('[NOTIFICATION API] DELETE /${ApiEndpoints.notificationDelete(id)} - Error: $e');
      rethrow;
    }
  }
}
