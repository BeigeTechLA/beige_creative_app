import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/exceptions.dart';
import '../../../../core/session/session_store.dart';
import '../../domain/entities/chat_details.dart';
import '../../domain/entities/chat_thread.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../dto/chat_details_dto.dart';
import '../dto/conversation_dto.dart';
import '../dto/message_dto.dart';
import '../dto/pagination_envelope.dart';

/// REST source. Implements `external-chat/*` endpoints via `dioClientProvider`.
///
/// All methods translate `DioException` → typed `AppException` via
/// [ExceptionHandler.mapDioException] so the notifier layer sees the same
/// error taxonomy as the rest of the app.
///
/// `currentUserId` is resolved per-call from [SessionStore] — needed by DTOs
/// to derive `fromMe` / read-receipt-based delivery status.
class MessagesRemoteSource {
  MessagesRemoteSource(this._client, this._session);

  final DioClient _client;
  final SessionStore _session;

  Dio get _dio => _client.dio;

  /// Used only for client-side `fromMe` / read-receipt derivation in DTOs.
  /// REST auth itself rides the bearer token attached by the Dio interceptor —
  /// the userId here never goes on the wire. Backend login may not return a
  /// user object, so fall back to empty string (degrades to "not me" for
  /// preview text + "delivered" for receipts until login persists the user).
  Future<String> _currentUserId() async {
    final user = await _session.readUser();
    return user?.id ?? '';
  }

  /// Single funnel for `DioException` → `AppException`. Keeps method bodies
  /// linear.
  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DioException catch (e, st) {
      throw ExceptionHandler.mapDioException(e, st);
    }
  }

  Future<List<Conversation>> listConversations({String? query}) {
    return _guard(() async {
      final userId = await _currentUserId();
      final resp = await _dio.get<dynamic>(
        ApiEndpoints.chatRooms,
        queryParameters: {
          'page': 1,
          'limit': 50,
          if (query != null && query.isNotEmpty) 'search': query,
        },
      );
      final rooms = PaginationEnvelope.unwrapList(resp.data);
      return rooms
          .map((r) => ConversationDto.fromRestJson(r, currentUserId: userId))
          .toList(growable: false);
    });
  }

  /// Latest single message for room. Used by list-screen preview hydration —
  /// backend's `/rooms` payload ships `last_message` as ID-only.
  Future<Message?> fetchLatestMessage(String conversationId) {
    return _guard(() async {
      final userId = await _currentUserId();
      final resp = await _dio.get<dynamic>(
        ApiEndpoints.chatMessages(conversationId),
        queryParameters: {
          'page': 1,
          'limit': 1,
          'sortBy': '-createdAt',
        },
      );
      final list = PaginationEnvelope.unwrapList(resp.data);
      if (list.isEmpty) return null;
      return MessageDto.fromRestJson(list.first, currentUserId: userId);
    });
  }

  Future<ChatThread> fetchThread(String conversationId, {String? cursor}) {
    return _guard(() async {
      final userId = await _currentUserId();
      const limit = 30;
      final resp = await _dio.get<dynamic>(
        ApiEndpoints.chatMessages(conversationId),
        queryParameters: {
          'page': int.tryParse(cursor ?? '') ?? 1,
          'limit': limit,
          'sortBy': '-createdAt',
        },
      );
      final raw = resp.data;
      final messagesRaw = PaginationEnvelope.unwrapList(raw);
      // Backend serves newest-first; thread renders chronological asc.
      final messages = messagesRaw.reversed
          .map((m) => MessageDto.fromRestJson(m, currentUserId: userId))
          .toList(growable: false);

      String? nextCursor;
      if (PaginationEnvelope.hasMore(raw, limit: limit)) {
        final nextRaw = PaginationEnvelope.nextCursor(raw);
        nextCursor =
            nextRaw ??
            (int.tryParse(cursor ?? '1') ?? 1).let((p) => (p + 1).toString());
      }

      return ChatThread(
        conversationId: conversationId,
        messages: messages,
        nextCursor: nextCursor,
      );
    });
  }

  Future<Message> sendText(
    String conversationId,
    String body, {
    String? replyToId,
  }) {
    return _guard(() async {
      // Backend expects the full sender block + an empty-string `replyTo`
      // (not null / absent) for non-reply sends. Matches web-chat contract:
      // {"message": "...", "sender": {"id","name","email"}, "replyTo": ""}.
      final user = await _session.readUser();
      final userId = user?.id ?? '';
      final resp = await _dio.post<dynamic>(
        ApiEndpoints.chatMessages(conversationId),
        data: {
          'message': body,
          'sender': {
            'id': userId,
            'name': user?.name ?? '',
            'email': user?.email ?? '',
          },
          'replyTo': (replyToId == null || replyToId.isEmpty) ? '' : replyToId,
        },
      );
      final json = PaginationEnvelope.unwrapItem(resp.data);
      return MessageDto.fromRestJson(json, currentUserId: userId);
    });
  }

  /// POST `external-chat/messages/:messageId/reaction`.
  /// Body: `{emoji, roomId, sender: {id, name, email}}`.
  /// Returns the emoji + reactor id so the caller can patch state locally
  /// without waiting for the socket echo.
  Future<({String emoji, String userId})> sendReaction({
    required String messageId,
    required String roomId,
    required String emoji,
  }) {
    return _guard(() async {
      final user = await _session.readUser();
      final userId = user?.id ?? '';
      await _dio.post<dynamic>(
        ApiEndpoints.chatMessageReaction(messageId),
        data: {
          'emoji': emoji,
          'roomId': roomId,
          'sender': {
            'id': userId,
            'name': user?.name ?? '',
            'email': user?.email ?? '',
          },
        },
      );
      return (emoji: emoji, userId: userId);
    });
  }

  Future<Message> sendAudio(
    String conversationId,
    String localPath,
    Duration duration,
  ) {
    // Plan §11 Q3 — backend has no documented upload endpoint. Block until
    // confirmed; UI currently has no real audio capture either (M5 leaves
    // mic as bool toggle).
    throw UnimplementedError(
      'Audio upload not yet supported by backend (plan §11 Q3)',
    );
  }

  Future<Message> sendAttachment(
    String conversationId, {
    required String localPath,
    required String name,
    required String mimeType,
    required int sizeBytes,
  }) {
    // Plan §11 Q3 — same blocker as sendAudio.
    throw UnimplementedError(
      'Attachment upload not yet supported by backend (plan §11 Q3)',
    );
  }

  Future<void> editMessage(
    String conversationId,
    String messageId,
    String newBody,
  ) {
    return _guard(() async {
      // Body key is `content` (not `message`) per REST §14 — flagged
      // inconsistency, deliberate.
      await _dio.post<dynamic>(
        ApiEndpoints.chatEditMessage(messageId),
        data: {'content': newBody, 'roomId': conversationId},
      );
    });
  }

  Future<void> deleteMessage(String conversationId, String messageId) {
    return _guard(() async {
      await _dio.post<dynamic>(
        ApiEndpoints.chatDeleteMessage(messageId),
        data: {'roomId': conversationId},
      );
    });
  }

  Future<void> markRead(String conversationId, String upToMessageId) {
    return _guard(() async {
      // REST spec defines no body / no `upTo` field — backend marks the
      // whole room as read for the caller. `upToMessageId` is currently
      // unused; keep on the signature for future per-message granularity.
      await _dio.patch<dynamic>(ApiEndpoints.chatMarkRead(conversationId));
    });
  }

  Future<ChatDetails> fetchDetails(String conversationId) {
    return _guard(() async {
      final resp = await _dio.get<dynamic>(
        ApiEndpoints.chatRoomDetails(conversationId),
      );
      final json = PaginationEnvelope.unwrapItem(resp.data);
      return ChatDetailsDto.fromRestJson(json, conversationId: conversationId);
    });
  }
}

extension<T> on T {
  R let<R>(R Function(T it) body) => body(this);
}
