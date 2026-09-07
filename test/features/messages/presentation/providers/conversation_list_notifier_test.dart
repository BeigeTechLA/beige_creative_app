import 'dart:async';

import 'package:beige_creative_app/core/network/exceptions/exceptions.dart';
import 'package:beige_creative_app/core/providers/auth_state_provider.dart';
import 'package:beige_creative_app/core/providers/core_providers.dart';
import 'package:beige_creative_app/core/session/session_store.dart';
import 'package:beige_creative_app/features/messages/data/dto/conversation_dto.dart';
import 'package:beige_creative_app/features/messages/domain/entities/chat_details.dart';
import 'package:beige_creative_app/features/messages/domain/entities/chat_thread.dart';
import 'package:beige_creative_app/features/messages/domain/entities/conversation.dart';
import 'package:beige_creative_app/features/messages/domain/entities/message.dart';
import 'package:beige_creative_app/features/messages/domain/events/chat_socket_event.dart';
import 'package:beige_creative_app/features/messages/domain/repositories/messages_repository.dart';
import 'package:beige_creative_app/features/messages/presentation/providers/conversation_list_providers.dart';
import 'package:beige_creative_app/features/messages/presentation/providers/messages_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DriverRepo implements MessagesRepository {
  final StreamController<ChatSocketEvent> globalCtrl =
      StreamController.broadcast();
  int listCalls = 0;
  Object? listError;

  @override
  Future<List<Conversation>> listConversations({String? query}) async {
    listCalls++;
    if (listError != null) {
      throw listError!;
    }
    return [
      Conversation(
        id: 'room_1',
        title: 'Angela',
        unreadCount: 0,
        isOnline: false,
        participantIds: const [],
      ),
    ];
  }

  @override
  Future<ChatThread> fetchThread(String conversationId, {String? cursor}) =>
      throw UnimplementedError();

  @override
  Future<Message?> fetchLatestMessage(String conversationId) async => null;

  @override
  Stream<ChatSocketEvent> events(String conversationId) => const Stream.empty();

  @override
  Stream<ChatSocketEvent> globalEvents() => globalCtrl.stream;

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
          {String? replyToId}) =>
      throw UnimplementedError();

  @override
  Future<Message> sendAudio(String conversationId, String localPath,
          Duration duration) =>
      throw UnimplementedError();

  @override
  Future<Message> sendAttachment(String conversationId,
          {required String localPath,
          required String name,
          required String mimeType,
          required int sizeBytes}) =>
      throw UnimplementedError();

  @override
  Future<void> editMessage(
          String conversationId, String messageId, String newBody) =>
      throw UnimplementedError();

  @override
  Future<void> deleteMessage(String conversationId, String messageId) =>
      throw UnimplementedError();

  @override
  Future<void> markRead(String conversationId, String upToMessageId) =>
      throw UnimplementedError();

  @override
  Future<ChatDetails> fetchDetails(String conversationId) =>
      throw UnimplementedError();

  @override
  Future<({String emoji, String userId})> sendReaction({
    required String conversationId,
    required String messageId,
    required String emoji,
  }) async =>
      throw UnimplementedError();
}

void main() {
  late _DriverRepo repo;
  late ProviderContainer container;
  ProviderSubscription<ConversationListState>? activeSub;

  Future<void> hydrate() async {
    activeSub = container.listen<ConversationListState>(
      conversationListProvider,
      (_, _) {},
    );
    for (var i = 0; i < 20; i++) {
      if (!container.read(conversationListProvider).isLoading) break;
      await Future<void>.delayed(Duration.zero);
    }
  }

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = _DriverRepo();
    container = ProviderContainer(overrides: [
      messagesRepositoryProvider.overrideWithValue(repo),
      sessionStoreProvider.overrideWithValue(_FakeSession()),
      prefsProvider.overrideWithValue(prefs),
    ]);
  });

  tearDown(() async {
    activeSub?.close();
    activeSub = null;
    await repo.globalCtrl.close();
    container.dispose();
  });

  test('initial build fetches conversations once', () async {
    await hydrate();
    expect(repo.listCalls, 1);
    expect(container.read(conversationListProvider).items, hasLength(1));
  });

  test('global RoomPreviewUpdated triggers throttled refetch', () async {
    await hydrate();
    repo.listCalls = 0;

    repo.globalCtrl.add(const RoomPreviewUpdated('room_1'));
    // Throttle window is 500ms — wait past it.
    await Future<void>.delayed(
      kConversationRefreshThrottle + const Duration(milliseconds: 50),
    );

    expect(repo.listCalls, 1);
  });

  test('burst of events coalesces to a single refetch', () async {
    await hydrate();
    repo.listCalls = 0;

    // Fire 5 events within the throttle window — only one refetch should run.
    for (var i = 0; i < 5; i++) {
      repo.globalCtrl.add(const RoomPreviewUpdated('room_1'));
    }
    await Future<void>.delayed(
      kConversationRefreshThrottle + const Duration(milliseconds: 50),
    );

    expect(repo.listCalls, 1);
  });

  test('TypingStarted (non-list event) does NOT trigger refetch', () async {
    await hydrate();
    repo.listCalls = 0;

    repo.globalCtrl
        .add(const TypingStarted('room_1', 'user_angela', 'Angela'));
    await Future<void>.delayed(
      kConversationRefreshThrottle + const Duration(milliseconds: 50),
    );

    expect(repo.listCalls, 0);
  });

  test('ChatRoomCreated adds room directly without triggering API refetch', () async {
    await hydrate();
    repo.listCalls = 0;

    const newRoom = Conversation(
      id: 'room_new',
      title: 'New Project Room',
      unreadCount: 0,
      isOnline: false,
      participantIds: ['user_1'],
    );

    repo.globalCtrl.add(const ChatRoomCreated(newRoom));
    await Future<void>.delayed(
      kConversationRefreshThrottle + const Duration(milliseconds: 50),
    );

    expect(repo.listCalls, 0);
    final items = container.read(conversationListProvider).items;
    expect(items, hasLength(2));
    expect(items.first.id, 'room_new');
    expect(items.first.title, 'New Project Room');
  });

  test('ChatRoomCreated correctly parses user sample payload and prepends room', () async {
    await hydrate();
    repo.listCalls = 0;

    final samplePayload = {
      'success': true,
      'type': 'addedToChat',
      'event': 'chatRoomCreated',
      'roomId': 'room_id',
      'chatRoomId': 'room_id',
      'orderId': 'order_id',
      'externalOrderRef': 'booking_id',
      'name': 'corporate_rachana_#4511',
      'room': {
        'id': 'room_id',
        'chat_id': '688',
        'name': 'corporate_rachana_#4511',
        'client_snapshot': {
          'id': '720',
          'name': 'Client Name',
          'email': 'client@example.com',
          'role': 'client',
        },
        'cp_ids': [
          {
            'id': '555',
            'name': 'CP Name',
            'email': 'cp@example.com',
            'decision': 'pending',
            'role': 'cp',
          }
        ],
        'manager_ids': [],
        'production_ids': [],
        'order_id': 'order_id',
        'external_order_ref': '4511',
        'last_message': null,
        'status': 'active',
        'unread_counts': {},
        'createdAt': '2026-07-28T04:07:56.875Z',
        'updatedAt': '2026-07-28T04:07:56.875Z',
      },
      'createdBy': {
        'id': '288',
        'email': 'admin@beigecorporation.io',
        'name': 'Admin',
        'role': 'admin',
      },
      'createdAt': '2026-07-28T04:07:56.875Z',
    };

    final roomRaw = samplePayload['room'] as Map<String, dynamic>;
    final conversation = ConversationDto.fromRestJson(
      roomRaw,
      currentUserId: '555',
    );

    repo.globalCtrl.add(ChatRoomCreated(conversation));
    await Future<void>.delayed(
      kConversationRefreshThrottle + const Duration(milliseconds: 50),
    );

    expect(repo.listCalls, 0);
    final items = container.read(conversationListProvider).items;
    expect(items, hasLength(2));
    expect(items.first.id, 'room_id');
    expect(items.first.title, 'corporate_rachana_#4511');
    expect(items.first.linkedShootId, '4511');
    expect(items.first.participantIds, containsAll(['555', '720']));
  });

  test('unauthorized exception triggers session logout', () async {
    repo.listError = const UnauthorizedException();

    container.read(authStateProvider.notifier).markLoggedIn();
    expect(container.read(authStateProvider), true);

    activeSub = container.listen<ConversationListState>(
      conversationListProvider,
      (_, _) {},
    );

    for (var i = 0; i < 20; i++) {
      if (!container.read(conversationListProvider).isLoading) break;
      await Future<void>.delayed(Duration.zero);
    }

    expect(container.read(authStateProvider), false);
  });
}

class _FakeSession implements SessionStore {
  @override
  Future<void> writeToken(String token) async {}
  @override
  Future<void> writeUser(UserSnapshot user) async {}
  @override
  Future<void> writeLastLoginAt(DateTime when) async {}
  @override
  Future<String?> readToken() async => null;
  @override
  Future<void> clearToken() async {}
  @override
  Future<String?> readRefreshToken() async => null;
  @override
  Future<void> writeRefreshToken(String token) async {}
  @override
  Future<void> clearRefreshToken() async {}
  @override
  Future<String?> readFcmToken() async => null;
  @override
  Future<void> writeFcmToken(String fcmToken) async {}
  @override
  Future<void> clearFcmToken() async {}
  @override
  Future<String> getAppSessionId() async => 'fake-app-session-id';
  @override
  Future<void> clearAppSessionId() async {}
  @override
  Future<UserSnapshot?> readUser() async => null;
  @override
  UserSnapshot? readUserSync() => null;
  @override
  Future<void> clearUser() async {}
  @override
  Future<DateTime?> readLastLoginAt() async => null;
  @override
  Future<bool> readOnboardingSeen() async => false;
  @override
  Future<void> writeOnboardingSeen(bool seen) async {}
  @override
  Future<bool> isLoggedIn() async => false;
  @override
  Future<void> clearSession() async {}
}
