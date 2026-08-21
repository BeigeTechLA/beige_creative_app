import 'package:flutter/foundation.dart';

import 'message.dart';

@immutable
class ChatThread {
  final String conversationId;
  final List<Message> messages;
  final String? nextCursor;

  const ChatThread({
    required this.conversationId,
    required this.messages,
    this.nextCursor,
  });
}
