import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../model_class/myprofile_model.dart';
import '../../domain/repositories/profile_files_repository.dart';

class ProfileFilesRepositoryImpl implements ProfileFilesRepository {
  final DioClient _client;

  ProfileFilesRepositoryImpl(this._client);

  @override
  Future<MyProfileData> fetchProfile() async {
    final response =
        await _client.dio.post<dynamic>(ApiEndpoints.profiledetails, data: {});
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Profile fetch returned unexpected payload');
    }
    if (data['error'] == true) {
      throw Exception(data['message'] ?? 'Profile fetch failed');
    }
    return MyProfileModel.fromJson(data).data;
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
    final formData = FormData.fromMap({
      'title': title,
      'tag': jsonEncode(tags),
    });
    for (final file in files) {
      formData.files.add(
        MapEntry(
          'files[]',
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ),
      );
    }
    final response = await _client.dio.post<dynamic>(
      ApiEndpoints.upload_recent_work,
      data: formData,
    );
    final body = response.data;
    if (body is! Map || body['error'] != false) {
      throw Exception(
        (body is Map ? body['message'] : null) ?? 'Upload failed',
      );
    }
  }

  @override
  Future<void> deleteFile(int id) async {
    if (id <= 0) {
      throw Exception('Invalid file ID ($id)');
    }
    final response = await _client.dio.delete<dynamic>(
      '${ApiEndpoints.delete_allfiles}/$id',
    );
    final data = response.data;
    if (data is Map && data['error'] == true) {
      throw Exception(data['message'] ?? 'Delete failed');
    }
  }

  Future<void> _multipartUpload(String path, File file) async {
    final formData = FormData.fromMap({});
    formData.files.add(
      MapEntry(
        'files[]',
        await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      ),
    );
    final response = await _client.dio.post<dynamic>(path, data: formData);
    final body = response.data;
    if (body is! Map || body['error'] != false) {
      throw Exception(
        (body is Map ? body['message'] : null) ?? 'Upload failed',
      );
    }
  }
}
