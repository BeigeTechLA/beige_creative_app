import 'package:beige_creative_app/core/network/api_endpoints.dart';
import 'package:beige_creative_app/features/shoots/data/repositories/shoots_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_data.dart';

/// AAA pattern. `DioClient.dio` returns `MockDio`; tests verify captured
/// path/body and assert on the parsed return value or thrown error.
Response<dynamic> _ok(Map<String, dynamic> body, {String path = '/'}) =>
    Response<dynamic>(
      requestOptions: RequestOptions(path: path),
      data: body,
      statusCode: 200,
    );

DioException _dioError({
  required String path,
  int? statusCode,
  DioExceptionType type = DioExceptionType.badResponse,
}) {
  final req = RequestOptions(path: path);
  return DioException(
    requestOptions: req,
    type: type,
    response: statusCode == null
        ? null
        : Response<dynamic>(requestOptions: req, statusCode: statusCode),
  );
}

Map<String, dynamic> _projectDetailPayload({int projectId = 7}) => {
      'error': false,
      'message': 'ok',
      'data': {
        'project': {
          'project_id': projectId,
          'project_name': 'Skyline',
          'status': 'confirmed',
          'image_url': null,
          'event_date': '2026-06-15',
          'start_time': '09:00',
          'end_time': '17:00',
          'event_location': 'NYC',
          'shoot_type': 'Editorial',
          'booking_type': 'Solo',
          'last_updated': null,
          'total_time_duration_hours': 8,
          'budget': 1200,
          'total_amount': 1200,
          'id_label': '#$projectId',
        },
        'payment_state': 'pending',
        'team_members': <Map<String, dynamic>>[],
        'team_summary': {'assigned_count': 1, 'total_required': 2},
        'client_contact': {
          'full_name': 'Client X',
          'email': 'c@x.io',
          'phone': '555',
        },
      },
    };

Map<String, dynamic> _shootCountPayload({
  int completed = 10,
  int pending = 4,
  int confirmed = 6,
  int rejected = 1,
}) =>
    {
      'error': false,
      'message': 'ok',
      'data': {
        'completedShoots': completed,
        'pendingRequests': pending,
        'confirmedRequests': confirmed,
        'rejectedRequests': rejected,
      },
    };

void main() {
  late MockDioClient client;
  late MockDio dio;
  late ShootsRepositoryImpl repo;

  setUpAll(registerHelperFallbacks);

  setUp(() {
    client = MockDioClient();
    dio = MockDio();
    when(() => client.dio).thenReturn(dio);
    repo = ShootsRepositoryImpl(client);
  });

  group('fetchProjectDetail', () {
    test('happy: parses MyData with project + team summary', () async {
      when(() => dio.get<dynamic>(any()))
          .thenAnswer((_) async => _ok(_projectDetailPayload(projectId: 42)));

      final data = await repo.fetchProjectDetail(42);

      expect(data.project.projectId, 42);
      expect(data.paymentStatus, 'pending');
      expect(data.teamSummary.assignedCount, 1);
      final url = verify(() => dio.get<dynamic>(captureAny())).captured.single;
      expect(url, ApiEndpoints.projectDetails(42));
    });

    test('error envelope → throws server message', () async {
      when(() => dio.get<dynamic>(any()))
          .thenAnswer((_) async => _ok(errorResponse(message: 'not found')));

      await expectLater(
        repo.fetchProjectDetail(99),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('not found'))),
      );
    });

    test('non-Map payload → throws', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/'),
          data: 'not a map',
          statusCode: 200,
        ),
      );

      await expectLater(
        repo.fetchProjectDetail(1),
        throwsA(isA<Exception>()),
      );
    });

    test('401 → DioException propagates', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(
        _dioError(path: ApiEndpoints.projectDetails(1), statusCode: 401),
      );

      await expectLater(
        repo.fetchProjectDetail(1),
        throwsA(isA<DioException>()),
      );
    });

    test('5xx → DioException propagates', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(
        _dioError(path: ApiEndpoints.projectDetails(1), statusCode: 500),
      );

      await expectLater(
        repo.fetchProjectDetail(1),
        throwsA(isA<DioException>()),
      );
    });

    test('cancel → DioException(type=cancel) propagates', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(
        _dioError(
          path: ApiEndpoints.projectDetails(1),
          type: DioExceptionType.cancel,
        ),
      );

      await expectLater(
        repo.fetchProjectDetail(1),
        throwsA(predicate(
            (e) => e is DioException && e.type == DioExceptionType.cancel)),
      );
    });
  });

  group('respondToProject', () {
    test('happy: posts project_id + status, omits null reason/comment',
        () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok({'error': false}));

      await repo.respondToProject(projectId: 7, status: 'accepted');

      final captured = verify(
        () => dio.post<dynamic>(captureAny(), data: captureAny(named: 'data')),
      ).captured;
      expect(captured.first, ApiEndpoints.acceptdeclineproject);
      expect(captured.last, {
        'project_id': 7,
        'crew_accept': 1,
      });
    });

    test('happy: includes reason + comment when provided', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok({'error': false}));

      await repo.respondToProject(
        projectId: 9,
        status: 'declined',
        reason: 'unavailable',
        comment: 'next week',
      );

      final body = verify(
        () => dio.post<dynamic>(any(), data: captureAny(named: 'data')),
      ).captured.single;
      expect(body, {
        'project_id': 9,
        'crew_accept': 2,
        'reason': 'unavailable',
        'comment': 'next week',
      });
    });

    test('error envelope → throws', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok(errorResponse(message: 'too late')));

      await expectLater(
        repo.respondToProject(projectId: 7, status: 'accepted'),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('too late'))),
      );
    });

    test('cancel → DioException propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _dioError(
          path: ApiEndpoints.acceptdeclineproject,
          type: DioExceptionType.cancel,
        ),
      );

      await expectLater(
        repo.respondToProject(projectId: 7, status: 'accepted'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('fetchShoots', () {
    test('happy: parses shoots list', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => _ok(shootsListResponse(shoots: [
          singleShootJson(id: 1, projectName: 'A'),
          singleShootJson(id: 2, projectName: 'B'),
        ])),
      );

      final shoots = await repo.fetchShoots();

      expect(shoots.map((s) => s.id).toList(), [1, 2]);
      expect(shoots.first.projectName, 'A');
      verify(() => dio.get<dynamic>(ApiEndpoints.creatordashboarddetails))
          .called(1);
    });

    test('error envelope → throws server message', () async {
      when(() => dio.get<dynamic>(any()))
          .thenAnswer((_) async => _ok(errorResponse(message: 'forbidden')));

      await expectLater(
        repo.fetchShoots(),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('forbidden'))),
      );
    });

    test('5xx → DioException propagates', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(
        _dioError(
          path: ApiEndpoints.creatordashboarddetails,
          statusCode: 503,
        ),
      );

      await expectLater(repo.fetchShoots(), throwsA(isA<DioException>()));
    });
  });

  group('fetchShootCount', () {
    test('happy: parses count payload', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => _ok(_shootCountPayload(completed: 12)),
      );

      final data = await repo.fetchShootCount();

      expect(data.completedShoots, 12);
      expect(data.confirmedRequests, 6);
      verify(() => dio.get<dynamic>(ApiEndpoints.myshootcount)).called(1);
    });

    test('error envelope → throws', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => _ok({
          'error': true,
          'message': 'denied',
          'data': {
            'completedShoots': 0,
            'pendingRequests': 0,
            'confirmedRequests': 0,
            'rejectedRequests': 0,
          },
        }),
      );

      await expectLater(
        repo.fetchShootCount(),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('denied'))),
      );
    });

    test('cancel → DioException propagates', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(
        _dioError(
          path: ApiEndpoints.myshootcount,
          type: DioExceptionType.cancel,
        ),
      );

      await expectLater(
        repo.fetchShootCount(),
        throwsA(predicate(
            (e) => e is DioException && e.type == DioExceptionType.cancel)),
      );
    });
  });
}
