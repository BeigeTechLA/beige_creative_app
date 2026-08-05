import 'dart:async';

import 'package:beige_creative_app/features/messages/domain/entities/chat_details.dart';
import 'package:beige_creative_app/features/messages/domain/entities/chat_thread.dart';
import 'package:beige_creative_app/features/messages/domain/entities/conversation.dart';
import 'package:beige_creative_app/features/messages/domain/entities/message.dart';
import 'package:beige_creative_app/features/messages/domain/events/chat_socket_event.dart';
import 'package:beige_creative_app/features/messages/domain/repositories/messages_repository.dart';
import 'package:beige_creative_app/features/messages/presentation/providers/chat_thread_providers.dart';
import 'package:beige_creative_app/features/messages/presentation/providers/messages_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stub repo with a single per-room event channel the test can drive.
class _DriverRepo implements MessagesRepository {
  final List<Message> initial;
  final StreamController<ChatSocketEvent> eventsCtrl =
      StreamController.broadcast();
  final List<String> markReadCalls = [];

  _DriverRepo({this.initial = const []});

  @override
  Future<List<Conversation>> listConversations({String? query}) async => const [];

  @override
  Future<ChatThread> fetchThread(String conversationId, {String? cursor}) async {
    return ChatThread(conversationId: conversationId, messages: initial);
  }

  @override
  Future<Message?> fetchLatestMessage(String conversationId) async => null;

  @override
  Stream<ChatSocketEvent> events(String conversationId) => eventsCtrl.stream;

  @override
  Stream<ChatSocketEvent> globalEvents() => const Stream.empty();

  @override
  Future<void> joinConversation(String conversationId) async {}

  @override
  Future<void> leaveConversation(String conversationId) async {}

  @override
  void notifyTyping(String conversationId) {}

  @override
  void notifyStopTyping(String conversationId) {}

  @override
  Future<Message> sendText(String conversationId, String body,
          {String? replyToId}) async =>
      throw UnimplementedError();

  @override
  Future<Message> sendAudio(String conversationId, String localPath,
          Duration duration) async =>
      throw UnimplementedError();

  @override
  Future<Message> sendAttachment(String conversationId,
          {required String localPath,
          required String name,
          required String mimeType,
          required int sizeBytes}) async =>
      throw UnimplementedError();

  @override
  Future<void> editMessage(
          String conversationId, String messageId, String newBody) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteMessage(
          String conversationId, String messageId) async =>
      throw UnimplementedError();

  @override
  Future<void> markRead(String conversationId, String upToMessageId) async {
    markReadCalls.add('$conversationId:$upToMessageId');
  }

  @override
  Future<ChatDetails> fetchDetails(String conversationId) async =>
      throw UnimplementedError();

  @override
  Future<({String emoji, String userId})> sendReaction({
    required String conversationId,
    required String messageId,
    required String emoji,
  }) async =>
      throw UnimplementedError();
}

Message _msg({
  required String id,
  String senderId = 'user_angela',
  String body = 'hi',
  DateTime? sentAt,
}) {
  return Message(
    id: id,
    senderId: senderId,
    senderName: 'Angela',
    type: MessageType.text,
    body: body,
    sentAt: sentAt ?? DateTime(2026, 6, 14, 10),
  );
}

void main() {
  late _DriverRepo repo;
  late ProviderContainer container;

  /// Tracks the active listener so the AutoDispose notifier survives between
  /// the test's `hydrate` call and assertions.
  ProviderSubscription<ChatThreadState>? activeSub;

  Future<void> hydrate(String roomId) async {
    activeSub = container.listen<ChatThreadState>(
      chatThreadProvider(roomId),
      (_, _) {},
    );
    // Drain microtasks until _hydrate flips isLoading off.
    for (var i = 0; i < 20; i++) {
      if (!container.read(chatThreadProvider(roomId)).isLoading) break;
      await Future<void>.delayed(Duration.zero);
    }
    // One extra microtask so markRead() in _hydrate runs before the test
    // body continues (otherwise markReadCalls.clear() races it).
    await Future<void>.delayed(Duration.zero);
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    repo = _DriverRepo(initial: [_msg(id: 'm_1', body: 'first')]);
    container = ProviderContainer(overrides: [
      messagesRepositoryProvider.overrideWithValue(repo),
    ]);
  });

  tearDown(() async {
    activeSub?.close();
    activeSub = null;
    await repo.eventsCtrl.close();
    container.dispose();
  });

  test('MessageEdited patches body + isEdited', () async {
    await hydrate('room_1');
    repo.eventsCtrl.add(MessageEdited('room_1', 'm_1', 'first updated'));
    await Future<void>.delayed(Duration.zero);

    final state = container.read(chatThreadProvider('room_1'));
    expect(state.messages.first.body, 'first updated');
    expect(state.messages.first.isEdited, isTrue);
  });

  test('MessageDeleted flips isDeleted on matching id', () async {
    await hydrate('room_1');
    repo.eventsCtrl.add(MessageDeleted('room_1', 'm_1'));
    await Future<void>.delayed(Duration.zero);

    final state = container.read(chatThreadProvider('room_1'));
    expect(state.messages.first.isDeleted, isTrue);
  });

  test('MessageReceived with new id appends + triggers markRead', () async {
    await hydrate('room_1');
    repo.markReadCalls.clear();
    repo.eventsCtrl.add(MessageReceived('room_1', _msg(id: 'm_2', body: 'second')));
    await Future<void>.delayed(Duration.zero);

    final state = container.read(chatThreadProvider('room_1'));
    expect(state.messages.map((m) => m.id), ['m_1', 'm_2']);
    expect(repo.markReadCalls, contains('room_1:m_2'));
  });

  test('MessageReceived with existing id dedupes + bumps to delivered', () async {
    await hydrate('room_1');
    repo.markReadCalls.clear();
    // Same id as initial m_1 — backend echo of our own POST.
    repo.eventsCtrl.add(MessageReceived('room_1', _msg(id: 'm_1', body: 'first')));
    await Future<void>.delayed(Duration.zero);

    final state = container.read(chatThreadProvider('room_1'));
    expect(state.messages, hasLength(1));
    expect(state.messages.first.deliveryStatus, DeliveryStatus.delivered);
    // Own echo must NOT trigger markRead (would be wasteful).
    expect(repo.markReadCalls, isEmpty);
  });

  test('TypingStarted/Stopped flip peerTyping', () async {
    await hydrate('room_1');

    repo.eventsCtrl.add(TypingStarted('room_1', 'user_angela', 'Angela'));
    await Future<void>.delayed(Duration.zero);
    expect(container.read(chatThreadProvider('room_1')).peerTyping, isTrue);

    repo.eventsCtrl.add(TypingStopped('room_1', 'user_angela'));
    await Future<void>.delayed(Duration.zero);
    expect(container.read(chatThreadProvider('room_1')).peerTyping, isFalse);
  });

  test('SocketErrored sets connection-lost banner', () async {
    await hydrate('room_1');
    repo.eventsCtrl.add(const SocketErrored('boom'));
    await Future<void>.delayed(Duration.zero);

    final state = container.read(chatThreadProvider('room_1'));
    expect(state.errorMessage, contains('Connection lost'));
  });

  test('events from a different room are ignored', () async {
    await hydrate('room_1');
    repo.eventsCtrl.add(MessageReceived('room_other', _msg(id: 'm_x')));
    await Future<void>.delayed(Duration.zero);

    final state = container.read(chatThreadProvider('room_1'));
    expect(state.messages, hasLength(1)); // unchanged
  });
}
