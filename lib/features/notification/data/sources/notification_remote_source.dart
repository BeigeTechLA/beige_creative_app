import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/exceptions.dart';

/// REST remote data source for Notification endpoints.
class NotificationRemoteSource {
  NotificationRemoteSource(this._client);

  final DioClient _client;

  Dio get _dio => _client.dio;

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DioException catch (e, st) {
      throw ExceptionHandler.mapDioException(e, st);
    }
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() {
    return _guard(() async {
      final response = await _dio.get<dynamic>('/notifications');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List).cast<Map<String, dynamic>>();
      } else if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    });
  }

  Future<void> markAsRead(String id) {
    return _guard(() async {
      await _dio.patch<dynamic>('/notifications/$id/read');
    });
  }

  Future<void> markAllAsRead() {
    return _guard(() async {
      await _dio.patch<dynamic>('/notifications/read-all');
    });
  }

  Future<Map<String, dynamic>> fetchNotificationPreferences() {
    return _guard(() async {
      final response = await _dio.get<dynamic>('/notifications/settings');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      return <String, dynamic>{};
    });
  }

  Future<void> updateNotificationPreferences(Map<String, dynamic> body) {
    return _guard(() async {
      await _dio.patch<dynamic>('/notifications/settings', data: body);
    });
  }
}
