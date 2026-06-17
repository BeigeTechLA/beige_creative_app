import 'package:beige_creative_app/core/network/api_endpoints.dart';
import 'package:beige_creative_app/core/network/exceptions/exceptions.dart';
import 'package:beige_creative_app/core/session/session_store.dart';
import 'package:beige_creative_app/features/meetings/data/sources/meetings_remote_source.dart';
import 'package:beige_creative_app/features/meetings/domain/models/create_meeting_input.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_category.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_platform.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_status.dart';
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

Map<String, dynamic> _meetingJson({
  String id = '36',
  String title = 'Test Meeting',
  String status = 'pending',
  String type = 'post_production',
  String link = 'https://meet.google.com/azi-kwdf-tuo',
  List<Map<String, dynamic>> participants = const [],
}) => {
  'id': id,
  'meeting_status': status,
  'meeting_date_time': '2026-06-11T13:30:00.000Z',
  'meeting_end_time': '2026-06-11T14:30:00.000Z',
  'meeting_type': type,
  'meeting_title': title,
  'description': 'desc',
  'meetLink': link,
  'duration': 60,
  'order': {'id': 4434, 'name': 'Project X'},
  'client': null,
  'admin': null,
  'cps': const [],
  'participants': participants,
  'created_by': null,
  'participant_responses': const [],
  'change_request': null,
};

void main() {
  late MockDioClient client;
  late MockDio dio;
  late MockSessionStore session;
  late MeetingsRemoteSource source;

  const me = UserSnapshot(id: '248', name: 'Me', role: 'creative');

  setUpAll(registerHelperFallbacks);

  setUp(() {
    client = MockDioClient();
    dio = MockDio();
    session = MockSessionStore();
    when(() => client.dio).thenReturn(dio);
    when(session.readUser).thenAnswer((_) async => me);
    source = MeetingsRemoteSource(client, session);
  });

  group('list', () {
    test('GET external-meetings — envelope maps to MeetingsPage', () async {
      when(
        () => dio.get<dynamic>(
          ApiEndpoints.meetings,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok({
          'results': [_meetingJson(id: '34')],
          'page': 1,
          'limit': 100,
          'totalPages': 1,
          'totalResults': 1,
        }),
      );

      final page = await source.list();

      expect(page.items, hasLength(1));
      expect(page.items.first.id, '34');
      expect(page.items.first.platform, MeetingPlatform.meet);
      expect(page.hasMore, isFalse);
    });

    test('forwards page/limit/sortBy as query params', () async {
      when(
        () => dio.get<dynamic>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _ok({'results': []}));

      await source.list(page: 2, limit: 50, sortBy: 'foo:asc');

      final captured =
          verify(
                () => dio.get<dynamic>(
                  ApiEndpoints.meetings,
                  queryParameters: captureAny(named: 'queryParameters'),
                ),
              ).captured.single
              as Map;
      expect(captured['page'], 2);
      expect(captured['limit'], 50);
      expect(captured['sortBy'], 'foo:asc');
    });

    test('DioException 500 → ServerException', () async {
      when(
        () => dio.get<dynamic>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(_serverError(statusCode: 500));

      expect(() => source.list(), throwsA(isA<ServerException>()));
    });
  });

  group('getById', () {
    test('GET external-meetings/:id returns mapped Meeting', () async {
      when(
        () => dio.get<dynamic>(ApiEndpoints.meetingById('36')),
      ).thenAnswer((_) async => _ok(_meetingJson(id: '36', title: 'X')));

      final m = await source.getById('36');

      expect(m.id, '36');
      expect(m.title, 'X');
      expect(m.status, MeetingStatus.upcoming); // 'pending' → upcoming
    });
  });

  group('create', () {
    test('POST omits participants/duration, sends created_by_id', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => _ok(_meetingJson(id: '99')),
      );

      final input = CreateMeetingInput(
        title: 'New',
        description: 'd',
        project: 'p',
        startAt: DateTime.utc(2026, 6, 11, 13, 30),
        endAt: DateTime.utc(2026, 6, 11, 14, 30),
        platform: MeetingPlatform.meet,
        link: 'https://meet.google.com/x',
        reminderMinutes: 15,
        category: MeetingCategory.commercial,
        participants: const [],
      );
      final m = await source.create(input);

      expect(m.id, '99');
      final captured = verify(
        () => dio.post<dynamic>(
          ApiEndpoints.meetings,
          data: captureAny(named: 'data'),
        ),
      ).captured.single as Map;
      expect(captured.containsKey('participants'), isFalse);
      expect(captured.containsKey('duration'), isFalse);
      expect(captured['created_by_id'], 248);
      expect(captured['meeting_title'], 'New');
      expect(captured['meeting_status'], 'pending');
      expect(captured['meetLink'], 'https://meet.google.com/x');
      expect(captured['cp_ids'], <int>[]);
      expect(captured['send_notification'], true);
      expect(captured['reminder_minutes'], 15);
    });
  });

  group('addParticipants', () {
    test('POST body uses role + string user_ids', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => _ok(
          _meetingJson(
            id: '36',
            participants: [
              {'id': 4, 'name': 'Punya', 'email': 'p@y.com', 'role': 'participant'},
            ],
          ),
        ),
      );

      final m = await source.addParticipants('36', const ['4', '7']);

      expect(m.participants, hasLength(1));
      expect(m.participants.first.id, '4');
      final captured = verify(
        () => dio.post<dynamic>(
          ApiEndpoints.meetingParticipants('36'),
          data: captureAny(named: 'data'),
        ),
      ).captured.single as Map;
      expect(captured['role'], 'participant');
      expect(captured['user_ids'], ['4', '7']);
    });
  });

  group('update', () {
    test('PATCH strips duration defensively', () async {
      when(() => dio.patch<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => _ok(_meetingJson(id: '12', title: 'Renamed')),
      );

      final m = await source.update('12', {
        'meeting_title': 'Renamed',
        'duration': 120, // should be stripped
      });

      expect(m.title, 'Renamed');
      final captured = verify(
        () => dio.patch<dynamic>(
          ApiEndpoints.meetingById('12'),
          data: captureAny(named: 'data'),
        ),
      ).captured.single as Map;
      expect(captured.containsKey('duration'), isFalse);
      expect(captured['meeting_title'], 'Renamed');
    });
  });

  group('delete', () {
    test('DELETE external-meetings/:id returns void on 2xx', () async {
      when(() => dio.delete<dynamic>(any())).thenAnswer(
        (_) async => _ok(<String, dynamic>{}),
      );

      await expectLater(source.delete('6'), completes);
      verify(() => dio.delete<dynamic>(ApiEndpoints.meetingById('6'))).called(1);
    });
  });

}
