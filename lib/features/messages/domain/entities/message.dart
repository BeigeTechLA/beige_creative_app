import 'package:flutter/foundation.dart';

/// Backend `message_type` enum — matches web ChatMessage model.
/// Audio is delivered as `file` with `MessageFile.mimeType` starting `audio/`.
enum MessageType { text, image, file, system }

enum DeliveryStatus { sending, sent, delivered, read, failed }

@immutable
class MessageFile {
  final String url;
  final String name;
  final String mimeType;
  final int sizeBytes;
  final int? durationMs;

  const MessageFile({
    required this.url,
    required this.name,
    required this.mimeType,
    required this.sizeBytes,
    this.durationMs,
  });

  bool get isAudio => mimeType.startsWith('audio/');
  bool get isImage => mimeType.startsWith('image/');
}

/// Snippet of the message being replied to. Ships inline with the parent
/// message so bubbles can render the quoted preview without a second fetch.
@immutable
class MessageReplyPreview {
  final String id;
  final String senderId;
  final String senderName;
  final MessageType type;
  final String? body;
  final String? fileName;

  const MessageReplyPreview({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.type,
    this.body,
    this.fileName,
  });
}

@immutable
class Message {
  final String id;
  final String senderId;
  final String senderName;
  final MessageType type;
  final String? body;
  final MessageFile? file;
  final DateTime sentAt;
  final bool isEdited;
  final bool isDeleted;
  final String? replyToId;
  final MessageReplyPreview? replyTo;
  final DeliveryStatus deliveryStatus;
  /// Emoji → set of user ids that reacted with it. Empty map = no reactions.
  final Map<String, Set<String>> reactions;

  const Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.type,
    required this.sentAt,
    this.body,
    this.file,
    this.isEdited = false,
    this.isDeleted = false,
    this.replyToId,
    this.replyTo,
    this.deliveryStatus = DeliveryStatus.sent,
    this.reactions = const {},
  });

  Message copyWith({
    String? id,
    DeliveryStatus? deliveryStatus,
    String? body,
    bool? isEdited,
    bool? isDeleted,
    DateTime? sentAt,
    Map<String, Set<String>>? reactions,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId,
      senderName: senderName,
      type: type,
      sentAt: sentAt ?? this.sentAt,
      body: body ?? this.body,
      file: file,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      replyToId: replyToId,
      replyTo: replyTo,
      reactions: reactions ?? this.reactions,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    );
  }
}
