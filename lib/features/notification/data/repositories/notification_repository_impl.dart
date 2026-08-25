import '../../domain/repositories/notification_repository.dart';
import '../../domain/models/notification_item.dart';
import 'package:beige_creative_app/features/notification/domain/models/notification_counts.dart';
import '../models/notification_dto.dart';
import '../sources/notification_remote_source.dart';

/// Concrete implementation of [NotificationRepository].
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remoteSource);

  final NotificationRemoteSource _remoteSource;

  @override
  Future<void> removeFcmToken({
    required String sessionId,
  }) async {
    await _remoteSource.removeFcmToken(
      sessionId: sessionId,
    );
  }

  @override
  Future<void> saveFcmToken({required String fcmToken, required String sessionId, String? deviceType}) async {
    await _remoteSource.saveFcmToken(
      fcmToken: fcmToken,
      sessionId: sessionId,
    );
  }

  @override
  Future<List<NotificationItem>> getNotifications({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
    String? category,
  }) async {
    final response = await _remoteSource.getNotifications(
      page: page,
      limit: limit,
      status: status,
      search: search,
      category: category,
    );
    final dto = NotificationListResponseDto.fromJson(response);
    return dto.data;
  }

  @override
  Future<NotificationCounts> getNotificationCounts() async {
    final response = await _remoteSource.getNotificationCounts();
    if (response['data'] != null) {
      return NotificationCounts.fromJson(response['data'] as Map<String, dynamic>);
    }
    return const NotificationCounts();
  }

  @override
  Future<NotificationItem> getNotificationDetails(String id) async {
    final response = await _remoteSource.getNotificationDetails(id);
    final dto = NotificationItemDto.fromJson(response['data']);
    return dto.toDomain();
  }

  @override
  Future<void> markAsRead(String id) async {
    await _remoteSource.markAsRead(id);
  }

  @override
  Future<void> markAsUnread(String id) async {
    await _remoteSource.markAsUnread(id);
  }

  @override
  Future<void> markAllAsRead() async {
    await _remoteSource.markAllAsRead();
  }

  @override
  Future<void> deleteNotification(String id) async {
    await _remoteSource.deleteNotification(id);
  }
}
