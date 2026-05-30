import 'dart:convert';
import 'dart:io';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../model_class/myprofile_model.dart';
import '../../../../service/api_service.dart';
import '../../domain/repositories/profile_files_repository.dart';

class ProfileFilesRepositoryImpl implements ProfileFilesRepository {
  final DioClient _client;
  final ApiService _multipartShim;

  ProfileFilesRepositoryImpl(this._client, {ApiService? multipartShim})
      : _multipartShim = multipartShim ?? ApiService();

  @override
  Future<Data> fetchProfile() async {
    final response =
        await _client.dio.post<dynamic>(ApiEndpoints.profiledetails, data: {});
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Profile fetch returned unexpected payload');
    }
    if (data['error'] == true) {
      throw Exception(data['message'] ?? 'Profile fetch failed');
    }
    return Myprofilemodel.fromJson(data).data;
  }

  @override
  Future<void> uploadResume(File file) async {
    await _multipartUpload(ApiEndpoints.upload_resume, file);
  }

  @override
  Future<void> uploadCertificate(File file) async {
    await _multipartUpload(ApiEndpoints.upload_certifications, file);
  }

  @override
  Future<void> uploadFeaturedWork({
    required String title,
    required List<String> tags,
    required List<File> files,
  }) async {
    final response = await _multipartShim.postMultipartDataMultiple(
      ApiEndpoints.upload_recent_work,
      {
        'title': title,
        'tag': jsonEncode(tags),
      },
      files,
    );
    if (response == null || response is! Map || response['error'] != false) {
      throw Exception(
        (response is Map ? response['message'] : null) ?? 'Upload failed',
      );
    }
  }

  @override
  Future<void> deleteFile(int id) async {
    final response = await _client.dio.delete<dynamic>(
      '${ApiEndpoints.delete_allfiles}/$id',
    );
    final data = response.data;
    if (data is Map && data['error'] == true) {
      throw Exception(data['message'] ?? 'Delete failed');
    }
  }

  Future<void> _multipartUpload(String path, File file) async {
    final response = await _multipartShim.postMultipartData(path, {}, file);
    if (response == null || response is! Map || response['error'] != false) {
      throw Exception(
        (response is Map ? response['message'] : null) ?? 'Upload failed',
      );
    }
  }
}
