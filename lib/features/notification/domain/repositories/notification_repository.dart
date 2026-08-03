import '../models/notification_item.dart';

/// Abstract contract for notification data operations.
abstract class NotificationRepository {
  /// Fetches a list of notifications for the signed-in user.
  Future<List<NotificationItem>> getNotifications();

  /// Marks a specific notification as read by ID.
  Future<void> markAsRead(String id);

  /// Marks all notifications as read for the current user.
  Future<void> markAllAsRead();
}
