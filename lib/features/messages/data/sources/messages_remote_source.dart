import '../../domain/entities/chat_details.dart';
import '../../domain/entities/chat_thread.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';

/// REST source. Stubbed for UI phases (M1-M5). Implemented against
/// `external-chat/*` endpoints in M6 using `dioClientProvider`.
class MessagesRemoteSource {
  Future<List<Conversation>> listConversations({
    required ConversationTab tab,
    String? query,
  }) {
    throw UnimplementedError('Remote source lands in M6');
  }

  Future<ChatThread> fetchThread(String conversationId, {String? cursor}) {
    throw UnimplementedError('Remote source lands in M6');
  }

  Future<Message> sendText(
    String conversationId,
    String body, {
    String? replyToId,
  }) {
    throw UnimplementedError('Remote source lands in M6');
  }

  Future<Message> sendAudio(
    String conversationId,
    String localPath,
    Duration duration,
  ) {
    throw UnimplementedError('Remote source lands in M6');
  }

  Future<Message> sendAttachment(
    String conversationId, {
    required String localPath,
    required String name,
    required String mimeType,
    required int sizeBytes,
  }) {
    throw UnimplementedError('Remote source lands in M6');
  }

  Future<void> editMessage(String messageId, String newBody) {
    throw UnimplementedError('Remote source lands in M6');
  }

  Future<void> deleteMessage(String messageId) {
    throw UnimplementedError('Remote source lands in M6');
  }

  Future<void> markRead(String conversationId, String upToMessageId) {
    throw UnimplementedError('Remote source lands in M6');
  }

  Future<ChatDetails> fetchDetails(String conversationId) {
    throw UnimplementedError('Remote source lands in M6');
  }
}
