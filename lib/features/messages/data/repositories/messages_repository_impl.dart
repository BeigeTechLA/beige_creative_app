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
  Future<List<Conversation>> listConversations({
    required ConversationTab tab,
    String? query,
  }) async {
    if (useDummy) {
      final all = await dummy.loadConversations();
      return _filter(all, tab, query);
    }
    return remote.listConversations(tab: tab, query: query);
  }

  List<Conversation> _filter(
    List<Conversation> source,
    ConversationTab tab,
    String? query,
  ) {
    Iterable<Conversation> out = source;
    if (tab != ConversationTab.all) {
      out = out.where((c) => c.tab == tab);
    }
    final q = (query ?? '').trim().toLowerCase();
    if (q.isNotEmpty) {
      out = out.where((c) {
        if (c.title.toLowerCase().contains(q)) return true;
        final last = c.lastMessage?.preview.toLowerCase() ?? '';
        return last.contains(q);
      });
    }
    return out.toList(growable: false);
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
  Future<void> editMessage(String messageId, String newBody) {
    if (useDummy) return Future.value();
    return remote.editMessage(messageId, newBody);
  }

  @override
  Future<void> deleteMessage(String messageId) {
    if (useDummy) return Future.value();
    return remote.deleteMessage(messageId);
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
