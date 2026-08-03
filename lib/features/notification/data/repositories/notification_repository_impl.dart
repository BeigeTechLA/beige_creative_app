import '../../domain/models/notification_item.dart';
import '../../domain/repositories/notification_repository.dart';
import '../sources/notification_remote_source.dart';

/// Dio-backed implementation of [NotificationRepository].
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remoteSource);

  final NotificationRemoteSource _remoteSource;

  @override
  Future<List<NotificationItem>> getNotifications() async {
    final rawList = await _remoteSource.fetchNotifications();
    return rawList.map(_mapToDomain).toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    await _remoteSource.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() async {
    await _remoteSource.markAllAsRead();
  }

  NotificationItem _mapToDomain(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at'] ?? json['createdAt'];
    final createdAt = createdAtRaw != null
        ? DateTime.tryParse(createdAtRaw.toString()) ?? DateTime.now()
        : DateTime.now();

    return NotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? json['body']?.toString() ?? '',
      createdAt: createdAt,
      isRead: json['is_read'] ?? json['isRead'] ?? false,
      type: json['type']?.toString(),
    );
  }
}
