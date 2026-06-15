import 'package:flutter/foundation.dart';

@immutable
class ConversationPreview {
  final String preview;
  final DateTime sentAt;
  final bool fromMe;

  const ConversationPreview({
    required this.preview,
    required this.sentAt,
    required this.fromMe,
  });

  ConversationPreview copyWith({
    String? preview,
    DateTime? sentAt,
    bool? fromMe,
  }) {
    return ConversationPreview(
      preview: preview ?? this.preview,
      sentAt: sentAt ?? this.sentAt,
      fromMe: fromMe ?? this.fromMe,
    );
  }
}

@immutable
class Conversation {
  final String id;
  final String title;
  final String? avatarUrl;
  final ConversationPreview? lastMessage;
  final int unreadCount;
  final bool isOnline;
  final String? linkedShootId;
  final List<String> participantIds;

  const Conversation({
    required this.id,
    required this.title,
    required this.unreadCount,
    required this.isOnline,
    required this.participantIds,
    this.avatarUrl,
    this.lastMessage,
    this.linkedShootId,
  });

  Conversation copyWith({
    String? id,
    String? title,
    String? avatarUrl,
    ConversationPreview? lastMessage,
    int? unreadCount,
    bool? isOnline,
    String? linkedShootId,
    List<String>? participantIds,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      linkedShootId: linkedShootId ?? this.linkedShootId,
      participantIds: participantIds ?? this.participantIds,
    );
  }
}
