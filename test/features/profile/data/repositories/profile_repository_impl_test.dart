import 'dart:io';

import 'package:beige_creative_app/core/network/api_endpoints.dart';
import 'package:beige_creative_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_data.dart';

/// AAA pattern. Mocks `DioClient.dio` and asserts on captured path/body for
/// each public method on [ProfileRepositoryImpl].
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

Map<String, dynamic> _editProfilePayload({
  int crewMemberId = 7,
  String firstName = 'Alice',
}) =>
    {
      'error': false,
      'code': 200,
      'message': 'ok',
      'data': {
        'crew_member_id': crewMemberId,
        'user_id': 99,
        'first_name': firstName,
        'last_name': 'Doe',
        'email': 'alice@example.com',
        'phone_number': '555-0101',
        'location': 'NYC',
        'working_distance': '50',
        'primary_role': 'Photographer',
        'years_of_experience': 4,
        'hourly_rate': '60',
        'bio': 'hi',
        'age': 30,
        'skills': [
          {'id': 1, 'name': 'Lighting'},
        ],
        'skill_ids': [1],
        'user': {
          'id': 99,
          'name': 'Alice Doe',
          'email': 'alice@example.com',
          'phone_number': '555-0101',
          'location': 'NYC',
          'latitude': '40.0',
          'longitude': '-74.0',
        },
        'stats': {
          'hourly_rate': 60,
          'years_of_experience': 4,
          'working_distance': '50',
          'rating': 5,
          'total_reviews': 12,
        },
        'profile_image_url': 'https://cdn.example/a.jpg',
      },
    };

void main() {
  late MockDioClient client;
  late MockDio dio;
  late ProfileRepositoryImpl repo;

  setUpAll(registerHelperFallbacks);

  setUp(() {
    client = MockDioClient();
    dio = MockDio();
    when(() => client.dio).thenReturn(dio);
    repo = ProfileRepositoryImpl(client);
  });

  group('fetchEditProfile', () {
    test('happy: posts empty body, parses model', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok(_editProfilePayload(firstName: 'Bob')));

      final model = await repo.fetchEditProfile();

      expect(model.firstName, 'Bob');
      expect(model.user.email, 'alice@example.com');
      final captured = verify(
        () => dio.post<dynamic>(captureAny(), data: captureAny(named: 'data')),
      ).captured;
      expect(captured.first, ApiEndpoints.editprofile);
      expect(captured.last, <String, dynamic>{});
    });

    test('error envelope → throws server message', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok(errorResponse(message: 'forbidden')));

      await expectLater(
        repo.fetchEditProfile(),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('forbidden'))),
      );
    });

    test('non-Map payload → throws', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok('not a map'));

      await expectLater(repo.fetchEditProfile(), throwsA(isA<Exception>()));
    });

    test('401 → DioException propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenThrow(_dioError(path: ApiEndpoints.editprofile, statusCode: 401));

      await expectLater(
        repo.fetchEditProfile(),
        throwsA(isA<DioException>()),
      );
    });

    test('5xx → DioException propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenThrow(_dioError(path: ApiEndpoints.editprofile, statusCode: 500));

      await expectLater(
        repo.fetchEditProfile(),
        throwsA(isA<DioException>()),
      );
    });

    test('cancel → DioException propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _dioError(
          path: ApiEndpoints.editprofile,
          type: DioExceptionType.cancel,
        ),
      );

      await expectLater(
        repo.fetchEditProfile(),
        throwsA(predicate(
            (e) => e is DioException && e.type == DioExceptionType.cancel)),
      );
    });
  });

  group('updateProfile', () {
    test('happy: forwards body and resolves on error=false', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok({'error': false}));

      await repo.updateProfile({'bio': 'updated'});

      final captured = verify(
        () => dio.post<dynamic>(captureAny(), data: captureAny(named: 'data')),
      ).captured;
      expect(captured.first, ApiEndpoints.editprofile);
      expect(captured.last, {'bio': 'updated'});
    });

    test('error envelope → throws', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => _ok(errorResponse(message: 'validation')),
      );

      await expectLater(
        repo.updateProfile({'bio': 'x'}),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('validation'))),
      );
    });

    test('cancel → DioException propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _dioError(
          path: ApiEndpoints.editprofile,
          type: DioExceptionType.cancel,
        ),
      );

      await expectLater(
        repo.updateProfile(const {'bio': 'x'}),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('fetchRoles', () {
    test('happy: returns name → id map', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => _ok({
          'error': false,
          'data': [
            {'role_id': 1, 'role_name': 'Photographer'},
            {'role_id': 2, 'role_name': 'Editor'},
          ],
        }),
      );

      final roles = await repo.fetchRoles();

      expect(roles, {'Photographer': 1, 'Editor': 2});
      verify(() => dio.get<dynamic>(ApiEndpoints.register_roles)).called(1);
    });

    test('data not list → throws', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => _ok({'error': false, 'data': 'not-a-list'}),
      );

      await expectLater(repo.fetchRoles(), throwsA(isA<Exception>()));
    });

    test('5xx → DioException propagates', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(
        _dioError(path: ApiEndpoints.register_roles, statusCode: 500),
      );

      await expectLater(repo.fetchRoles(), throwsA(isA<DioException>()));
    });
  });

  group('fetchSkills', () {
    test('happy: returns name → id map', () async {
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

      expect(skills, {'Lighting': 10, 'Editing': 11});
      verify(() => dio.get<dynamic>(ApiEndpoints.register_Skill)).called(1);
    });

    test('cancel → DioException propagates', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(_dioError(
        path: ApiEndpoints.register_Skill,
        type: DioExceptionType.cancel,
      ));

      await expectLater(repo.fetchSkills(), throwsA(isA<DioException>()));
    });
  });

  group('uploadPhoto', () {
    late File tempFile;

    setUp(() {
      tempFile = File(
        '${Directory.systemTemp.path}/profile_repo_test_${DateTime.now().microsecondsSinceEpoch}.jpg',
      )..writeAsBytesSync(const [1, 2, 3, 4]);
    });

    tearDown(() {
      if (tempFile.existsSync()) tempFile.deleteSync();
    });

    test('happy: returns server-supplied image url', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => _ok({
          'error': false,
          'data': {'profile_image_url': 'https://cdn/example/a.jpg'},
        }),
      );

      final url = await repo.uploadPhoto(tempFile, crewMemberId: '7');

      expect(url, 'https://cdn/example/a.jpg');
      final path = verify(
        () => dio.post<dynamic>(captureAny(), data: any(named: 'data')),
      ).captured.single;
      expect(path, ApiEndpoints.upload_profile_photo);
    });

    test('error envelope → throws server message', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => _ok({'error': true, 'message': 'too large'}),
      );

      await expectLater(
        repo.uploadPhoto(tempFile),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('too large'))),
      );
    });

    test('5xx → DioException propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _dioError(path: ApiEndpoints.upload_profile_photo, statusCode: 502),
      );

      await expectLater(
        repo.uploadPhoto(tempFile),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('updateSocialLinks', () {
    test('happy: forwards links list under social_media_links', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok({'error': false}));

      await repo.updateSocialLinks([
        {'platform': 'instagram', 'url': 'https://i/u'},
      ]);

      final captured = verify(
        () => dio.post<dynamic>(captureAny(), data: captureAny(named: 'data')),
      ).captured;
      expect(captured.first, ApiEndpoints.editprofile);
      expect(captured.last, {
        'social_media_links': [
          {'platform': 'instagram', 'url': 'https://i/u'},
        ],
      });
    });

    test('error envelope → throws', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok(errorResponse(message: 'bad url')));

      await expectLater(
        repo.updateSocialLinks(const []),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('bad url'))),
      );
    });

    test('cancel → DioException propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _dioError(
          path: ApiEndpoints.editprofile,
          type: DioExceptionType.cancel,
        ),
      );

      await expectLater(
        repo.updateSocialLinks(const []),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('addPortfolioLinks', () {
    test('happy: posts links under portfolio_links', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok({'error': false}));

      await repo.addPortfolioLinks([
        {'url': 'https://p/1', 'title': 'one'},
      ]);

      final captured = verify(
        () => dio.post<dynamic>(captureAny(), data: captureAny(named: 'data')),
      ).captured;
      expect(captured.first, ApiEndpoints.addportfoliolink);
      expect(captured.last, {
        'portfolio_links': [
          {'url': 'https://p/1', 'title': 'one'},
        ],
      });
    });

    test('error envelope → throws', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok(errorResponse(message: 'dup link')));

      await expectLater(
        repo.addPortfolioLinks(const []),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('dup link'))),
      );
    });

    test('5xx → DioException propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _dioError(path: ApiEndpoints.addportfoliolink, statusCode: 500),
      );

      await expectLater(
        repo.addPortfolioLinks(const []),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('editPortfolioLink', () {
    test('happy: posts to /edit_portfolio_link/\$id with body', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok({'error': false}));

      await repo.editPortfolioLink(
        id: 5,
        url: 'https://p/5',
        platform: 'site',
        title: 'five',
      );

      final captured = verify(
        () => dio.post<dynamic>(captureAny(), data: captureAny(named: 'data')),
      ).captured;
      expect(captured.first, '${ApiEndpoints.edit_portfolio_link}/5');
      expect(captured.last, {
        'url': 'https://p/5',
        'platform': 'site',
        'title': 'five',
      });
    });

    test('error envelope → throws', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => _ok(errorResponse(message: 'not yours')));

      await expectLater(
        repo.editPortfolioLink(id: 5, url: 'u', platform: 'p', title: 't'),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('not yours'))),
      );
    });

    test('cancel → DioException propagates', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _dioError(
          path: '${ApiEndpoints.edit_portfolio_link}/5',
          type: DioExceptionType.cancel,
        ),
      );

      await expectLater(
        repo.editPortfolioLink(id: 5, url: 'u', platform: 'p', title: 't'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
