import 'package:flutter/foundation.dart';

import '../entities/message.dart';

/// Sealed union of realtime events emitted by the messaging socket.
/// Mirrors backend socket.io events from `web-chat-socket-reference.md`.
@immutable
sealed class ChatSocketEvent {
  const ChatSocketEvent();
}

class MessageReceived extends ChatSocketEvent {
  final String conversationId;
  final Message message;
  const MessageReceived(this.conversationId, this.message);
}

class MessageEdited extends ChatSocketEvent {
  final String conversationId;
  final String messageId;
  final String newBody;
  const MessageEdited(this.conversationId, this.messageId, this.newBody);
}

class MessageDeleted extends ChatSocketEvent {
  final String conversationId;
  final String messageId;
  const MessageDeleted(this.conversationId, this.messageId);
}

class TypingStarted extends ChatSocketEvent {
  final String conversationId;
  final String userId;
  final String userName;
  const TypingStarted(this.conversationId, this.userId, this.userName);
}

class TypingStopped extends ChatSocketEvent {
  final String conversationId;
  final String userId;
  const TypingStopped(this.conversationId, this.userId);
}

class PresenceChanged extends ChatSocketEvent {
  final String userId;
  final bool isOnline;
  const PresenceChanged(this.userId, this.isOnline);
}

class ReadReceiptUpdated extends ChatSocketEvent {
  final String conversationId;
  final String upToMessageId;
  final String readerId;
  const ReadReceiptUpdated(
    this.conversationId,
    this.upToMessageId,
    this.readerId,
  );
}

class RoomPreviewUpdated extends ChatSocketEvent {
  final String conversationId;
  const RoomPreviewUpdated(this.conversationId);
}

class ParticipantsChanged extends ChatSocketEvent {
  final String conversationId;
  const ParticipantsChanged(this.conversationId);
}

class RoomStatusChanged extends ChatSocketEvent {
  final String conversationId;
  final String status;
  const RoomStatusChanged(this.conversationId, this.status);
}

class NotificationReceived extends ChatSocketEvent {
  final String? conversationId;
  final String body;
  const NotificationReceived(this.body, {this.conversationId});
}

class SocketErrored extends ChatSocketEvent {
  final String message;
  const SocketErrored(this.message);
}

/// Emitted once the socket transitions from disconnected → connected after a
/// prior drop. Signal for consumers (conversation list) to force-refresh so
/// events missed during the outage are recovered.
class SocketReconnected extends ChatSocketEvent {
  const SocketReconnected();
}

class ReactionUpdated extends ChatSocketEvent {
  final String conversationId;
  final String messageId;
  final Map<String, Set<String>> reactions;
  const ReactionUpdated(
    this.conversationId,
    this.messageId,
    this.reactions,
  );
}
