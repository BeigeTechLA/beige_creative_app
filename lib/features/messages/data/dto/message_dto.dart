import '../../domain/entities/message.dart';

class MessageDto {
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
}
