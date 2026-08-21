import 'package:beige_creative_app/core/network/api_endpoints.dart';
import 'package:beige_creative_app/features/auth/data/repositories/signup_resume_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockDioClient client;
  late MockDio dio;
  late SignupResumeRepositoryImpl repository;

  setUpAll(registerHelperFallbacks);

  setUp(() {
    client = MockDioClient();
    dio = MockDio();
    when(() => client.dio).thenReturn(dio);
    repository = SignupResumeRepositoryImpl(client);
  });

  test('posts to profile-detail and maps signup step 1 fields', () async {
    when(
      () => dio.post<dynamic>(
        ApiEndpoints.profiledetails,
        data: <String, dynamic>{},
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: ApiEndpoints.profiledetails),
        statusCode: 200,
        data: {
          'error': false,
          'code': 200,
          'message': 'Profile details',
          'data': {
            'crew_member_id': 559,
            'first_name': 'Krunal',
            'last_name': 'Doshi',
            'email': 'krunal@example.com',
            'phone_number': '1234567890',
            'location': 'Ahmedabad',
            'working_distance': 'Upto 75 miles',
            'profile_image_url': 'profile.jpg',
            'primary_role': '[1, 2]',
            'years_of_experience': 6,
            'hourly_rate': '125.50',
            'bio': 'Documentary filmmaker',
            'skills': [
              {'id': 10, 'name': 'Lighting'},
            ],
            'equipment_ownership': [
              {'equipment_id': 100, 'equipment_name': 'RED Komodo'},
            ],
            'user': {'id': 797, 'latitude': '23.0225', 'longitude': '72.5714'},
          },
        },
      ),
    );

    final result = await repository.fetchStep1Prefill();

    expect(result.crewMemberId, 559);
    expect(result.firstName, 'Krunal');
    expect(result.location, 'Ahmedabad');
    expect(result.latitude, 23.0225);
    expect(result.longitude, 72.5714);
    expect(result.profileImageUrl, 'profile.jpg');
    expect(result.primaryRoles.map((option) => option.id), [1, 2]);
    expect(result.yearsOfExperience, '6');
    expect(result.hourlyRate, '125.50');
    expect(result.bio, 'Documentary filmmaker');
    expect(result.skills.single.name, 'Lighting');
    expect(result.equipments.single.id, 100);
    expect(result.equipments.single.name, 'RED Komodo');
    verify(
      () => dio.post<dynamic>(
        ApiEndpoints.profiledetails,
        data: <String, dynamic>{},
      ),
    ).called(1);
  });
}
