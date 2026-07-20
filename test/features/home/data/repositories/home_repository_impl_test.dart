import 'package:beige_creative_app/core/network/api_endpoints.dart';
import 'package:beige_creative_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_data.dart';

/// AAA pattern. Each test stubs DioClient.dio = MockDio and asserts both the
/// path/body that hit Dio and the parsed return value from the repo method.
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

Map<String, dynamic> _upcomingShootJson({
  int projectId = 11,
  String projectName = 'Skyline',
  String eventDate = '2026-06-15',
}) =>
    {
      'shoot_type': 'Editorial',
      'shoot_type_image_url': '',
      'project_id': projectId,
      'project_name': projectName,
      'event_date': eventDate,
      'start_time': '09:00',
      'end_time': '17:00',
      'event_location': 'NYC',
      'budget': 1200,
      'is_completed': false,
    };

Map<String, dynamic> _crewStatsResponse() => {
      'error': false,
      'message': 'ok',
      'data': {
        'completedShoots': 10,
        'pendingShoots': 2,
        'rejectedShoots': 1,
        'shootRequests': 4,
        'photographyShoots': 6,
        'videographyShoots': 4,
      },
    };

void main() {
  late MockDioClient client;
  late MockDio dio;
  late HomeRepositoryImpl repo;

  setUpAll(registerHelperFallbacks);

  setUp(() {
    client = MockDioClient();
    dio = MockDio();
    when(() => client.dio).thenReturn(dio);
    repo = HomeRepositoryImpl(client);
  });

  group('fetchCreatorDashboard', () {
    test('happy: parses consolidated dashboard payload', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => _ok({
          'error': false,
          'message': 'Dashboard details fetched successfully',
          'data': {
            'dashboard_counts': {
              'completedShoots': 5,
              'upcomingShoots': 2,
              'pendingRequests': 1,
              'equipmentRequests': 0,
            },
            'crew_stats': _crewStatsResponse()['data'],
            'failed_sections': [],
          },
        }),
      );

      final data = await repo.fetchCreatorDashboard(
        statsDateFilter: 'this_month',
        categoriesTab: 'photo',
        availabilityMonth: 7,
        availabilityYear: 2026,
      );

      expect(data.dashboardCounts?.completedShoots, 5);
      expect(data.crewStats?.completedShoots, 10);
      expect(data.failedSections, isEmpty);
    });

    test('error envelope → throws server message', () async {
      when(() => dio.get<dynamic>(any()))
          .thenAnswer((_) async => _ok(errorResponse(message: 'unauthorized')));

      await expectLater(
        repo.fetchCreatorDashboard(
          statsDateFilter: 'this_month',
          categoriesTab: 'photo',
          availabilityMonth: 7,
          availabilityYear: 2026,
        ),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('unauthorized'))),
      );
    });
  });

  group('fetchDashboardCount', () {
    test('happy: parses count payload', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => _ok(dashboardCountResponse(
          completed: 8,
          upcoming: 3,
          pending: 1,
          equipment: 0,
        )),
      );

      final data = await repo.fetchDashboardCount();

      expect(data.completedShoots, 8);
      expect(data.upcomingShoots, 3);
      expect(data.pendingRequests, 1);
      verify(() => dio.get<dynamic>(ApiEndpoints.dashboardcount)).called(1);
    });

    test('error envelope → throws server message', () async {
      when(() => dio.get<dynamic>(any()))
          .thenAnswer((_) async => _ok(errorResponse(message: 'no perms')));

      await expectLater(
        repo.fetchDashboardCount(),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('no perms'))),
      );
    });

    test('5xx → DioException propagates', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(
        _dioError(path: ApiEndpoints.dashboardcount, statusCode: 500),
      );

      await expectLater(
        repo.fetchDashboardCount(),
        throwsA(isA<DioException>()),
      );
    });

    test('cancel → DioException propagates', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(
        _dioError(
          path: ApiEndpoints.dashboardcount,
          type: DioExceptionType.cancel,
        ),
      );

      await expectLater(
        repo.fetchDashboardCount(),
        throwsA(predicate(
            (e) => e is DioException && e.type == DioExceptionType.cancel)),
      );
    });
  });

  group('fetchUpcomingShoots', () {
    test('happy: parses list and preserves order', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => _ok({
          'error': false,
          'message': 'ok',
          'data': [
            _upcomingShootJson(projectId: 1, projectName: 'A'),
            _upcomingShootJson(projectId: 2, projectName: 'B'),
          ],
        }),
      );

      final list = await repo.fetchUpcomingShoots();

      expect(list.map((e) => e.projectId).toList(), [1, 2]);
      verify(() => dio.get<dynamic>(ApiEndpoints.upcomingshoots)).called(1);
    });

    test('error envelope → throws', () async {
      when(() => dio.get<dynamic>(any()))
          .thenAnswer((_) async => _ok(errorResponse(message: 'oops')));

      await expectLater(
        repo.fetchUpcomingShoots(),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('oops'))),
      );
    });

    test('401 → DioException propagates', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(
        _dioError(path: ApiEndpoints.upcomingshoots, statusCode: 401),
      );

      await expectLater(
        repo.fetchUpcomingShoots(),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('fetchPendingRequests', () {
    test('happy: filters to pending status only', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => _ok(shootsListResponse(shoots: [
          singleShootJson(id: 1, status: 'Pending'),
          singleShootJson(id: 2, status: 'confirmed'),
          singleShootJson(id: 3, status: 'pending '),
        ])),
      );

      final pending = await repo.fetchPendingRequests();

      expect(pending.map((e) => e.id).toList(), [1, 3]);
      verify(() => dio.get<dynamic>(ApiEndpoints.creatordashboarddetails))
          .called(1);
    });

    test('error envelope → throws', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => _ok(errorResponse(message: 'no access')),
      );

      await expectLater(
        repo.fetchPendingRequests(),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('no access'))),
      );
    });

    test('cancel → DioException propagates', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(
        _dioError(
          path: ApiEndpoints.creatordashboarddetails,
          type: DioExceptionType.cancel,
        ),
      );

      await expectLater(
        repo.fetchPendingRequests(),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('fetchCrewStats', () {
    test('happy: applies filter to URL and parses', () async {
      when(() => dio.get<dynamic>(any()))
          .thenAnswer((_) async => _ok(_crewStatsResponse()));

      final stats = await repo.fetchCrewStats('this_month');

      expect(stats.completedShoots, 10);
      expect(stats.shootRequests, 4);
      final url = verify(() => dio.get<dynamic>(captureAny())).captured.single;
      expect(url, ApiEndpoints.crewStats('this_month'));
    });

    test('error envelope → throws', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => _ok({
          'error': true,
          'message': 'bad filter',
          'data': {
            'completedShoots': 0,
            'pendingShoots': 0,
            'rejectedShoots': 0,
            'shootRequests': 0,
            'photographyShoots': 0,
            'videographyShoots': 0,
          },
        }),
      );

      await expectLater(
        repo.fetchCrewStats('x'),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('bad filter'))),
      );
    });

    test('5xx → DioException propagates', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(
        _dioError(path: ApiEndpoints.crewStats('x'), statusCode: 503),
      );

      await expectLater(
        repo.fetchCrewStats('x'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('fetchShootCategories', () {
    test('happy: returns tabs map nested under data', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => _ok({
          'error': false,
          'data': {
            'tabs': {'completed': 5, 'upcoming': 3},
          },
        }),
      );

      final tabs = await repo.fetchShootCategories('all');

      expect(tabs, {'completed': 5, 'upcoming': 3});
      final url = verify(() => dio.get<dynamic>(captureAny())).captured.single;
      expect(url, ApiEndpoints.shootCategories('all'));
    });

    test('happy: returns empty map when tabs missing', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => _ok({'error': false, 'data': <String, dynamic>{}}),
      );

      expect(await repo.fetchShootCategories('all'), <String, dynamic>{});
    });

    test('error envelope → throws', () async {
      when(() => dio.get<dynamic>(any()))
          .thenAnswer((_) async => _ok(errorResponse(message: 'nope')));

      await expectLater(
        repo.fetchShootCategories('all'),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('nope'))),
      );
    });
  });

  group('fetchAvailability', () {
    test('happy: posts month/year and returns availability map', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok({
                'error': false,
                'data': {
                  'availability': {'2026-06-01': true},
                },
              }));

      final result = await repo.fetchAvailability(6, 2026);

      expect(result, {'2026-06-01': true});
      final captured = verify(
        () => dio.post<dynamic>(captureAny(), data: captureAny(named: 'data')),
      ).captured;
      expect(captured.first, ApiEndpoints.createavailability);
      expect(captured.last, {'month': 6, 'year': 2026});
    });

    test('error envelope → throws', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok(errorResponse(message: 'bad month')));

      await expectLater(
        repo.fetchAvailability(13, 2026),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('bad month'))),
      );
    });

    test('cancel → DioException propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _dioError(
          path: ApiEndpoints.createavailability,
          type: DioExceptionType.cancel,
        ),
      );

      await expectLater(
        repo.fetchAvailability(6, 2026),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('fetchProfile', () {
    test('happy: parses MyProfileData', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok(profileResponse(firstName: 'Carla')));

      final data = await repo.fetchProfile();

      expect(data.firstName, 'Carla');
      final captured = verify(
        () => dio.post<dynamic>(captureAny(), data: captureAny(named: 'data')),
      ).captured;
      expect(captured.first, ApiEndpoints.profiledetails);
      expect(captured.last, <String, dynamic>{});
    });

    test('error envelope (model.error=true) → throws server message',
        () async {
      final body = profileResponse();
      body['error'] = true;
      body['message'] = 'profile blocked';
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok(body));

      await expectLater(
        repo.fetchProfile(),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('profile blocked'))),
      );
    });

    test('401 → DioException propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _dioError(path: ApiEndpoints.profiledetails, statusCode: 401),
      );

      await expectLater(repo.fetchProfile(), throwsA(isA<DioException>()));
    });
  });

  group('acceptDeclineProject', () {
    test('happy: posts project_id + crew_accept', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok({'error': false}));

      await repo.acceptDeclineProject(42, 1);

      final captured = verify(
        () => dio.post<dynamic>(captureAny(), data: captureAny(named: 'data')),
      ).captured;
      expect(captured.first, ApiEndpoints.acceptdeclineproject);
      expect(captured.last, {'project_id': 42, 'crew_accept': 1});
    });

    test('error envelope → throws', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok(errorResponse(message: 'expired')));

      await expectLater(
        repo.acceptDeclineProject(42, 1),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('expired'))),
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
        repo.acceptDeclineProject(42, 1),
        throwsA(isA<DioException>()),
      );
    });
  });
}
