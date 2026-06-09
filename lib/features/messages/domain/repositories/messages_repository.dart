import '../entities/chat_details.dart';
import '../entities/chat_thread.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';
import '../events/chat_socket_event.dart';

/// Stable interface for messaging. Backed by `MessagesDummySource` in UI
/// phases (M1-M5). M6 swaps in REST + socket.io implementations behind the
/// same contract — UI never changes.
abstract class MessagesRepository {
  Future<List<Conversation>> listConversations({
    required ConversationTab tab,
    String? query,
  });

  Future<ChatThread> fetchThread(String conversationId, {String? cursor});

  /// socket.io-backed event stream. UI never imports `socket_io_client`.
  Stream<ChatSocketEvent> events(String conversationId);

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

  Future<void> editMessage(String messageId, String newBody);

  Future<void> deleteMessage(String messageId);

  Future<void> markRead(String conversationId, String upToMessageId);

  Future<ChatDetails> fetchDetails(String conversationId);
}
