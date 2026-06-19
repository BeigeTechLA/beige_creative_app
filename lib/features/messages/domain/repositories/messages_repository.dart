import '../entities/chat_details.dart';
import '../entities/chat_thread.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';
import '../events/chat_socket_event.dart';

/// Stable interface for messaging. Backed by REST + socket.io.
abstract class MessagesRepository {
  Future<List<Conversation>> listConversations({String? query});

  Future<ChatThread> fetchThread(String conversationId, {String? cursor});

  /// Fetches the latest single message for a room. Used by the list-screen
  /// preview hydration since backend returns only `last_message` as id.
  Future<Message?> fetchLatestMessage(String conversationId);

  /// socket.io-backed per-room event stream. UI never imports `socket_io_client`.
  /// Caller must pair with [joinConversation]/[leaveConversation] for lifecycle.
  Stream<ChatSocketEvent> events(String conversationId);

  /// Cross-room event firehose for the conversation list (preview / unread
  /// refresh).
  Stream<ChatSocketEvent> globalEvents();

  /// Emit `joinRoom` to backend so this client starts receiving room events.
  /// Idempotent; safe to call before socket connect resolves.
  Future<void> joinConversation(String conversationId);

  /// Emit `leaveRoom` + drop per-room subscription. Called from thread-screen
  /// dispose via `ref.onDispose`.
  Future<void> leaveConversation(String conversationId);

  /// Composer typing pulses.
  void notifyTyping(String conversationId);
  void notifyStopTyping(String conversationId);

  Future<Message> sendText(
    String conversationId,
    String body, {
    String? replyToId,
  });

  Future<Message> sendAudio(
    String conversationId,
    String localPath,
    Duration duration,
  );

  Future<Message> sendAttachment(
    String conversationId, {
    required String localPath,
    required String name,
    required String mimeType,
    required int sizeBytes,
  });

  /// `conversationId` required by REST contract — body carries `roomId`
  /// (`external-chat-api-reference.md` §14).
  Future<void> editMessage(
    String conversationId,
    String messageId,
    String newBody,
  );

  /// `conversationId` required by REST contract — body carries `roomId`
  /// (`external-chat-api-reference.md` §15).
  Future<void> deleteMessage(String conversationId, String messageId);

  Future<void> markRead(String conversationId, String upToMessageId);

  Future<ChatDetails> fetchDetails(String conversationId);
}
