import 'dart:io';

import 'package:beige_creative_app/core/network/api_endpoints.dart';
import 'package:beige_creative_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:beige_creative_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_data.dart';

/// AAA: each test arranges DioClient.dio = MockDio, stubs the single network
/// call, then invokes the repo method and asserts on (a) returned value and
/// (b) the path/payload that hit Dio.
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

void main() {
  late MockDioClient client;
  late MockDio dio;
  late AuthRepositoryImpl repo;

  setUpAll(registerHelperFallbacks);

  setUp(() {
    client = MockDioClient();
    dio = MockDio();
    when(() => client.dio).thenReturn(dio);
    repo = AuthRepositoryImpl(client);
  });

  group('login', () {
    test(
      'happy: returns token + UserSnapshot when payload includes user',
      () async {
        // Arrange
        final body = loginResponse(token: 'jwt-xyz');
        (body['data'] as Map)['user'] = {
          'id': 9,
          'email': 'crew@example.com',
          'name': 'Test Crew',
        };
        when(
          () => dio.post<dynamic>(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => _ok(body, path: ApiEndpoints.login));

        // Act
        final result = await repo.login(
          email: 'crew@example.com',
          password: 'pw',
        );

        // Assert
        expect(result.token, 'jwt-xyz');
        expect(result.user?.id, '9');
        expect(result.user?.email, 'crew@example.com');
        final captured = verify(
          () =>
              dio.post<dynamic>(captureAny(), data: captureAny(named: 'data')),
        ).captured;
        expect(captured.first, ApiEndpoints.login);
        expect(captured.last, {'email': 'crew@example.com', 'password': 'pw'});
      },
    );

    test(
      'happy: parses token + crew_member when user payload is absent',
      () async {
        when(
          () => dio.post<dynamic>(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => _ok(loginResponse(token: 't')));

        final result = await repo.login(email: 'a@b.c', password: 'pw');

        expect(result.token, 't');
        expect(result.user?.id, '1');
        expect(result.user?.email, 'crew@example.com');
        expect(result.user?.name, 'Test Crew');
      },
    );

    test('happy: missing user and crew_member still returns token', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => _ok({
          'error': false,
          'message': 'ok',
          'data': {'token': 't'},
        }),
      );

      final result = await repo.login(email: 'a@b.c', password: 'pw');

      expect(result.token, 't');
      expect(result.user, isNull);
    });

    test('error envelope (error: true) → throws with server message', () async {
      when(
        () => dio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _ok(errorResponse(message: 'bad creds')));

      await expectLater(
        repo.login(email: 'a@b.c', password: 'pw'),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('bad creds'),
          ),
        ),
      );
    });

    test('missing token in payload → throws', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => _ok({
          'error': false,
          'message': 'ok',
          'data': {
            'crew_member': {'id': 1},
          },
        }),
      );

      await expectLater(
        repo.login(email: 'a@b.c', password: 'pw'),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('missing token'),
          ),
        ),
      );
    });

    test('non-Map payload → throws', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: ApiEndpoints.login),
          data: 'not a map',
          statusCode: 200,
        ),
      );

      await expectLater(
        repo.login(email: 'a@b.c', password: 'pw'),
        throwsA(isA<Exception>()),
      );
    });

    test(
      '401 → DioException propagates (interceptor will translate)',
      () async {
        when(
          () => dio.post<dynamic>(any(), data: any(named: 'data')),
        ).thenThrow(_dioError(path: ApiEndpoints.login, statusCode: 401));

        await expectLater(
          repo.login(email: 'a@b.c', password: 'pw'),
          throwsA(isA<DioException>()),
        );
      },
    );

    test('5xx → DioException propagates', () async {
      when(
        () => dio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenThrow(_dioError(path: ApiEndpoints.login, statusCode: 503));

      await expectLater(
        repo.login(email: 'a@b.c', password: 'pw'),
        throwsA(isA<DioException>()),
      );
    });

    test('cancel → DioException(type=cancel) propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _dioError(path: ApiEndpoints.login, type: DioExceptionType.cancel),
      );

      await expectLater(
        repo.login(email: 'a@b.c', password: 'pw'),
        throwsA(
          predicate(
            (e) => e is DioException && e.type == DioExceptionType.cancel,
          ),
        ),
      );
    });
  });

  group('requestPasswordReset', () {
    test('happy: posts email and resolves on error=false', () async {
      when(
        () => dio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _ok({'error': false, 'message': 'sent'}));

      await repo.requestPasswordReset('user@example.com');

      final captured = verify(
        () => dio.post<dynamic>(captureAny(), data: captureAny(named: 'data')),
      ).captured;
      expect(captured.first, ApiEndpoints.forgotpassword);
      expect(captured.last, {'email': 'user@example.com'});
    });

    test('error envelope → throws with server message', () async {
      when(
        () => dio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _ok(errorResponse(message: 'not registered')));

      await expectLater(
        repo.requestPasswordReset('x@y.z'),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('not registered'),
          ),
        ),
      );
    });

    test('5xx → DioException propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _dioError(path: ApiEndpoints.forgotpassword, statusCode: 500),
      );

      await expectLater(
        repo.requestPasswordReset('x@y.z'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('verifyResetOtp', () {
    test('happy: posts email + otp', () async {
      when(
        () => dio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _ok({'error': false}));

      await repo.verifyResetOtp(email: 'u@x.io', otp: '4242');

      final captured = verify(
        () => dio.post<dynamic>(captureAny(), data: captureAny(named: 'data')),
      ).captured;
      expect(captured.first, ApiEndpoints.forgotpasswordverifyotp);
      expect(captured.last, {'email': 'u@x.io', 'otp': '4242'});
    });

    test('error envelope → throws Invalid OTP fallback', () async {
      when(
        () => dio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _ok(errorResponse(message: 'wrong otp')));

      await expectLater(
        repo.verifyResetOtp(email: 'u@x.io', otp: '0'),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('wrong otp'),
          ),
        ),
      );
    });

    test('cancel → DioException(type=cancel) propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _dioError(
          path: ApiEndpoints.forgotpasswordverifyotp,
          type: DioExceptionType.cancel,
        ),
      );

      await expectLater(
        repo.verifyResetOtp(email: 'u@x.io', otp: '0'),
        throwsA(
          predicate(
            (e) => e is DioException && e.type == DioExceptionType.cancel,
          ),
        ),
      );
    });
  });

  group('resetPassword', () {
    test('happy: posts all four fields', () async {
      when(
        () => dio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _ok({'error': false}));

      await repo.resetPassword(
        email: 'u@x.io',
        otp: '1111',
        newPassword: 'newpw',
        confirmPassword: 'newpw',
      );

      final captured = verify(
        () => dio.post<dynamic>(captureAny(), data: captureAny(named: 'data')),
      ).captured;
      expect(captured.first, ApiEndpoints.restartpassword);
      expect(captured.last, {
        'email': 'u@x.io',
        'otp': '1111',
        'new_password': 'newpw',
        'confirm_password': 'newpw',
      });
    });

    test('error envelope → throws', () async {
      when(
        () => dio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _ok(errorResponse(message: 'reset failed')));

      await expectLater(
        repo.resetPassword(
          email: 'u@x.io',
          otp: '1',
          newPassword: 'a',
          confirmPassword: 'a',
        ),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('reset failed'),
          ),
        ),
      );
    });

    test('401 → DioException propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _dioError(path: ApiEndpoints.restartpassword, statusCode: 401),
      );

      await expectLater(
        repo.resetPassword(
          email: 'u@x.io',
          otp: '1',
          newPassword: 'a',
          confirmPassword: 'a',
        ),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('registerStep1', () {
    late File tempImage;

    setUp(() {
      tempImage = File(
        '${Directory.systemTemp.path}/auth_repo_test_${DateTime.now().microsecondsSinceEpoch}.jpg',
      )..writeAsBytesSync(const [0x00, 0x01, 0x02, 0x03]);
    });

    tearDown(() {
      if (tempImage.existsSync()) tempImage.deleteSync();
    });

    Step1Payload payload() => Step1Payload(
      firstName: 'A',
      lastName: 'B',
      email: 'a@b.c',
      phone: '555',
      password: 'pw',
      location: 'NYC',
      workingDistance: '50',
      latitude: 1.0,
      longitude: 2.0,
      profileImage: tempImage,
    );

    test('happy: returns crew_member_id as int', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => _ok({
          'error': false,
          'message': 'ok',
          'data': {'crew_member_id': 77},
        }),
      );

      final id = await repo.registerStep1(payload());

      expect(id, 77);
      final path = verify(
        () => dio.post<dynamic>(captureAny(), data: any(named: 'data')),
      ).captured.single;
      expect(path, ApiEndpoints.register_step1);
    });

    test(
      'happy: parses crew_member_id when backend returns it as string',
      () async {
        when(
          () => dio.post<dynamic>(any(), data: any(named: 'data')),
        ).thenAnswer(
          (_) async => _ok({
            'error': false,
            'data': {'crew_member_id': '42'},
          }),
        );

        expect(await repo.registerStep1(payload()), 42);
      },
    );

    test('error envelope → throws server message', () async {
      when(
        () => dio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _ok(errorResponse(message: 'duplicate email')));

      await expectLater(
        repo.registerStep1(payload()),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('duplicate email'),
          ),
        ),
      );
    });

    test('cancel → DioException propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _dioError(
          path: ApiEndpoints.register_step1,
          type: DioExceptionType.cancel,
        ),
      );

      await expectLater(
        repo.registerStep1(payload()),
        throwsA(
          predicate(
            (e) => e is DioException && e.type == DioExceptionType.cancel,
          ),
        ),
      );
    });
  });

  group('registerStep2', () {
    Step2Payload payload() => const Step2Payload(
      crewMemberId: 7,
      primaryRoleIds: [1, 2],
      yearsOfExperience: 3,
      hourlyRate: 50.0,
      bio: 'hi',
      skillIds: [9],
      equipmentIds: [4],
    );

    test('happy: posts JSON body', () async {
      when(
        () => dio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _ok({'error': false}));

      await repo.registerStep2(payload());

      final captured = verify(
        () => dio.post<dynamic>(captureAny(), data: captureAny(named: 'data')),
      ).captured;
      expect(captured.first, ApiEndpoints.register_step2);
      expect(captured.last, {
        'crew_member_id': 7,
        'primary_role': [1, 2],
        'years_of_experience': 3,
        'hourly_rate': 50,
        'bio': 'hi',
        'skills': [9],
        'equipment_ownership': [4],
      });
    });

    test('error envelope → throws fallback "Step 2 failed"', () async {
      when(
        () => dio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _ok({'error': true, 'data': null}));

      await expectLater(
        repo.registerStep2(payload()),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('Step 2 failed'),
          ),
        ),
      );
    });

    test('cancel → DioException propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _dioError(
          path: ApiEndpoints.register_step2,
          type: DioExceptionType.cancel,
        ),
      );

      await expectLater(
        repo.registerStep2(payload()),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('registerStep3', () {
    Step3Payload payload() => const Step3Payload(
      crewMemberId: 7,
      socialMediaLinks: [],
      portfolioLinks: [],
      featuredWork: [],
      certificationFiles: [],
      resume: null,
      portfolio: null,
      recentWorkMediaFiles: [],
      recentWorkMediaIndexes: [],
    );

    test('happy: posts to register_step3 endpoint', () async {
      when(
        () => dio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _ok({'error': false}));

      await repo.registerStep3(payload());

      final path = verify(
        () => dio.post<dynamic>(captureAny(), data: any(named: 'data')),
      ).captured.single;
      expect(path, ApiEndpoints.register_step3);
    });

    test('error envelope → throws fallback "Step 3 failed"', () async {
      when(
        () => dio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => _ok({'error': true}));

      await expectLater(
        repo.registerStep3(payload()),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('Step 3 failed'),
          ),
        ),
      );
    });
  });

  group('fetchRoles', () {
    test(
      'happy: parses role_id + role_name, dedupes, skips malformed',
      () async {
        when(() => dio.get<dynamic>(any())).thenAnswer(
          (_) async => _ok({
            'error': false,
            'data': [
              {'role_id': 1, 'role_name': 'Photographer'},
              {'role_id': 2, 'role_name': 'Videographer'},
              // dup name → ignored
              {'role_id': 3, 'role_name': 'Photographer'},
              // missing fields → ignored
              {'role_id': 'not-int', 'role_name': 'Editor'},
              {'role_id': 4, 'role_name': ''},
              'not-a-map',
            ],
          }),
        );

        final roles = await repo.fetchRoles();

        expect(roles.map((r) => r.name).toList(), [
          'Photographer',
          'Videographer',
        ]);
        expect(roles.first.id, 1);
        verify(() => dio.get<dynamic>(ApiEndpoints.register_roles)).called(1);
      },
    );

    test('error envelope → throws fallback', () async {
      when(
        () => dio.get<dynamic>(any()),
      ).thenAnswer((_) async => _ok(errorResponse(message: 'roles down')));

      await expectLater(
        repo.fetchRoles(),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('roles down'),
          ),
        ),
      );
    });

    test('5xx → DioException propagates', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(
        _dioError(path: ApiEndpoints.register_roles, statusCode: 500),
      );

      await expectLater(repo.fetchRoles(), throwsA(isA<DioException>()));
    });
  });

  group('fetchSkills', () {
    test('happy: parses id + name', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => _ok({
          'error': false,
          'data': [
            {'id': 10, 'name': 'Lighting'},
            {'id': 11, 'name': 'Editing'},
          ],
        }),
      );

      final skills = await repo.fetchSkills();

      expect(skills.length, 2);
      expect(skills.first.id, 10);
      verify(() => dio.get<dynamic>(ApiEndpoints.register_Skill)).called(1);
    });
  });

  group('searchEquipments', () {
    test(
      'happy: appends ?query=foo to URL and parses equipment_id/name',
      () async {
        when(() => dio.get<dynamic>(any())).thenAnswer(
          (_) async => _ok({
            'error': false,
            'data': [
              {'equipment_id': 1, 'equipment_name': 'Sony A7'},
              {'equipment_id': 2, 'equipment_name': 'Canon R5'},
            ],
          }),
        );

        final results = await repo.searchEquipments('camera');

        expect(results.map((r) => r.name).toList(), ['Sony A7', 'Canon R5']);
        final url = verify(
          () => dio.get<dynamic>(captureAny()),
        ).captured.single;
        expect(url, '${ApiEndpoints.register_equipment}?query=camera');
      },
    );

    test('cancel → DioException propagates', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(
        _dioError(
          path: '${ApiEndpoints.register_equipment}?query=x',
          type: DioExceptionType.cancel,
        ),
      );

      await expectLater(
        repo.searchEquipments('x'),
        throwsA(
          predicate(
            (e) => e is DioException && e.type == DioExceptionType.cancel,
          ),
        ),
      );
    });
  });
}
