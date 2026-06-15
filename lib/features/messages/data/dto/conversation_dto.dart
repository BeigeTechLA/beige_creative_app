import '../../domain/entities/conversation.dart';

class ConversationDto {
  /// Canonical dummy-fixture shape (camelCase). Used by `MessagesDummySource`.
  static Conversation fromJson(Map<String, dynamic> json) {
    final last = json['lastMessage'] as Map<String, dynamic>?;
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      lastMessage: last == null
          ? null
          : ConversationPreview(
              preview: last['preview'] as String,
              sentAt: DateTime.parse(last['sentAt'] as String).toLocal(),
              fromMe: last['fromMe'] as bool,
            ),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isOnline: (json['isOnline'] as bool?) ?? false,
      linkedShootId: json['linkedShootId'] as String?,
      participantIds: ((json['participants'] as List?) ?? const [])
          .cast<String>(),
    );
  }

  /// REST shape from `GET /external-chat/rooms`. Assumed snake_case fields —
  /// confirm with backend (plan §3.1, §11 Q1).
  ///
  /// `currentUserId` drives `lastMessage.fromMe`.
  static Conversation fromRestJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final last = (json['last_message'] ?? json['lastMessage']) as Map<String, dynamic>?;
    final participantsRaw = (json['participants'] as List?) ?? const [];
    final participantIds = participantsRaw.map((p) {
      if (p is String) return p;
      if (p is Map) return (p['id'] ?? p['_id'] ?? '').toString();
      return '';
    }).where((s) => s.isNotEmpty).toList(growable: false);

    return Conversation(
      id: (json['id'] ?? json['_id']).toString(),
      title: (json['room_name'] ?? json['roomName'] ?? json['title'] ?? '') as String,
      avatarUrl: (json['avatar_url'] ?? json['avatarUrl']) as String?,
      lastMessage: last == null ? null : _previewFromRest(last, currentUserId: currentUserId),
      unreadCount: ((json['unread_count'] ?? json['unreadCount'] ?? 0) as num).toInt(),
      isOnline: (json['is_online'] ?? json['isOnline'] ?? false) as bool,
      linkedShootId: (json['linked_booking_id'] ??
          json['linkedBookingId'] ??
          json['linked_shoot_id']) as String?,
      participantIds: participantIds,
    );
  }

  static ConversationPreview _previewFromRest(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final sentBy = (json['sent_by'] ?? json['senderId'] ?? '').toString();
    return ConversationPreview(
      preview: (json['message'] ?? json['preview'] ?? '') as String,
      sentAt: DateTime.parse(
        (json['sent_at'] ?? json['sentAt'] ?? json['createdAt']).toString(),
      ).toLocal(),
      fromMe: sentBy == currentUserId,
    );
  }
}
