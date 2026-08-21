import 'package:beige_creative_app/model_class/myprofile_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data.dart';

/// Regression tests for `creator/get-profile-detail` payload drift.
/// The API has started returning numeric fields as doubles and
/// `primary_role` in multiple shapes; parsing must not throw.
void main() {
  group('MyProfileModel.fromJson hostile payloads', () {
    test('parses numeric fields sent as doubles', () {
      final json = profileResponse();
      final data = json['data'] as Map<String, dynamic>;
      data['crew_member_id'] = 42.0;
      data['years_of_experience'] = 3.0;
      data['is_available'] = 1.0;
      final user = data['user'] as Map<String, dynamic>;
      user['id'] = 42.0;
      user['user_type'] = 2.0;
      user['years_of_experience'] = 3.0;
      user['is_available'] = 1.0;

      final model = MyProfileModel.fromJson(json);
      expect(model.data.crewMemberId, 42);
      expect(model.data.yearsOfExperience, 3);
      expect(model.data.user.id, 42);
      expect(model.data.user.userType, 2);
    });

    test('parses user.primary_role as plain string', () {
      final json = profileResponse();
      (json['data'] as Map<String, dynamic>)['user']['primary_role'] =
          'Photographer';
      final model = MyProfileModel.fromJson(json);
      expect(model.data.user.primaryRole, 'Photographer');
    });

    test('parses user.primary_role as raw list', () {
      final json = profileResponse();
      (json['data'] as Map<String, dynamic>)['user']['primary_role'] = [1, 2];
      final model = MyProfileModel.fromJson(json);
      expect(model.data.user.primaryRole, '1, 2');
    });

    test('parses user.primary_role as JSON-encoded list', () {
      final json = profileResponse();
      (json['data'] as Map<String, dynamic>)['user']['primary_role'] =
          '["1","2"]';
      final model = MyProfileModel.fromJson(json);
      expect(model.data.user.primaryRole, '1, 2');
    });

    test('parses equipment_ownership sent as string', () {
      final json = profileResponse();
      final data = json['data'] as Map<String, dynamic>;
      data['equipment_ownership'] = '[]';
      data['user']['equipment_ownership'] = '[]';
      final model = MyProfileModel.fromJson(json);
      expect(model.data.equipmentOwnership, isEmpty);
      expect(model.data.user.equipmentOwnership, isEmpty);
    });

    test('synthesizes user from top-level fields when user is null '
        '(live get-profile-detail shape, 2026-07)', () {
      final json = profileResponse(
        firstName: 'Rach',
        lastName: 'CP dev 1',
        email: 'pranav+RPcpdev1@revurge.com',
        yearsOfExperience: 8,
        hourlyRate: '500.51',
        profileImageUrl: 'profile_photo_0.jpg',
        skills: [
          {'id': 18, 'name': 'People & Teams'},
        ],
      );
      final data = json['data'] as Map<String, dynamic>;
      data['user'] = null;
      data['user_id'] = null;
      data['display_name'] = 'Rach CP dev 1';
      data['location'] = '"Dallas Street, Los Angeles, California 90031"';
      data['primary_role'] = '["1","2","3"]';
      data['social_media_links'] = '{"instagram":"www.instagram.com"}';

      final model = MyProfileModel.fromJson(json);
      final user = model.data.user;
      expect(user.name, 'Rach CP dev 1');
      expect(user.email, 'pranav+RPcpdev1@revurge.com');
      expect(user.location, 'Dallas Street, Los Angeles, California 90031');
      expect(user.hourlyRate, '500.51');
      expect(user.yearsOfExperience, 8);
      expect(user.primaryRole, '1, 2, 3');
      expect(user.userProfileImageUrl, 'profile_photo_0.jpg');
      expect(user.skills.single.name, 'People & Teams');
      // Top-level location also unwrapped.
      expect(
        model.data.location,
        'Dallas Street, Los Angeles, California 90031',
      );
    });

    test('parses skill ids sent as doubles', () {
      final json = profileResponse(
        skills: [
          {'id': 7.0, 'name': 'Drone'},
        ],
      );
      final model = MyProfileModel.fromJson(json);
      expect(model.data.skills.single.id, 7);
      expect(model.data.skills.single.name, 'Drone');
    });

    test('parses account status flags from top-level profile data', () {
      final json = profileResponse();
      final data = json['data'] as Map<String, dynamic>;
      data['is_registration_complete'] = 1;
      data['is_crew_verified'] = 2;

      final model = MyProfileModel.fromJson(json);

      expect(model.data.isRegistrationComplete, 1);
      expect(model.data.isCrewVerified, 2);
    });

    test('parses account status flags from nested user fallback', () {
      final json = profileResponse();
      final data = json['data'] as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>;
      user['is_registration_complete'] = '1';
      user['is_crew_verified'] = '0';

      final model = MyProfileModel.fromJson(json);

      expect(model.data.isRegistrationComplete, 1);
      expect(model.data.isCrewVerified, 0);
    });

    test('parses boolean account status flags from mobile API', () {
      final json = profileResponse();
      final data = json['data'] as Map<String, dynamic>;
      data['is_registration_complete'] = true;
      data['is_crew_verified'] = false;

      final model = MyProfileModel.fromJson(json);

      expect(model.data.isRegistrationComplete, 1);
      expect(model.data.isCrewVerified, 0);
    });
  });
}
