import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env.dart';
import '../core/network/dio_client.dart';
import '../core/network/interceptors/auth_interceptor.dart';
import '../core/network/interceptors/error_interceptor.dart';
import '../core/network/interceptors/logging_interceptor.dart';
import '../core/network/interceptors/retry_interceptor.dart';
import '../core/utils/app_logger.dart';
import 'prefs_service.dart';

/// Legacy facade. Internals now run through `DioClient` + the canonical
/// interceptor chain. Public signatures are unchanged so the 68 existing
/// call sites compile without edits — Phase 4 migrates them feature-by-feature.
///
/// **Auth token** is no longer injected per-call here — `AuthInterceptor` handles
/// it via `PrefsService.token`. `createAuthorizationHeader()` has been removed.
class ApiService {
  static DioClient? _client;

  /// Lazily-built shared `DioClient` reused across all `ApiService()` instances.
  /// Interceptor chain: `Auth → Retry → Error → Logging` (dev only).
  static DioClient _ensureClient() {
    final existing = _client;
    if (existing != null) return existing;
    final client = DioClient();
    client.attachInterceptors([
      AuthInterceptor(
        tokenReader: () async => PrefsService.token,
      ),
      RetryInterceptor(dio: client.dio),
      ErrorInterceptor(),
      if (kDebugMode) LoggingInterceptor(),
    ]);
    _client = client;
    return client;
  }

  Dio get _dio => _ensureClient().dio;

  final String _baseUrl = Env.apiUrl;
  String get baseUrl => _baseUrl;

  static String imageURL = Env.imageUrl;

  String getImageURL(String imagePath) => imageURL + imagePath;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Generic REST verbs (return decoded JSON — Map or List)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Future<dynamic> fetchData(String url) async {
    try {
      final response = await _dio.get<dynamic>(url);
      if (_isSuccess(response.statusCode)) return response.data;
      throw Exception('Failed to load data');
    } on DioException catch (e) {
      AppLogger.e('GET $url failed: ${e.response?.statusCode}', e);
      throw Exception('Failed to load data');
    }
  }

  Future<dynamic> postData(String url, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post<dynamic>(url, data: data);
      if (_isSuccess(response.statusCode)) return response.data;
      throw Exception('Failed to post data');
    } on DioException catch (e) {
      AppLogger.e('POST $url failed: ${e.response?.statusCode}', e);
      throw Exception('Failed to post data');
    }
  }

  Future<Map<String, dynamic>> putData(
    String url,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put<dynamic>(url, data: data);
      if (_isSuccess(response.statusCode)) {
        final body = response.data;
        if (body is Map<String, dynamic>) return body;
        return <String, dynamic>{};
      }
      throw Exception('Failed to update data');
    } on DioException catch (e) {
      AppLogger.e('PUT $url failed: ${e.response?.statusCode}', e);
      throw Exception('Failed to update data');
    }
  }

  Future<dynamic> deleteData(String url) async {
    try {
      final response = await _dio.delete<dynamic>(url);
      if (_isSuccess(response.statusCode)) return response.data;
      throw Exception('Failed to delete data');
    } on DioException catch (e) {
      AppLogger.e('DELETE $url failed: ${e.response?.statusCode}', e);
      throw Exception('Failed to delete data');
    }
  }

  /// Same as [postData] — preserved for the existing caller surface.
  Future<dynamic> postDataraw(String url, Map<String, dynamic> data) =>
      postData(url, data);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Multipart variants — auth applied via interceptor (was bypassed in Step 3).
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Profile-photo upload. Sends file as `profile_photo`.
  Future<dynamic> postMultipart(
    String url,
    Map<String, String> fields,
    File? imageFile,
  ) async {
    final formData = FormData.fromMap({
      ...fields,
      if (imageFile != null)
        'profile_photo': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
    });
    try {
      final response = await _dio.post<dynamic>(url, data: formData);
      return response.data;
    } on DioException catch (e) {
      AppLogger.e('postMultipart $url failed: ${e.response?.statusCode}', e);
      rethrow;
    }
  }

  /// Generic single-file upload. Sends file as `files[]`.
  Future<dynamic> postMultipartData(
    String url,
    Map<String, String> fields,
    File? file,
  ) async {
    final formData = FormData.fromMap(fields);
    if (file != null) {
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
    try {
      final response = await _dio.post<dynamic>(url, data: formData);
      return response.data;
    } on DioException catch (e) {
      AppLogger.e(
        'postMultipartData $url failed: ${e.response?.statusCode}',
        e,
      );
      return null;
    }
  }

  /// Multi-file upload. All files sent under `files[]`.
  Future<dynamic> postMultipartDataMultiple(
    String url,
    Map<String, String> fields,
    List<File> files,
  ) async {
    final formData = FormData.fromMap(fields);
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
    try {
      final response = await _dio.post<dynamic>(url, data: formData);
      return response.data;
    } on DioException catch (e) {
      AppLogger.e(
        'postMultipartDataMultiple $url failed: ${e.response?.statusCode}',
        e,
      );
      return null;
    }
  }

  /// Registration step 3 — composite upload of resume + portfolio +
  /// certifications (multi) + recent work media (with paired index).
  /// Now goes through the shared client (auth interceptor applies — fixes the
  /// legacy bug where Step 3 bypassed auth entirely).
  Future<dynamic> postMultipartStep3(
    String url, {
    required Map<String, String> fields,
    File? resume,
    File? portfolio,
    List<File>? certificates,
    List<File>? recentWorks,
    List<int>? recentWorkIndexes,
  }) async {
    final formData = FormData.fromMap(fields);

    if (resume != null) {
      formData.files.add(
        MapEntry(
          'resume',
          await MultipartFile.fromFile(
            resume.path,
            filename: resume.path.split('/').last,
          ),
        ),
      );
    }

    if (portfolio != null) {
      formData.files.add(
        MapEntry(
          'portfolio',
          await MultipartFile.fromFile(
            portfolio.path,
            filename: portfolio.path.split('/').last,
          ),
        ),
      );
    }

    if (certificates != null) {
      for (final file in certificates) {
        formData.files.add(
          MapEntry(
            'certifications',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }
    }

    if (recentWorks != null && recentWorkIndexes != null) {
      for (var i = 0; i < recentWorks.length; i++) {
        formData.files.add(
          MapEntry(
            'recent_work_media',
            await MultipartFile.fromFile(
              recentWorks[i].path,
              filename: recentWorks[i].path.split('/').last,
            ),
          ),
        );
        formData.fields.add(
          MapEntry(
            'recent_work_media_index',
            recentWorkIndexes[i].toString(),
          ),
        );
      }
    }

    final response = await _dio.post<dynamic>(url, data: formData);
    return response.data;
  }

  static bool _isSuccess(int? status) =>
      status != null && status >= 200 && status < 300;
}
