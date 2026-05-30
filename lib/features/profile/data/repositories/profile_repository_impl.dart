import 'dart:io';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../model_class/edit_profile_model.dart';
import '../../../../service/api_service.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final DioClient _client;
  final ApiService _multipartShim;

  ProfileRepositoryImpl(this._client, {ApiService? multipartShim})
      : _multipartShim = multipartShim ?? ApiService();

  @override
  Future<EditProfileModel> fetchEditProfile() async {
    final response =
        await _client.dio.post<dynamic>(ApiEndpoints.editprofile, data: {});
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Edit profile fetch returned unexpected payload');
    }
    if (data['error'] == true) {
      throw Exception(data['message'] ?? 'Edit profile fetch failed');
    }
    return EditProfileResponse.fromJson(data).data;
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> body) async {
    final response =
        await _client.dio.post<dynamic>(ApiEndpoints.editprofile, data: body);
    final data = response.data;
    if (data is Map && data['error'] == true) {
      throw Exception(data['message'] ?? 'Update failed');
    }
  }

  @override
  Future<Map<String, int>> fetchRoles() async {
    final response = await _client.dio.get<dynamic>(ApiEndpoints.register_roles);
    final data = response.data;
    if (data is! Map || data['data'] is! List) {
      throw Exception('Roles fetch returned unexpected payload');
    }
    final out = <String, int>{};
    for (final item in data['data'] as List) {
      if (item is Map) {
        final name = item['role_name']?.toString();
        final id = item['role_id'];
        if (name != null && id is int) out[name] = id;
      }
    }
    return out;
  }

  @override
  Future<Map<String, int>> fetchSkills() async {
    final response = await _client.dio.get<dynamic>(ApiEndpoints.register_Skill);
    final data = response.data;
    if (data is! Map || data['data'] is! List) {
      throw Exception('Skills fetch returned unexpected payload');
    }
    final out = <String, int>{};
    for (final item in data['data'] as List) {
      if (item is Map) {
        final name = item['name']?.toString();
        final id = item['id'];
        if (name != null && id is int) out[name] = id;
      }
    }
    return out;
  }

  @override
  Future<String> uploadPhoto(File file, {String? crewMemberId}) async {
    final fields = <String, String>{};
    if (crewMemberId != null) fields['crew_member_id'] = crewMemberId;
    final response = await _multipartShim.postMultipart(
      ApiEndpoints.upload_profile_photo,
      fields,
      file,
    );
    if (response is Map && response['error'] == false) {
      final data = response['data'];
      if (data is Map) {
        return data['profile_image_url']?.toString() ?? '';
      }
      return '';
    }
    throw Exception(
      (response is Map ? response['message'] : null) ?? 'Photo upload failed',
    );
  }

  @override
  Future<void> updateSocialLinks(List<Map<String, String>> links) async {
    final response = await _client.dio.post<dynamic>(
      ApiEndpoints.editprofile,
      data: {'social_media_links': links},
    );
    final data = response.data;
    if (data is Map && data['error'] == true) {
      throw Exception(data['message'] ?? 'Update failed');
    }
  }

  @override
  Future<void> addPortfolioLinks(List<Map<String, dynamic>> links) async {
    final response = await _client.dio.post<dynamic>(
      ApiEndpoints.addportfoliolink,
      data: {'portfolio_links': links},
    );
    final data = response.data;
    if (data is Map && data['error'] == true) {
      throw Exception(data['message'] ?? 'Add failed');
    }
  }

  @override
  Future<void> editPortfolioLink({
    required int id,
    required String url,
    required String platform,
    required String title,
  }) async {
    final response = await _client.dio.post<dynamic>(
      '${ApiEndpoints.edit_portfolio_link}/$id',
      data: {
        'url': url,
        'platform': platform,
        'title': title,
      },
    );
    final data = response.data;
    if (data is Map && data['error'] == true) {
      throw Exception(data['message'] ?? 'Edit failed');
    }
  }
}
