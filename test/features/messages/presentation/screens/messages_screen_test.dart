import 'dart:async';

import 'package:beige_creative_app/features/messages/domain/entities/chat_details.dart';
import 'package:beige_creative_app/features/messages/domain/entities/chat_thread.dart';
import 'package:beige_creative_app/features/messages/domain/entities/conversation.dart';
import 'package:beige_creative_app/features/messages/domain/entities/message.dart';
import 'package:beige_creative_app/features/messages/domain/entities/participant.dart';
import 'package:beige_creative_app/features/messages/domain/entities/shared_file.dart';
import 'package:beige_creative_app/features/messages/domain/events/chat_socket_event.dart';
import 'package:beige_creative_app/features/messages/domain/repositories/messages_repository.dart';
import 'package:beige_creative_app/features/messages/presentation/providers/messages_repository_provider.dart';
import 'package:beige_creative_app/features/messages/presentation/screens/chat_details_screen.dart';
import 'package:beige_creative_app/features/messages/presentation/screens/chat_thread_screen.dart';
import 'package:beige_creative_app/features/messages/presentation/screens/messages_screen.dart';
import 'package:beige_creative_app/features/messages/presentation/screens/widgets/details_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMessagesRepository implements MessagesRepository {
  final sentBodies = <String>[];
  Completer<Message>? sendTextCompleter;

  @override
  Future<List<Conversation>> listConversations({String? query}) async {
    final items = [
      Conversation(
        id: 'conv_001',
        title: 'Angela Kia',
        unreadCount: 2,
        isOnline: true,
        participantIds: ['user_me', 'user_angela'],
        lastMessage: ConversationPreview(
          preview: 'Hey! How are you?',
          sentAt: _stamp,
          fromMe: false,
        ),
      ),
      Conversation(
        id: 'conv_002',
        title: 'Shoot Planning',
        unreadCount: 0,
        isOnline: false,
        participantIds: ['user_me', 'producer'],
        lastMessage: ConversationPreview(
          preview: 'Call sheet attached.',
          sentAt: _stamp,
          fromMe: true,
        ),
      ),
    ];
    if (query == null || query.isEmpty) return items;
    return [
      for (final item in items)
        if (item.title.toLowerCase().contains(query.toLowerCase())) item,
    ];
  }

  @override
  Future<ChatThread> fetchThread(
    String conversationId, {
    String? cursor,
  }) async {
    return ChatThread(
      conversationId: conversationId,
      messages: [
        Message(
          id: 'm1',
          senderId: 'user_angela',
          senderName: 'Angela Kia',
          type: MessageType.text,
          body: 'Hello!',
          sentAt: _stamp,
        ),
      ],
    );
  }

  @override
  Future<Message?> fetchLatestMessage(String conversationId) async => null;

  @override
  Stream<ChatSocketEvent> events(String conversationId) => const Stream.empty();

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
  Future<Message> sendText(
    String conversationId,
    String body, {
    String? replyToId,
  }) {
    sentBodies.add(body);
    final completer = Completer<Message>();
    sendTextCompleter = completer;
    return completer.future;
  }

  @override
  Future<Message> sendAudio(
    String conversationId,
    String localPath,
    Duration duration,
  ) async {
    return Message(
      id: 'audio_1',
      senderId: 'user_me',
      senderName: 'Me',
      type: MessageType.file,
      sentAt: _stamp,
      file: MessageFile(
        url: localPath,
        name: 'voice.m4a',
        mimeType: 'audio/m4a',
        sizeBytes: 0,
        durationMs: duration.inMilliseconds,
      ),
    );
  }

  @override
  Future<Message> sendAttachment(
    String conversationId, {
    required String localPath,
    required String name,
    required String mimeType,
    required int sizeBytes,
  }) async {
    return Message(
      id: 'file_1',
      senderId: 'user_me',
      senderName: 'Me',
      type: MessageType.file,
      sentAt: _stamp,
      file: MessageFile(
        url: localPath,
        name: name,
        mimeType: mimeType,
        sizeBytes: sizeBytes,
      ),
    );
  }

  @override
  Future<void> editMessage(
    String conversationId,
    String messageId,
    String newBody,
  ) async {}

  @override
  Future<void> deleteMessage(String conversationId, String messageId) async {}

  @override
  Future<void> markRead(String conversationId, String upToMessageId) async {}

  @override
  Future<ChatDetails> fetchDetails(String conversationId) async {
    return ChatDetails(
      conversationId: conversationId,
      roomName: 'Angela Kia',
      contact: const ContactInfo(id: 'p1', name: 'Angela Kia'),
      participants: const [
        Participant(id: 'user_me', name: 'Me', role: 'crew'),
        Participant(id: 'user_angela', name: 'Angela Kia', role: 'cp'),
      ],
      sharedFiles: [
        SharedFile(
          id: 'f1',
          name: 'call_sheet.pdf',
          mimeType: 'application/pdf',
          sizeBytes: 2048,
          uploadedAt: DateTime(2026, 1, 23, 9, 25),
        ),
      ],
    );
  }

  @override
  Future<({String emoji, String userId})> sendReaction({
    required String conversationId,
    required String messageId,
    required String emoji,
  }) async =>
      throw UnimplementedError();
}

final _stamp = DateTime(2026, 1, 23, 9, 25);

Future<void> _pumpWithRepo(
  WidgetTester tester,
  Widget child,
  _FakeMessagesRepository repo,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [messagesRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        home: Scaffold(
          drawer: const Drawer(child: Text('drawer-open')),
          body: child,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('MessagesScreen renders conversation list', (tester) async {
    final repo = _FakeMessagesRepository();
    await _pumpWithRepo(tester, const MessagesScreen(), repo);

    expect(find.text('Message'), findsOneWidget);
    expect(find.text('Angela Kia'), findsOneWidget);
    expect(find.text('Shoot Planning'), findsOneWidget);
  });

  testWidgets('ChatThreadScreen shows optimistic message while sending', (
    tester,
  ) async {
    final repo = _FakeMessagesRepository();
    await _pumpWithRepo(
      tester,
      const ChatThreadScreen(
        conversationId: 'conv_001',
        contactName: 'Angela Kia',
      ),
      repo,
    );

    await tester.enterText(find.byType(TextField), 'Booked for 10');
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Send message'));
    await tester.pumpAndSettle();

    expect(repo.sentBodies, ['Booked for 10']);
    expect(find.text('Booked for 10'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Booked for 10')).dy,
      greaterThan(tester.getTopLeft(find.text('Hello!')).dy),
    );

    repo.sendTextCompleter!.complete(
      Message(
        id: 'server_1',
        senderId: 'user_me',
        senderName: 'Me',
        type: MessageType.text,
        body: 'Booked for 10',
        sentAt: _stamp.add(const Duration(minutes: 1)),
        deliveryStatus: DeliveryStatus.sent,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Booked for 10'), findsOneWidget);
  });

  testWidgets('DetailsSectionCard expands and collapses body content', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DetailsSectionCard(
            leading: const Icon(Icons.folder_outlined),
            title: 'Shared Files',
            trailingCount: 1,
            body: const Text('Call sheet.pdf'),
          ),
        ),
      ),
    );

    expect(
      tester
          .widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade))
          .crossFadeState,
      CrossFadeState.showFirst,
    );

    await tester.tap(find.byIcon(Icons.folder_outlined));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade))
          .crossFadeState,
      CrossFadeState.showSecond,
    );

    await tester.tap(find.byIcon(Icons.folder_outlined));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade))
          .crossFadeState,
      CrossFadeState.showFirst,
    );
  });

  testWidgets('ChatDetailsScreen formats participant role labels', (
    tester,
  ) async {
    final repo = _FakeMessagesRepository();
    await _pumpWithRepo(
      tester,
      const ChatDetailsScreen(conversationId: 'conv_001'),
      repo,
    );

    expect(
      find.textContaining('Participants', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Angela Kia'), findsWidgets);
    expect(find.text('Creative Partner'), findsOneWidget);
    expect(find.text('cp'), findsNothing);
  });
}
