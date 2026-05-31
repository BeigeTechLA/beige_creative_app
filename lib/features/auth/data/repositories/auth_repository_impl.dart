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
    UserSnapshot? user;
    final rawUser = payload['user'];
    if (rawUser is Map<String, dynamic>) {
      try {
        user = UserSnapshot.fromJson(rawUser);
      } catch (_) {
        user = null;
      }
    }
    return LoginResult(token: token, user: user);
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
      'profile_photo': await MultipartFile.fromFile(
        payload.profileImage.path,
        filename: payload.profileImage.path.split('/').last,
      ),
    });
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
        payload.certificationFiles
            .map((f) => f.path.split('/').last)
            .toList(),
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
    final response =
        await _client.dio.get<dynamic>(ApiEndpoints.register_roles);
    return _parseLookups(
      response.data,
      idKey: 'role_id',
      nameKey: 'role_name',
      fallback: 'Failed to load roles',
    );
  }

  @override
  Future<List<LookupOption>> fetchSkills() async {
    final response =
        await _client.dio.get<dynamic>(ApiEndpoints.register_Skill);
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
