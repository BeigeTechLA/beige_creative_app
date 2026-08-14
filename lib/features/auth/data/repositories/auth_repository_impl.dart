import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/session/session_store.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _client;

  const AuthRepositoryImpl(this._client);

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post<dynamic>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Login returned unexpected payload');
    }
    if (data['error'] == true) {
      throw Exception(data['message'] ?? 'Login failed');
    }
    final payload = data['data'];
    if (payload is! Map<String, dynamic>) {
      throw Exception('Login response missing data');
    }
    final token = payload['token']?.toString() ?? '';
    if (token.isEmpty) {
      throw Exception('Login response missing token');
    }
    final rawCrewMember = payload['crew_member'] is Map
        ? payload['crew_member'] as Map
        : null;
    final rawUserMap = payload['user'] is Map ? payload['user'] as Map : null;

    final isRegistrationComplete =
        _intValue(payload, ['is_registration_complete']) ??
        (rawUserMap != null
            ? _intValue(rawUserMap, [
                'is_registration_complete',
                'is_crew_profile_completed',
              ])
            : null) ??
        (rawCrewMember != null
            ? _intValue(rawCrewMember, [
                'is_registration_complete',
                'is_crew_profile_completed',
              ])
            : null);

    final isCrewVerified =
        _intValue(payload, ['is_crew_verified']) ??
        (rawUserMap != null
            ? _intValue(rawUserMap, ['is_crew_verified'])
            : null) ??
        (rawCrewMember != null
            ? _intValue(rawCrewMember, ['is_crew_verified'])
            : null);

    final isStep2Complete =
        _boolValue(payload, ['is_step_2_complete']) ??
        (rawUserMap != null
            ? _boolValue(rawUserMap, ['is_step_2_complete'])
            : null) ??
        (rawCrewMember != null
            ? _boolValue(rawCrewMember, ['is_step_2_complete'])
            : null);

    if (isRegistrationComplete == null ||
        !const {0, 1}.contains(isRegistrationComplete) ||
        isCrewVerified == null ||
        !const {0, 1, 2}.contains(isCrewVerified)) {
      throw Exception('Login response missing valid account status');
    }

    final crewMemberId =
        _intValue(payload, ['crew_member_id']) ??
        (rawUserMap != null
            ? _intValue(rawUserMap, ['crew_member_id'])
            : null) ??
        (rawCrewMember != null
            ? _intValue(rawCrewMember, ['crew_member_id', 'id'])
            : null);

    final rawUser = _parseLoginUser(payload);
    // The creator avatar belongs to the crew profile. Some login responses
    // also include an account-level user image, which can be different. Prefer
    // the crew-member value so pending-review UI shows the submitted profile.
    final crewProfileImageUrl = rawCrewMember == null
        ? null
        : _stringValue(rawCrewMember, [
            'profile_image_url',
            'user_profile_image_url',
            'profile_photo',
          ]);
    final user = rawUser != null
        ? UserSnapshot(
            id: rawUser.id,
            firstName: rawUser.firstName,
            lastName: rawUser.lastName,
            name: rawUser.name,
            email: rawUser.email,
            phoneNumber: rawUser.phoneNumber,
            location: rawUser.location,
            workingDistance: rawUser.workingDistance,
            role: rawUser.role,
            userType: rawUser.userType,
            profileImageUrl: crewProfileImageUrl ?? rawUser.profileImageUrl,
            isRegistrationComplete: isRegistrationComplete,
            isCrewVerified: isCrewVerified,
            isStep2Complete: isStep2Complete,
            crewMemberId: crewMemberId,
          )
        : (crewMemberId != null
              ? UserSnapshot(
                  id: crewMemberId.toString(),
                  isRegistrationComplete: isRegistrationComplete,
                  isCrewVerified: isCrewVerified,
                  isStep2Complete: isStep2Complete,
                  crewMemberId: crewMemberId,
                )
              : null);

    if (user == null) {
      throw Exception('Login response missing crew member identity');
    }

    return LoginResult(
      token: token,
      user: user,
      isRegistrationComplete: isRegistrationComplete,
      isCrewVerified: isCrewVerified,
      isStep2Complete: isStep2Complete,
      crewMemberId: crewMemberId,
    );
  }

  UserSnapshot? _parseLoginUser(Map<String, dynamic> payload) {
    final rawUser = payload['user'];
    if (rawUser is Map) {
      final user = _snapshotFromMap(rawUser);
      if (user != null) return user;
    }

    final rawCrewMember = payload['crew_member'];
    if (rawCrewMember is Map) {
      final nestedUser = rawCrewMember['user'];
      if (nestedUser is Map) {
        final user = _snapshotFromMap(nestedUser);
        if (user != null) return user;
      }

      final id = _stringValue(rawCrewMember, [
        'user_id',
        'userId',
        'id',
        'crew_member_id',
        '_id',
      ]);
      if (id == null || id.isEmpty) return null;

      final firstName = _stringValue(rawCrewMember, ['first_name']);
      final lastName = _stringValue(rawCrewMember, ['last_name']);
      final fallbackName = [
        if (firstName != null && firstName.isNotEmpty) firstName,
        if (lastName != null && lastName.isNotEmpty) lastName,
      ].join(' ');

      return UserSnapshot(
        id: id,
        firstName: firstName,
        lastName: lastName,
        name:
            _stringValue(rawCrewMember, ['name']) ??
            (fallbackName.isEmpty ? null : fallbackName),
        email: _stringValue(rawCrewMember, ['email']),
        phoneNumber: _stringValue(rawCrewMember, ['phone_number', 'phone']),
        location: _stringValue(rawCrewMember, ['location']),
        workingDistance: _stringValue(rawCrewMember, ['working_distance']),
        role: _stringValue(rawCrewMember, ['role']),
        userType: _stringValue(rawCrewMember, ['user_type']),
        profileImageUrl: _stringValue(rawCrewMember, [
          'profile_image_url',
          'user_profile_image_url',
          'profile_photo',
        ]),
      );
    }

    return null;
  }

  UserSnapshot? _snapshotFromMap(Map<dynamic, dynamic> json) {
    final id = _stringValue(json, ['id', 'user_id', '_id']);
    if (id == null || id.isEmpty) return null;
    return UserSnapshot(
      id: id,
      firstName: _stringValue(json, ['first_name', 'firstName']),
      lastName: _stringValue(json, ['last_name', 'lastName']),
      name: _stringValue(json, ['name', 'full_name']),
      email: _stringValue(json, ['email']),
      phoneNumber: _stringValue(json, ['phone_number', 'phone']),
      location: _stringValue(json, ['location']),
      workingDistance: _stringValue(json, ['working_distance']),
      role: _stringValue(json, ['role']),
      userType: _stringValue(json, ['user_type']),
      profileImageUrl: _stringValue(json, [
        'profile_image_url',
        'user_profile_image_url',
        'profileImage',
        'avatar_url',
      ]),
    );
  }

  String? _stringValue(Map<dynamic, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  int? _intValue(Map<dynamic, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      if (value is bool) return value ? 1 : 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
    return null;
  }

  bool? _boolValue(Map<dynamic, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      if (value is bool) return value;
      if (value is num) return value.toInt() == 1;
      final normalized = value.toString().trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    final response = await _client.dio.post<dynamic>(
      ApiEndpoints.forgotpassword,
      data: {'email': email},
    );
    _throwIfError(response.data, fallback: 'Email not registered');
  }

  @override
  Future<void> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _client.dio.post<dynamic>(
      ApiEndpoints.forgotpasswordverifyotp,
      data: {'email': email, 'otp': otp},
    );
    _throwIfError(response.data, fallback: 'Invalid OTP. Please try again.');
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _client.dio.post<dynamic>(
      ApiEndpoints.restartpassword,
      data: {
        'email': email,
        'otp': otp,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
    _throwIfError(response.data, fallback: 'Failed to reset password');
  }

  void _throwIfError(dynamic data, {required String fallback}) {
    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected server response');
    }
    if (data['error'] == true) {
      throw Exception(data['message']?.toString() ?? fallback);
    }
  }

  @override
  Future<int> registerStep1(Step1Payload payload) async {
    final formData = FormData.fromMap({
      'first_name': payload.firstName,
      'last_name': payload.lastName,
      'email': payload.email,
      'phone': payload.phone,
      'password': payload.password,
      'location': payload.location,
      'working_distance': payload.workingDistance,
      'lat': payload.latitude.toString(),
      'lng': payload.longitude.toString(),
    });
    final profileImage = payload.profileImage;
    if (profileImage != null) {
      formData.files.add(
        MapEntry(
          'profile_photo',
          await MultipartFile.fromFile(
            profileImage.path,
            filename: profileImage.path.split('/').last,
          ),
        ),
      );
    }
    final response = await _client.dio.post<dynamic>(
      ApiEndpoints.register_step1,
      data: formData,
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected server response');
    }
    if (data['error'] == true) {
      throw Exception(data['message']?.toString() ?? 'Registration failed');
    }
    final crewMemberId = data['data']?['crew_member_id'];
    if (crewMemberId is int) return crewMemberId;
    final parsed = int.tryParse(crewMemberId?.toString() ?? '');
    if (parsed == null) {
      throw Exception('Crew member id not received');
    }
    return parsed;
  }

  @override
  Future<void> registerStep2(Step2Payload payload) async {
    final response = await _client.dio.post<dynamic>(
      ApiEndpoints.register_step2,
      data: {
        'crew_member_id': payload.crewMemberId,
        'primary_role': payload.primaryRoleIds,
        'years_of_experience': payload.yearsOfExperience,
        'hourly_rate': payload.hourlyRate,
        'bio': payload.bio,
        'skills': payload.skillIds,
        'equipment_ownership': payload.equipmentIds,
      },
    );
    _throwIfError(response.data, fallback: 'Step 2 failed');
  }

  @override
  Future<void> registerStep3(Step3Payload payload) async {
    final fields = <String, String>{
      'crew_member_id': payload.crewMemberId.toString(),
      'certifications': jsonEncode(
        payload.certificationFiles.map((f) => f.path.split('/').last).toList(),
      ),
      'social_media_links': jsonEncode(payload.socialMediaLinks),
      'portfolio_links': jsonEncode(payload.portfolioLinks),
      'featured_work': jsonEncode(payload.featuredWork),
    };

    final formData = FormData.fromMap(fields);

    Future<void> appendFile(String field, File file) async {
      formData.files.add(
        MapEntry(
          field,
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ),
      );
    }

    if (payload.resume != null) await appendFile('resume', payload.resume!);
    if (payload.portfolio != null) {
      await appendFile('portfolio', payload.portfolio!);
    }
    for (final f in payload.certificationFiles) {
      await appendFile('certifications', f);
    }
    for (var i = 0; i < payload.recentWorkMediaFiles.length; i++) {
      await appendFile('recent_work_media', payload.recentWorkMediaFiles[i]);
      formData.fields.add(
        MapEntry(
          'recent_work_media_index',
          payload.recentWorkMediaIndexes[i].toString(),
        ),
      );
    }

    final response = await _client.dio.post<dynamic>(
      ApiEndpoints.register_step3,
      data: formData,
    );
    _throwIfError(response.data, fallback: 'Step 3 failed');
  }

  @override
  Future<List<LookupOption>> fetchRoles() async {
    final response = await _client.dio.get<dynamic>(
      ApiEndpoints.register_roles,
    );
    return _parseLookups(
      response.data,
      idKey: 'role_id',
      nameKey: 'role_name',
      fallback: 'Failed to load roles',
    );
  }

  @override
  Future<List<LookupOption>> fetchSkills() async {
    final response = await _client.dio.get<dynamic>(
      ApiEndpoints.register_Skill,
    );
    return _parseLookups(
      response.data,
      idKey: 'id',
      nameKey: 'name',
      fallback: 'Failed to load skills',
    );
  }

  @override
  Future<List<LookupOption>> searchEquipments(String query) async {
    final response = await _client.dio.get<dynamic>(
      '${ApiEndpoints.register_equipment}?query=$query',
    );
    return _parseLookups(
      response.data,
      idKey: 'equipment_id',
      nameKey: 'equipment_name',
      fallback: 'Failed to load equipment',
    );
  }

  List<LookupOption> _parseLookups(
    dynamic data, {
    required String idKey,
    required String nameKey,
    required String fallback,
  }) {
    if (data is! Map<String, dynamic>) {
      throw Exception(fallback);
    }
    if (data['error'] == true) {
      throw Exception(data['message']?.toString() ?? fallback);
    }
    final list = data['data'];
    if (list is! List) return const [];
    final seen = <String>{};
    final result = <LookupOption>[];
    for (final raw in list) {
      if (raw is! Map) continue;
      final name = raw[nameKey]?.toString();
      final id = raw[idKey];
      if (name == null || name.isEmpty || id is! int) continue;
      if (seen.add(name)) {
        result.add(LookupOption(id: id, name: name));
      }
    }
    return result;
  }
}
