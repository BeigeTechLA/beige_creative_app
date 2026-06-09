import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/chat_details.dart';
import '../../domain/entities/chat_thread.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/events/chat_socket_event.dart';
import '../dto/chat_details_dto.dart';
import '../dto/conversation_dto.dart';
import '../dto/message_dto.dart';

/// Reads bundled JSON from `assets/dummy/messages/` and fakes a realtime
/// stream via `Stream.periodic`. Replaced by remote + socket sources in M6.
class MessagesDummySource {
  static const String _root = 'assets/dummy/messages';
  static const Duration _networkLatency = Duration(milliseconds: 350);
  static const Duration _typingTickInterval = Duration(seconds: 8);

  Future<List<Conversation>> loadConversations() async {
    final raw = await rootBundle.loadString('$_root/conversations.json');
    await Future.delayed(_networkLatency);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final listRaw = (decoded['conversations'] as List)
        .cast<Map<String, dynamic>>();
    final now = DateTime.now();
    final conversations = <Conversation>[];
    for (var i = 0; i < listRaw.length; i++) {
      final conv = ConversationDto.fromJson(listRaw[i]);
      if (conv.lastMessage != null) {
        final offset = switch (i) {
          0 => const Duration(minutes: 5),
          1 => const Duration(hours: 1),
          2 => const Duration(hours: 2),
          _ => const Duration(days: 1),
        };
        conversations.add(
          conv.copyWith(
            lastMessage: conv.lastMessage!.copyWith(
              sentAt: now.subtract(offset),
            ),
          ),
        );
      } else {
        conversations.add(conv);
      }
    }
    return conversations;
  }

  Future<ChatThread> loadThread(String conversationId) async {
    final raw = await rootBundle.loadString(
      '$_root/messages_$conversationId.json',
    );
    await Future.delayed(_networkLatency);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final messagesRaw = decoded['messages'] as List;
    final now = DateTime.now();
    final messages = <Message>[];
    for (var i = 0; i < messagesRaw.length; i++) {
      final item = messagesRaw[i] as Map<String, dynamic>;
      final message = MessageDto.fromJson(item);
      final offsetMinutes = (messagesRaw.length - i) * 5;
      messages.add(
        message.copyWith(
          sentAt: now.subtract(Duration(minutes: offsetMinutes)),
        ),
      );
    }
    return ChatThread(conversationId: conversationId, messages: messages);
  }

  Future<ChatDetails> loadDetails(String conversationId) async {
    final raw = await rootBundle.loadString(
      '$_root/details_$conversationId.json',
    );
    await Future.delayed(_networkLatency);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return ChatDetailsDto.fromJson(decoded);
  }

  /// Fake realtime stream — alternates typing-started / typing-stopped on a
  /// fixed cadence so the UI can observe transitions without real backend.
  Stream<ChatSocketEvent> events(String conversationId) async* {
    var tick = 0;
    yield* Stream.periodic(_typingTickInterval, (i) => i).asyncMap((i) async {
      tick = i;
      final typing = tick.isEven;
      return typing
          ? TypingStarted(conversationId, 'user_angela', 'Angela Kia')
          : TypingStopped(conversationId, 'user_angela');
    });
  }

  Future<Message> echoText(
    String conversationId,
    String body, {
    String? replyToId,
  }) async {
    await Future.delayed(_networkLatency);
    return Message(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      senderId: 'user_me',
      senderName: 'Me',
      type: MessageType.text,
      body: body,
      sentAt: DateTime.now(),
      replyToId: replyToId,
      deliveryStatus: DeliveryStatus.sent,
    );
  }

  Future<Message> echoAudio(
    String conversationId,
    String localPath,
    Duration duration,
  ) async {
    await Future.delayed(_networkLatency);
    return Message(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      senderId: 'user_me',
      senderName: 'Me',
      type: MessageType.file,
      sentAt: DateTime.now(),
      file: MessageFile(
        url: localPath,
        name: 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
        mimeType: 'audio/m4a',
        sizeBytes: 0,
        durationMs: duration.inMilliseconds,
      ),
      deliveryStatus: DeliveryStatus.sent,
    );
  }

  Future<Message> echoAttachment(
    String conversationId, {
    required String localPath,
    required String name,
    required String mimeType,
    required int sizeBytes,
  }) async {
    await Future.delayed(_networkLatency);
    return Message(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      senderId: 'user_me',
      senderName: 'Me',
      type: mimeType.startsWith('image/')
          ? MessageType.image
          : MessageType.file,
      sentAt: DateTime.now(),
      file: MessageFile(
        url: localPath,
        name: name,
        mimeType: mimeType,
        sizeBytes: sizeBytes,
      ),
      deliveryStatus: DeliveryStatus.sent,
    );
  }
}
