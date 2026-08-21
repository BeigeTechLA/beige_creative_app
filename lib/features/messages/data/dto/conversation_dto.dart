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
    // Prefer canonical `participants` array (same shape as details endpoint's
    // `participants.items`) so list count matches the details screen. Falls
    // back to `cp_ids + manager_ids` for legacy payloads. Deduped by id.
    final canonical = _readParticipantsFromCanonical(json['participants']);
    final List<String> participantIds;
    if (canonical.isNotEmpty) {
      participantIds = canonical;
    } else {
      final cpIds = _readParticipants(json['cp_ids']);
      final managerIds = _readParticipants(json['manager_ids']);
      final productionIds = _readParticipants(json['production_ids']);
      final clientId = _readParticipantIdFromObject(json['client_snapshot']);
      final seen = <String>{};
      participantIds = [
        for (final id in [
          ...cpIds,
          ...managerIds,
          ...productionIds,
          ?clientId,
        ])
          if (seen.add(id)) id,
      ];
    }

    final unreadMap = json['unread_counts'];
    int unread = 0;
    if (unreadMap is Map && currentUserId.isNotEmpty) {
      final v = unreadMap[currentUserId];
      if (v is num) unread = v.toInt();
    }

    final rawUpdated = json['updatedAt'] ?? json['updated_at'];
    final updatedAt = rawUpdated == null
        ? null
        : DateTime.tryParse(rawUpdated.toString())?.toLocal();
    return Conversation(
      id: (json['id'] ?? json['_id'] ?? json['chat_id']).toString(),
      title: (json['display_name'] ?? json['name'] ?? '') as String,
      avatarUrl: _firstAvatar(json['cp_ids']) ??
          _firstAvatar(json['manager_ids']) ??
          _firstAvatar(json['production_ids']) ??
          _avatarFromObject(json['client_snapshot']),
      lastMessage: _previewFromRoom(json),
      unreadCount: unread,
      isOnline: false,
      linkedShootId: (json['external_order_ref'] ?? json['order_id']) as String?,
      participantIds: participantIds,
      updatedAt: updatedAt,
    );
  }

  static String? _readParticipantIdFromObject(Object? raw) {
    if (raw is Map) {
      final id = (raw['id'] ?? raw['_id'] ?? '').toString();
      if (id.isNotEmpty) return id;
    }
    return null;
  }

  static List<String> _readParticipants(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((m) => (m['id'] ?? m['_id'] ?? '').toString())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }

  /// Reads canonical `participants` from the rooms payload. Accepts either
  /// a bare list of participant maps or a `{ items: [...] }` envelope
  /// (mirrors the details endpoint's `participants.items` shape). Deduped
  /// by id to keep count aligned with the details screen.
  static List<String> _readParticipantsFromCanonical(Object? raw) {
    final List list;
    if (raw is List) {
      list = raw;
    } else if (raw is Map && raw['items'] is List) {
      list = raw['items'] as List;
    } else {
      return const [];
    }
    final seen = <String>{};
    final ids = <String>[];
    for (final item in list) {
      if (item is Map) {
        final id = (item['id'] ?? item['_id'] ?? '').toString();
        if (id.isNotEmpty && seen.add(id)) ids.add(id);
      } else if (item is String && item.isNotEmpty && seen.add(item)) {
        ids.add(item);
      }
    }
    return List.unmodifiable(ids);
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

  static String? _avatarFromObject(Object? raw) {
    if (raw is Map) {
      final v = raw['profileImage'] ?? raw['profile_image'] ?? raw['avatar_url'];
      if (v is String && v.isNotEmpty) return v;
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
