import 'package:flutter/foundation.dart';

/// Immutable domain entity representing a user notification.
@immutable
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.type,
    this.senderName,
    this.avatarUrl,
    this.actionLabel,
    this.category,
  });

  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? type;
  final String? senderName;
  final String? avatarUrl;
  final String? actionLabel;
  final String? category;

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    String? type,
    String? senderName,
    String? avatarUrl,
    String? actionLabel,
    String? category,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      senderName: senderName ?? this.senderName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      actionLabel: actionLabel ?? this.actionLabel,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          message == other.message &&
          createdAt == other.createdAt &&
          isRead == other.isRead &&
          type == other.type &&
          senderName == other.senderName &&
          avatarUrl == other.avatarUrl &&
          actionLabel == other.actionLabel &&
          category == other.category;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      message.hashCode ^
      createdAt.hashCode ^
      isRead.hashCode ^
      type.hashCode ^
      senderName.hashCode ^
      avatarUrl.hashCode ^
      actionLabel.hashCode ^
      category.hashCode;
}
