import '../../domain/entities/chat_details.dart';
import '../../domain/entities/chat_thread.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/events/chat_socket_event.dart';
import '../../domain/repositories/messages_repository.dart';
import '../sources/messages_dummy_source.dart';
import '../sources/messages_remote_source.dart';
import '../sources/messages_socket_source.dart';

/// Routes calls to either dummy or remote+socket based on [useDummy]. UI never
/// branches on this flag — repository is the only seam. M6 flips the default.
class MessagesRepositoryImpl implements MessagesRepository {
  MessagesRepositoryImpl({
    required this.dummy,
    required this.remote,
    required this.socket,
    required this.useDummy,
  });

  final MessagesDummySource dummy;
  final MessagesRemoteSource remote;
  final MessagesSocketSource socket;
  final bool useDummy;

  @override
  Future<List<Conversation>> listConversations({String? query}) async {
    if (useDummy) {
      final all = await dummy.loadConversations();
      return _filter(all, query);
    }
    return remote.listConversations(query: query);
  }

  List<Conversation> _filter(List<Conversation> source, String? query) {
    final q = (query ?? '').trim().toLowerCase();
    if (q.isEmpty) return source;
    return source.where((c) {
      if (c.title.toLowerCase().contains(q)) return true;
      final last = c.lastMessage?.preview.toLowerCase() ?? '';
      return last.contains(q);
    }).toList(growable: false);
  }

  @override
  Future<ChatThread> fetchThread(String conversationId, {String? cursor}) {
    if (useDummy) return dummy.loadThread(conversationId);
    return remote.fetchThread(conversationId, cursor: cursor);
  }

  @override
  Stream<ChatSocketEvent> events(String conversationId) {
    if (useDummy) return dummy.events(conversationId);
    return socket.events(conversationId);
  }

  @override
  Stream<ChatSocketEvent> globalEvents() {
    if (useDummy) return const Stream.empty();
    return socket.globalEvents();
  }

  @override
  Future<void> joinConversation(String conversationId) {
    if (useDummy) return Future.value();
    return socket.joinRoom(conversationId);
  }

  @override
  Future<void> leaveConversation(String conversationId) {
    if (useDummy) return Future.value();
    return socket.leaveRoom(conversationId);
  }

  @override
  void notifyTyping(String conversationId) {
    if (useDummy) return;
    socket.emitTyping(conversationId);
  }

  @override
  void notifyStopTyping(String conversationId) {
    if (useDummy) return;
    socket.emitStopTyping(conversationId);
  }

  @override
  Future<Message> sendText(
    String conversationId,
    String body, {
    String? replyToId,
  }) {
    if (useDummy) {
      return dummy.echoText(conversationId, body, replyToId: replyToId);
    }
    return remote.sendText(conversationId, body, replyToId: replyToId);
  }

  @override
  Future<Message> sendAudio(
    String conversationId,
    String localPath,
    Duration duration,
  ) {
    if (useDummy) return dummy.echoAudio(conversationId, localPath, duration);
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
    if (useDummy) {
      return dummy.echoAttachment(
        conversationId,
        localPath: localPath,
        name: name,
        mimeType: mimeType,
        sizeBytes: sizeBytes,
      );
    }
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
    if (useDummy) return Future.value();
    return remote.editMessage(conversationId, messageId, newBody);
  }

  @override
  Future<void> deleteMessage(String conversationId, String messageId) {
    if (useDummy) return Future.value();
    return remote.deleteMessage(conversationId, messageId);
  }

  @override
  Future<void> markRead(String conversationId, String upToMessageId) {
    if (useDummy) return Future.value();
    return remote.markRead(conversationId, upToMessageId);
  }

  @override
  Future<ChatDetails> fetchDetails(String conversationId) {
    if (useDummy) return dummy.loadDetails(conversationId);
    return remote.fetchDetails(conversationId);
  }
}
