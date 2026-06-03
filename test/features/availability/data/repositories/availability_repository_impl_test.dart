import 'package:beige_creative_app/core/network/api_endpoints.dart';
import 'package:beige_creative_app/features/availability/data/repositories/availability_repository_impl.dart';
import 'package:beige_creative_app/features/availability/domain/entities/availability_entry.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

/// AAA pattern. Availability repo is **swallow-on-envelope-error** for
/// `fetchMonth` (returns empty map) and fire-and-forget for
/// `createAvailability` (no envelope check). Transport failures still
/// propagate as `DioException`.
Response<dynamic> _ok(dynamic body, {String path = '/'}) => Response<dynamic>(
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

AvailabilityPayload _payload({
  String date = '2026-06-15',
  int status = 1,
  int isFullDay = 1,
}) =>
    AvailabilityPayload(
      date: date,
      availabilityStatus: status,
      isFullDay: isFullDay,
      startTime: '09:00',
      endTime: '17:00',
      recurrence: 0,
      notes: '',
      recurrenceUntil: '',
      recurrenceDays: null,
    );

void main() {
  late MockDioClient client;
  late MockDio dio;
  late AvailabilityRepositoryImpl repo;

  setUpAll(registerHelperFallbacks);

  setUp(() {
    client = MockDioClient();
    dio = MockDio();
    when(() => client.dio).thenReturn(dio);
    repo = AvailabilityRepositoryImpl(client);
  });

  group('fetchMonth', () {
    test('happy: parses availability + shoot statuses, drops idle days',
        () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok({
                'error': false,
                'data': {
                  'availability': {
                    '2026-06-01': {'available': true},
                    '2026-06-02': {'projectAssigned': true, 'available': true},
                    '2026-06-03': {'available': false},
                    '2026-06-04': 'not-a-map',
                    'not-a-date': {'available': true},
                  },
                },
              }));

      final out = await repo.fetchMonth(month: 6, year: 2026);

      expect(out, {
        DateTime(2026, 6, 1): AvailabilityStatus.available,
        // projectAssigned wins over available
        DateTime(2026, 6, 2): AvailabilityStatus.shoot,
      });
      final captured = verify(
        () => dio.post<dynamic>(captureAny(), data: captureAny(named: 'data')),
      ).captured;
      expect(captured.first, ApiEndpoints.createavailability);
      expect(captured.last, {'month': 6, 'year': 2026});
    });

    test('error envelope → returns empty map (does NOT throw)', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok({'error': true, 'message': 'denied'}));

      expect(await repo.fetchMonth(month: 6, year: 2026),
          isA<Map<DateTime, AvailabilityStatus>>().having((m) => m.isEmpty,
              'isEmpty', isTrue));
    });

    test('non-Map payload → returns empty map', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok('not a map'));

      expect(await repo.fetchMonth(month: 6, year: 2026), isEmpty);
    });

    test('missing data.availability → returns empty map', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok({'error': false, 'data': {}}));

      expect(await repo.fetchMonth(month: 6, year: 2026), isEmpty);
    });

    test('401 → DioException propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _dioError(path: ApiEndpoints.createavailability, statusCode: 401),
      );

      await expectLater(
        repo.fetchMonth(month: 6, year: 2026),
        throwsA(isA<DioException>()),
      );
    });

    test('5xx → DioException propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _dioError(path: ApiEndpoints.createavailability, statusCode: 502),
      );

      await expectLater(
        repo.fetchMonth(month: 6, year: 2026),
        throwsA(isA<DioException>()),
      );
    });

    test('cancel → DioException(type=cancel) propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _dioError(
          path: ApiEndpoints.createavailability,
          type: DioExceptionType.cancel,
        ),
      );

      await expectLater(
        repo.fetchMonth(month: 6, year: 2026),
        throwsA(predicate(
            (e) => e is DioException && e.type == DioExceptionType.cancel)),
      );
    });
  });

  group('createAvailability', () {
    test('happy: posts payload JSON to add_availability', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok({'error': false}));

      await repo.createAvailability(_payload(date: '2026-06-20'));

      final captured = verify(
        () => dio.post<dynamic>(captureAny(), data: captureAny(named: 'data')),
      ).captured;
      expect(captured.first, ApiEndpoints.add_availability);
      expect(captured.last, {
        'date': '2026-06-20',
        'availability_status': 1,
        'is_full_day': 1,
        'start_time': '09:00',
        'end_time': '17:00',
        'recurrence': 0,
        'notes': '',
        'recurrence_until': '',
        'recurrence_days': null,
      });
    });

    test('error envelope on response is NOT inspected (fire-and-forget)',
        () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok({'error': true, 'message': 'ignored'}));

      // Must not throw — repo never reads response.data on this path.
      await repo.createAvailability(_payload());
    });

    test('5xx → DioException propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _dioError(path: ApiEndpoints.add_availability, statusCode: 500),
      );

      await expectLater(
        repo.createAvailability(_payload()),
        throwsA(isA<DioException>()),
      );
    });

    test('cancel → DioException propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _dioError(
          path: ApiEndpoints.add_availability,
          type: DioExceptionType.cancel,
        ),
      );

      await expectLater(
        repo.createAvailability(_payload()),
        throwsA(isA<DioException>()),
      );
    });
  });
}
