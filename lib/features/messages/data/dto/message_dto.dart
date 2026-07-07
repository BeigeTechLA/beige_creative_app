import '../../domain/entities/message.dart';

class MessageDto {
  /// REST list shape (`GET /external-chat/messages/:roomId`).
  /// snake_case payload. `sent_by` is an expanded user ref with the canonical
  /// numeric `id` (matches session `currentUserId`); flat `sent_by_name`
  /// mirrors `sent_by.name`. File messages add `file_url` / `file_name` /
  /// `file_type` / `file_size` (+ optional `duration_ms` for audio).
  static Message fromRestJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    // `sent_by` is either an expanded user ref `{id, name, email, ...}`
    // (preferred — canonical numeric `id` matches session `currentUserId`)
    // or a bare id string when the backend skips ref expansion.
    final rawSentBy = json['sent_by'];
    final Map<String, dynamic>? sentBy =
        rawSentBy is Map<String, dynamic> ? rawSentBy : null;
    final senderId =
        (sentBy?['id'] ?? (rawSentBy is String ? rawSentBy : '')).toString();
    final fileUrl = json['file_url'] as String?;
    return Message(
      id: json['_id'].toString(),
      senderId: senderId,
      senderName: (json['sent_by_name'] ?? sentBy?['name'] ?? '') as String,
      type: _parseType(json['message_type'] as String?),
      body: json['message'] as String?,
      file: fileUrl == null
          ? null
          : MessageFile(
              url: fileUrl,
              name: (json['file_name'] ?? '') as String,
              mimeType: (json['file_type'] as String?) ?? 'application/octet-stream',
              sizeBytes: ((json['file_size'] ?? 0) as num).toInt(),
              durationMs: (json['duration_ms'] as num?)?.toInt(),
            ),
      sentAt: DateTime.parse(json['createdAt'].toString()).toLocal(),
      isEdited: (json['is_edited'] as bool?) ?? false,
      isDeleted: (json['is_deleted'] as bool?) ?? false,
      replyToId: _extractReplyId(json['reply_to']),
      replyTo: _extractReplyPreview(json['reply_to']),
      deliveryStatus: _restStatus(json, currentUserId: currentUserId, senderId: senderId),
    );
  }

  /// Socket payload shape per `web-chat-socket-reference.md` §"Realtime Message Event".
  /// camelCase, flat `fileUrl` / `fileName` / `fileType`. Always treated as
  /// just-delivered (status = `delivered`) — recipient state is local.
  static Message fromSocketJson(Map<String, dynamic> json) {
    final rawSender = json['senderId'] ?? json['sent_by'];
    final String senderId;
    String? sentByName;
    if (rawSender is Map<String, dynamic>) {
      // Prefer canonical `id` over Mongo `_id` — see REST DTO note above.
      senderId = (rawSender['id'] ??
              rawSender['userId'] ??
              rawSender['user_id'] ??
              rawSender['_id'] ??
              '')
          .toString();
      sentByName = (rawSender['name'] ??
          rawSender['full_name'] ??
          rawSender['fullName']) as String?;
    } else {
      senderId = (rawSender ?? '').toString();
    }
    final fileUrl = json['fileUrl'] as String?;
    final fileType = json['fileType'] as String?;
    return Message(
      id: (json['messageId'] ?? json['_id'] ?? json['id']).toString(),
      senderId: senderId,
      senderName: (json['senderName'] ??
              json['sender_name'] ??
              sentByName ??
              '')
          as String,
      type: _parseType(json['message_type'] as String?),
      body: json['message'] as String?,
      file: fileUrl == null
          ? null
          : MessageFile(
              url: fileUrl,
              name: (json['fileName'] ?? '') as String,
              mimeType: fileType ?? 'application/octet-stream',
              sizeBytes: ((json['fileSize'] ?? 0) as num).toInt(),
              durationMs: (json['durationMs'] as num?)?.toInt(),
            ),
      sentAt: DateTime.parse(
        (json['createdAt'] ?? json['sentAt']).toString(),
      ).toLocal(),
      isEdited: (json['is_edited'] as bool?) ?? false,
      isDeleted: (json['is_deleted'] as bool?) ?? false,
      replyToId: _extractReplyId(json['replyTo'] ?? json['reply_to']),
      replyTo: _extractReplyPreview(json['replyTo'] ?? json['reply_to']),
      deliveryStatus: DeliveryStatus.delivered,
    );
  }

  /// Backend ships `replyTo` either as a bare id string OR an expanded map
  /// `{_id, message, sent_by, ...}`. Cast-to-String fails on the map shape —
  /// pull the id out of both forms.
  static String? _extractReplyId(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return raw.isEmpty ? null : raw;
    if (raw is Map) {
      final id = raw['_id'] ?? raw['id'] ?? raw['messageId'];
      return id?.toString();
    }
    return raw.toString();
  }

  /// Extracts the full quoted-message preview from `replyTo`. Only present
  /// when backend expanded the ref (`{_id, message, sent_by, message_type,
  /// file_name, ...}`); bare-id form returns null and the UI falls back to
  /// `replyToId` alone.
  static MessageReplyPreview? _extractReplyPreview(dynamic raw) {
    if (raw is! Map) return null;
    final id =
        (raw['_id'] ?? raw['id'] ?? raw['messageId'])?.toString();
    if (id == null || id.isEmpty) return null;
    final sentBy = raw['sent_by'];
    String senderId = '';
    String senderName = '';
    if (sentBy is Map) {
      senderId = (sentBy['id'] ??
              sentBy['userId'] ??
              sentBy['user_id'] ??
              sentBy['_id'] ??
              '')
          .toString();
      senderName = (sentBy['name'] ??
              sentBy['full_name'] ??
              sentBy['fullName'] ??
              '')
          .toString();
    } else if (sentBy != null) {
      senderId = sentBy.toString();
    }
    if (senderName.isEmpty) {
      senderName = (raw['sent_by_name'] ?? raw['senderName'] ?? '').toString();
    }
    return MessageReplyPreview(
      id: id,
      senderId: senderId,
      senderName: senderName,
      type: _parseType(raw['message_type'] as String?),
      body: raw['message'] as String?,
      fileName: (raw['file_name'] ?? raw['fileName']) as String?,
    );
  }

  static MessageType _parseType(String? raw) {
    switch (raw) {
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  /// Derives status from REST payload. Honors explicit `status` when shipped;
  /// otherwise outgoing messages reflect recipient read state and incoming
  /// messages are treated as `delivered` (local recipient state).
  static DeliveryStatus _restStatus(
    Map<String, dynamic> json, {
    required String currentUserId,
    required String senderId,
  }) {
    switch ((json['status'] as String?)?.toLowerCase()) {
      case 'sent':
        return DeliveryStatus.sent;
      case 'delivered':
        return DeliveryStatus.delivered;
      case 'read':
        return DeliveryStatus.read;
      case 'failed':
        return DeliveryStatus.failed;
    }
    if (senderId == currentUserId) {
      final readBy = (json['read_by'] as List?)
              ?.map((e) => e.toString())
              .toSet() ??
          const <String>{};
      return readBy.any((id) => id != currentUserId)
          ? DeliveryStatus.read
          : DeliveryStatus.delivered;
    }
    return DeliveryStatus.delivered;
  }
}
