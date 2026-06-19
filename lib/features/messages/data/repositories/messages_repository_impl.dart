import '../../domain/entities/chat_details.dart';
import '../../domain/entities/chat_thread.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/events/chat_socket_event.dart';
import '../../domain/repositories/messages_repository.dart';
import '../sources/messages_remote_source.dart';
import '../sources/messages_socket_source.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  MessagesRepositoryImpl({
    required this.remote,
    required this.socket,
  });

  final MessagesRemoteSource remote;
  final MessagesSocketSource socket;

  @override
  Future<List<Conversation>> listConversations({String? query}) {
    return remote.listConversations(query: query);
  }

  @override
  Future<ChatThread> fetchThread(String conversationId, {String? cursor}) {
    return remote.fetchThread(conversationId, cursor: cursor);
  }

  @override
  Future<Message?> fetchLatestMessage(String conversationId) {
    return remote.fetchLatestMessage(conversationId);
  }

  @override
  Stream<ChatSocketEvent> events(String conversationId) {
    return socket.events(conversationId);
  }

  @override
  Stream<ChatSocketEvent> globalEvents() {
    return socket.globalEvents();
  }

  @override
  Future<void> joinConversation(String conversationId) {
    return socket.joinRoom(conversationId);
  }

  @override
  Future<void> leaveConversation(String conversationId) {
    return socket.leaveRoom(conversationId);
  }

  @override
  void notifyTyping(String conversationId) {
    socket.emitTyping(conversationId);
  }

  @override
  void notifyStopTyping(String conversationId) {
    socket.emitStopTyping(conversationId);
  }

  @override
  Future<Message> sendText(
    String conversationId,
    String body, {
    String? replyToId,
  }) {
    return remote.sendText(conversationId, body, replyToId: replyToId);
  }

  @override
  Future<Message> sendAudio(
    String conversationId,
    String localPath,
    Duration duration,
  ) {
    return remote.sendAudio(conversationId, localPath, duration);
  }

  @override
  Future<Message> sendAttachment(
    String conversationId, {
    required String localPath,
    required String name,
    required String mimeType,
    required int sizeBytes,
  }) {
    return remote.sendAttachment(
      conversationId,
      localPath: localPath,
      name: name,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
    );
  }

  @override
  Future<void> editMessage(
    String conversationId,
    String messageId,
    String newBody,
  ) {
    return remote.editMessage(conversationId, messageId, newBody);
  }

  @override
  Future<void> deleteMessage(String conversationId, String messageId) {
    return remote.deleteMessage(conversationId, messageId);
  }

  @override
  Future<void> markRead(String conversationId, String upToMessageId) {
    return remote.markRead(conversationId, upToMessageId);
  }

  @override
  Future<ChatDetails> fetchDetails(String conversationId) {
    return remote.fetchDetails(conversationId);
  }
}