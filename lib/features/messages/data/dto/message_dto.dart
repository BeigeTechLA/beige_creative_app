import '../../domain/entities/message.dart';

class MessageDto {
  /// Canonical dummy-fixture shape (camelCase, nested `file` object).
  /// Used by `MessagesDummySource`. Do not call from real REST/socket paths.
  static Message fromJson(Map<String, dynamic> json) {
    final fileRaw = json['file'] as Map<String, dynamic>?;
    return Message(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      type: _parseType(json['type'] as String?),
      body: json['body'] as String?,
      file: fileRaw == null
          ? null
          : MessageFile(
              url: fileRaw['url'] as String,
              name: fileRaw['name'] as String,
              mimeType: fileRaw['mimeType'] as String,
              sizeBytes: (fileRaw['sizeBytes'] as num).toInt(),
              durationMs: (fileRaw['durationMs'] as num?)?.toInt(),
            ),
      sentAt: DateTime.parse(json['sentAt'] as String).toLocal(),
      isEdited: (json['isEdited'] as bool?) ?? false,
      isDeleted: (json['isDeleted'] as bool?) ?? false,
      replyToId: json['replyToId'] as String?,
      deliveryStatus: _parseStatus(json['deliveryStatus'] as String?),
    );
  }

  /// REST list shape (`GET /external-chat/messages/:roomId`).
  /// snake_case, flat `file_url` / `file_name` / `file_type` fields.
  /// Assumed shape — verify with backend.
  static Message fromRestJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final senderId = (json['sent_by'] ?? json['senderId'] ?? '').toString();
    final fileUrl = json['file_url'] as String?;
    final fileType = json['file_type'] as String?;
    return Message(
      id: (json['id'] ?? json['_id'] ?? json['messageId']).toString(),
      senderId: senderId,
      senderName: (json['sender_name'] ?? json['senderName'] ?? '') as String,
      type: _parseType(json['message_type'] as String?),
      body: (json['message'] ?? json['content']) as String?,
      file: fileUrl == null
          ? null
          : MessageFile(
              url: fileUrl,
              name: (json['file_name'] ?? '') as String,
              mimeType: fileType ?? 'application/octet-stream',
              sizeBytes: ((json['file_size'] ?? json['size_bytes'] ?? 0) as num).toInt(),
              durationMs: (json['duration_ms'] as num?)?.toInt(),
            ),
      sentAt: DateTime.parse(
        (json['createdAt'] ?? json['created_at'] ?? json['sentAt']).toString(),
      ).toLocal(),
      isEdited: (json['is_edited'] as bool?) ?? false,
      isDeleted: (json['is_deleted'] as bool?) ?? false,
      replyToId: (json['reply_to'] ?? json['replyTo']) as String?,
      deliveryStatus: _restStatus(json, currentUserId: currentUserId, senderId: senderId),
    );
  }

  /// Socket payload shape per `web-chat-socket-reference.md` §"Realtime Message Event".
  /// camelCase, flat `fileUrl` / `fileName` / `fileType`. Always treated as
  /// just-delivered (status = `delivered`) — recipient state is local.
  static Message fromSocketJson(Map<String, dynamic> json) {
    final fileUrl = json['fileUrl'] as String?;
    final fileType = json['fileType'] as String?;
    return Message(
      id: (json['messageId'] ?? json['_id'] ?? json['id']).toString(),
      senderId: (json['senderId'] ?? json['sent_by'] ?? '').toString(),
      senderName: (json['senderName'] ?? json['sender_name'] ?? '') as String,
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
      replyToId: (json['replyTo'] ?? json['reply_to']) as String?,
      deliveryStatus: DeliveryStatus.delivered,
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

  static DeliveryStatus _parseStatus(String? raw) {
    switch (raw) {
      case 'sending':
        return DeliveryStatus.sending;
      case 'delivered':
        return DeliveryStatus.delivered;
      case 'read':
        return DeliveryStatus.read;
      case 'failed':
        return DeliveryStatus.failed;
      default:
        return DeliveryStatus.sent;
    }
  }

  /// Derives status from REST payload. Backend doesn't ship explicit status —
  /// historical messages are at least `delivered`. Tighten when read receipts
  /// land (plan §11 Q4).
  static DeliveryStatus _restStatus(
    Map<String, dynamic> json, {
    required String currentUserId,
    required String senderId,
  }) {
    final readBy = (json['read_by'] as List?)?.cast<dynamic>().map((e) => e.toString()).toSet() ?? const <String>{};
    if (senderId == currentUserId) {
      final othersRead = readBy.any((id) => id != currentUserId);
      return othersRead ? DeliveryStatus.read : DeliveryStatus.delivered;
    }
    return DeliveryStatus.delivered;
  }
}
