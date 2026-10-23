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

    // Handle { "data": { "items": [...] } } or { "data": { "data": [...] } } structure
    if (rawData is Map<String, dynamic>) {
      if (rawData['items'] != null) {
        rawData = rawData['items'];
      } else if (rawData['data'] != null) {
        rawData = rawData['data'];
      }
    } else if (rawData == null && json['items'] != null) {
      rawData = json['items'];
    }

    final list = (rawData as List?)
            ?.whereType<Map>()
            .map((e) => NotificationItemDto.fromJson(e).toDomain())
            .toList() ??
        [];

    int resolvedTotal = list.length;
    if (json['data'] is Map<String, dynamic>) {
      final mapData = json['data'] as Map<String, dynamic>;
      if (mapData['pagination'] is Map) {
        final total = mapData['pagination']['total'];
        if (total is int) {
          resolvedTotal = total;
        } else if (total is num) {
          resolvedTotal = total.toInt();
        } else if (total is String) {
          resolvedTotal = int.tryParse(total) ?? list.length;
        }
      }
    } else if (json['pagination'] is Map) {
      final total = (json['pagination'] as Map)['total'];
      if (total is int) {
        resolvedTotal = total;
      } else if (total is num) {
        resolvedTotal = total.toInt();
      } else if (total is String) {
        resolvedTotal = int.tryParse(total) ?? list.length;
      }
    } else if (json['total'] != null) {
      final total = json['total'];
      if (total is int) {
        resolvedTotal = total;
      } else if (total is num) {
        resolvedTotal = total.toInt();
      } else if (total is String) {
        resolvedTotal = int.tryParse(total) ?? list.length;
      }
    }

    int resolvedUnread = 0;
    final unreadRaw = json['unread_count'] ??
        json['unreadCount'] ??
        (json['data'] is Map ? (json['data'] as Map)['unread_count'] : null);
    if (unreadRaw is int) {
      resolvedUnread = unreadRaw;
    } else if (unreadRaw is num) {
      resolvedUnread = unreadRaw.toInt();
    } else if (unreadRaw is String) {
      resolvedUnread = int.tryParse(unreadRaw) ?? 0;
    }

    return NotificationListResponseDto(
      data: list,
      totalCount: resolvedTotal,
      unreadCount: resolvedUnread,
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
  final Map<String, dynamic>? payload;

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
    this.payload,
  });

  factory NotificationItemDto.fromJson(dynamic raw) {
    if (raw is! Map) {
      return NotificationItemDto(
        id: '',
        title: 'Notification',
        message: '',
      );
    }
    final json = Map<String, dynamic>.from(raw);
    return NotificationItemDto(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['subject'] ?? 'Notification',
      message: json['message'] ?? json['body'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString())?.toLocal() : null,
      isRead: json['is_read'] == 1 || json['is_read'] == true || json['read_at'] != null || json['status'] == 'read',
      type: json['type']?.toString(),
      senderName: json['sender']?['name']?.toString() ?? json['sender_name']?.toString() ?? (json['payload'] is Map ? json['payload']['sender_name']?.toString() : null),
      avatarUrl: json['sender']?['profile_image_url']?.toString() ?? json['avatar_url']?.toString(),
      actionLabel: json['action_label']?.toString(),
      category: json['category']?.toString(),
      payload: json['payload'] is Map ? Map<String, dynamic>.from(json['payload'] as Map) : null,
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
      payload: payload,
    );
  }
}
