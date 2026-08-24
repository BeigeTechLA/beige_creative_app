import '../../domain/models/notification_item.dart';

class NotificationListResponseDto {
  final List<NotificationItem> data;
  final int totalCount;
  final int unreadCount;

  NotificationListResponseDto({
    required this.data,
    this.totalCount = 0,
    this.unreadCount = 0,
  });

  factory NotificationListResponseDto.fromJson(Map<String, dynamic> json) {
    dynamic rawData = json['data'];
    
    // Handle { "data": { "items": [...] } } structure from /app-notifications
    if (rawData is Map<String, dynamic>) {
      if (rawData['items'] != null) {
        rawData = rawData['items'];
      } else if (rawData['data'] != null) {
        rawData = rawData['data'];
      }
    }
    
    final list = (rawData as List?)?.map((e) => NotificationItemDto.fromJson(e).toDomain()).toList() ?? [];
    
    return NotificationListResponseDto(
      data: list,
      totalCount: json['data']?['pagination']?['total'] ?? list.length,
      unreadCount: json['unread_count'] ?? 0, // Will implement unread count later if provided
    );
  }
}

class NotificationItemDto {
  final String id;
  final String title;
  final String message;
  final DateTime? createdAt;
  final bool isRead;
  final String? type;
  final String? senderName;
  final String? avatarUrl;
  final String? actionLabel;
  final String? category;

  NotificationItemDto({
    required this.id,
    required this.title,
    required this.message,
    this.createdAt,
    this.isRead = false,
    this.type,
    this.senderName,
    this.avatarUrl,
    this.actionLabel,
    this.category,
  });

  factory NotificationItemDto.fromJson(Map<String, dynamic> json) {
    return NotificationItemDto(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['subject'] ?? 'Notification',
      message: json['message'] ?? json['body'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      isRead: json['is_read'] == 1 || json['is_read'] == true || json['read_at'] != null || json['status'] == 'read',
      type: json['type']?.toString(),
      senderName: json['sender_name']?.toString() ?? (json['payload'] is Map ? json['payload']['sender_name']?.toString() : null),
      avatarUrl: json['avatar_url']?.toString(),
      actionLabel: json['action_label']?.toString(),
      category: json['category']?.toString(),
    );
  }

  NotificationItem toDomain() {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      createdAt: createdAt ?? DateTime.now(),
      isRead: isRead,
      type: type,
      senderName: senderName,
      avatarUrl: avatarUrl,
      actionLabel: actionLabel,
      category: category,
    );
  }
}
