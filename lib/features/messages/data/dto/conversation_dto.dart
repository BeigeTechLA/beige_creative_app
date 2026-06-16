import '../../domain/entities/conversation.dart';

class ConversationDto {
  /// REST shape from `GET /external-chat/rooms`.
  ///
  /// Real backend shape (observed 2026-06-16):
  /// - `id`: Mongo `_id`
  /// - `chat_id`: human-readable id
  /// - `display_name` / `name`: title (prefer display_name)
  /// - `cp_ids` + `manager_ids`: arrays of participants (id, name, role, profileImage)
  /// - `last_message`: STRING id of last msg (no embedded preview/timestamp)
  /// - `unread_counts`: map { userId: count }
  /// - `order_id` / `external_order_ref`: linked booking
  /// - `updatedAt`: room-level last-activity timestamp
  static Conversation fromRestJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final cpIds = _readParticipants(json['cp_ids']);
    final managerIds = _readParticipants(json['manager_ids']);
    final participantIds = [...cpIds, ...managerIds];

    final unreadMap = json['unread_counts'];
    int unread = 0;
    if (unreadMap is Map && currentUserId.isNotEmpty) {
      final v = unreadMap[currentUserId];
      if (v is num) unread = v.toInt();
    }

    return Conversation(
      id: (json['id'] ?? json['_id'] ?? json['chat_id']).toString(),
      title: (json['display_name'] ?? json['name'] ?? '') as String,
      avatarUrl: _firstAvatar(json['cp_ids']) ?? _firstAvatar(json['manager_ids']),
      lastMessage: _previewFromRoom(json),
      unreadCount: unread,
      isOnline: false,
      linkedShootId: (json['external_order_ref'] ?? json['order_id']) as String?,
      participantIds: participantIds,
    );
  }

  static List<String> _readParticipants(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((m) => (m['id'] ?? m['_id'] ?? '').toString())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }

  static String? _firstAvatar(Object? raw) {
    if (raw is! List) return null;
    for (final item in raw) {
      if (item is Map) {
        final v = item['profileImage'] ?? item['profile_image'] ?? item['avatar_url'];
        if (v is String && v.isNotEmpty) return v;
      }
    }
    return null;
  }

  /// Backend serves `last_message` as a String id only. Without a hydrated
  /// preview/timestamp, show the room as having no preview but stamp `sentAt`
  /// from `updatedAt` so list ordering still works upstream.
  static ConversationPreview? _previewFromRoom(Map<String, dynamic> json) {
    final updatedAt = json['updatedAt'] ?? json['updated_at'];
    if (updatedAt == null) return null;
    return ConversationPreview(
      preview: '',
      sentAt: DateTime.parse(updatedAt.toString()).toLocal(),
      fromMe: false,
    );
  }
}
