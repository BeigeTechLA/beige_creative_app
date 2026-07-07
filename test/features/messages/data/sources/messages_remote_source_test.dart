import 'package:beige_creative_app/core/network/api_endpoints.dart';
import 'package:beige_creative_app/core/network/exceptions/exceptions.dart';
import 'package:beige_creative_app/core/session/session_store.dart';
import 'package:beige_creative_app/features/messages/data/sources/messages_remote_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

Response<dynamic> _ok(dynamic body, {String path = '/'}) => Response<dynamic>(
  requestOptions: RequestOptions(path: path),
  data: body,
  statusCode: 200,
);

DioException _serverError({String path = '/', int statusCode = 500}) {
  final req = RequestOptions(path: path);
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(requestOptions: req, statusCode: statusCode),
  );
}

void main() {
  late MockDioClient client;
  late MockDio dio;
  late MockSessionStore session;
  late MessagesRemoteSource source;

  const me = UserSnapshot(id: 'user_me', name: 'Me', role: 'crew');

  setUpAll(registerHelperFallbacks);

  setUp(() {
    client = MockDioClient();
    dio = MockDio();
    session = MockSessionStore();
    when(() => client.dio).thenReturn(dio);
    when(session.readUser).thenAnswer((_) async => me);
    source = MessagesRemoteSource(client, session);
  });

  group('listConversations', () {
    test(
      'GET /external-chat/rooms — bare list maps to Conversation list',
      () async {
        when(
          () => dio.get<dynamic>(
            ApiEndpoints.chatRooms,
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => _ok([
            {
              'id': 'room_1',
              'name': 'Angela',
              'unread_counts': {'user_me': 2},
              'is_online': true,
              'updated_at': '2026-06-14T10:00:00.000Z',
              'participants': ['user_me', 'user_angela'],
              'last_message': {
                'message': 'hi',
                'sent_at': '2026-06-14T10:00:00.000Z',
                'sent_by': 'user_angela',
              },
            },
          ]),
        );

        final result = await source.listConversations();

        expect(result, hasLength(1));
        expect(result.first.id, 'room_1');
        expect(result.first.title, 'Angela');
        expect(result.first.unreadCount, 2);
        expect(result.first.lastMessage?.fromMe, isFalse);
      },
    );

    test('passes search query as `search` param', () async {
      when(
        () => dio.get<dynamic>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _ok([]));

      await source.listConversations(query: 'angela');

      final captured =
          verify(
                () => dio.get<dynamic>(
                  ApiEndpoints.chatRooms,
                  queryParameters: captureAny(named: 'queryParameters'),
                ),
              ).captured.single
              as Map;
      expect(captured['search'], 'angela');
    });

    test('DioException 500 → ServerException', () async {
      when(
        () => dio.get<dynamic>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(_serverError(statusCode: 500));

      expect(() => source.listConversations(), throwsA(isA<ServerException>()));
    });
  });

  group('fetchThread', () {
    test('reverses backend newest-first list to chronological asc', () async {
      when(
        () => dio.get<dynamic>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok([
          {
            '_id': 'm_2',
            'sent_by': 'user_angela',
            'sent_by_name': 'Angela',
            'message': 'second',
            'message_type': 'text',
            'createdAt': '2026-06-14T10:01:00.000Z',
          },
          {
            '_id': 'm_1',
            'sent_by': 'user_me',
            'sent_by_name': 'Me',
            'message': 'first',
            'message_type': 'text',
            'createdAt': '2026-06-14T10:00:00.000Z',
          },
        ]),
      );

      final thread = await source.fetchThread('room_1');

      expect(thread.messages.map((m) => m.id).toList(), ['m_1', 'm_2']);
    });
  });

  group('sendText', () {
    test('POST body uses `message` + `replyTo` keys', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => _ok({
          '_id': 'm_99',
          'sent_by': 'user_me',
          'sent_by_name': 'Me',
          'message': 'hi',
          'message_type': 'text',
          'createdAt': '2026-06-14T10:00:00.000Z',
        }),
      );

      await source.sendText('room_1', 'hi', replyToId: 'm_3');

      final captured = verify(
        () => dio.post<dynamic>(
          ApiEndpoints.chatMessages('room_1'),
          data: captureAny(named: 'data'),
        ),
      ).captured.single as Map;
      expect(captured, {
        'message': 'hi',
        'sender': {
          'id': 'user_me',
          'name': 'Me',
          'email': '',
        },
        'replyTo': 'm_3',
      });
    });
  });

  group('editMessage', () {
    test(
      'POST body uses `content` key (not `message`) + carries `roomId`',
      () async {
        when(
          () => dio.post<dynamic>(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => _ok(<String, dynamic>{}));

        await source.editMessage('room_1', 'm_5', 'updated');

        final captured =
            verify(
                  () => dio.post<dynamic>(
                    ApiEndpoints.chatEditMessage('m_5'),
                    data: captureAny(named: 'data'),
                  ),
                ).captured.single
                as Map;
        expect(captured, {'content': 'updated', 'roomId': 'room_1'});
      },
    );
  });

  group('deleteMessage', () {
    test('POST body carries `roomId`', () async {
      when(
        () => dio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _ok(<String, dynamic>{}));

      await source.deleteMessage('room_1', 'm_5');

      final captured =
          verify(
                () => dio.post<dynamic>(
                  ApiEndpoints.chatDeleteMessage('m_5'),
                  data: captureAny(named: 'data'),
                ),
              ).captured.single
              as Map;
      expect(captured, {'roomId': 'room_1'});
    });
  });

  group('markRead', () {
    test('PATCH /external-chat/room/:roomId/mark-read — no body', () async {
      when(
        () => dio.patch<dynamic>(any()),
      ).thenAnswer((_) async => _ok(<String, dynamic>{}));

      await source.markRead('room_1', 'm_9');

      verify(
        () => dio.patch<dynamic>(ApiEndpoints.chatMarkRead('room_1')),
      ).called(1);
    });
  });

  group('fetchDetails', () {
    test('GET /external-chat/room/:roomId/details — maps response', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => _ok({
          'success': true,
          'data': {
            'room': {'id': 'room_1', 'display_name': 'corporate_krunal_#4727'},
            'profile': {
              'id': '133',
              'name': 'Angela',
              'email': 'angela@example.com',
              'phone': '8956320147',
              'profileImage': null,
            },
            'participants': {
              'count': 1,
              'items': [
                {
                  'id': 'user_angela',
                  'name': 'Angela',
                  'email': 'angela@example.com',
                  'role': 'client',
                  'profileImage': null,
                },
              ],
            },
            'sharedFiles': {'count': 0, 'items': const []},
          },
        }),
      );

      final details = await source.fetchDetails('room_1');

      expect(details.conversationId, 'room_1');
      expect(details.contact.name, 'Angela');
      expect(details.contact.email, 'angela@example.com');
      expect(details.participants, hasLength(1));
      expect(details.participants.first.id, 'user_angela');
      expect(details.participants.first.role, 'client');
    });
  });

  group('auth', () {
    test('missing local user still fetches conversations', () async {
      when(session.readUser).thenAnswer((_) async => null);
      when(
        () => dio.get<dynamic>(
          ApiEndpoints.chatRooms,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok([
          {
            'id': 'room_1',
            'name': 'Angela',
            'unread_counts': {'user_me': 2},
            'updated_at': '2026-06-14T10:00:00.000Z',
          },
        ]),
      );

      final result = await source.listConversations();

      expect(result, hasLength(1));
      expect(result.first.id, 'room_1');
      expect(result.first.unreadCount, 0);
      verify(
        () => dio.get<dynamic>(
          ApiEndpoints.chatRooms,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(1);
    });
  });

  group('audio/attachment uploads', () {
    test(
      'sendAudio throws UnimplementedError (backend endpoint pending)',
      () async {
        expect(
          () => source.sendAudio(
            'room_1',
            '/tmp/voice.m4a',
            const Duration(seconds: 5),
          ),
          throwsA(isA<UnimplementedError>()),
        );
      },
    );

    test(
      'sendAttachment throws UnimplementedError (backend endpoint pending)',
      () async {
        expect(
          () => source.sendAttachment(
            'room_1',
            localPath: '/tmp/file.pdf',
            name: 'file.pdf',
            mimeType: 'application/pdf',
            sizeBytes: 1024,
          ),
          throwsA(isA<UnimplementedError>()),
        );
      },
    );
  });
}
