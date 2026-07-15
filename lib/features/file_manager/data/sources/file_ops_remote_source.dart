import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../domain/models/fm_copy_result.dart';
import '../../domain/models/fm_delete_result.dart';
import '../../domain/models/fm_phase.dart';
import '../../domain/models/fm_revision_action.dart';
import '../../domain/models/fm_revision_result.dart';
import '../../domain/models/fm_signed_url.dart';
import '../dtos/fm_copy_result_dto.dart';
import '../dtos/fm_delete_result_dto.dart';
import '../dtos/fm_envelope_dto.dart';
import '../dtos/fm_revision_result_dto.dart';
import '../dtos/fm_signed_url_dto.dart';

class FileOpsRemoteSource {
  FileOpsRemoteSource(this._client);

  final DioClient _client;
  Dio get _dio => _client.dio;

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DioException catch (e, st) {
      throw ExceptionHandler.mapDioException(e, st);
    }
  }

  Future<FmSignedUrl> viewUrl(String filepath) => _guard(() async {
    final resp = await _dio.post<dynamic>(
      ApiEndpoints.fmFileViewUrl,
      data: {'filepath': filepath},
    );
    final data = FmJson.asMap(FmJson.unwrap(resp.data)) ?? const {};
    return FmSignedUrlDto.fromJson(data);
  });

  Future<FmSignedUrl> downloadUrl(String filepath) => _guard(() async {
    final resp = await _dio.post<dynamic>(
      ApiEndpoints.fmFileDownloadUrl,
      data: {'filepath': filepath},
    );
    final data = FmJson.asMap(FmJson.unwrap(resp.data)) ?? const {};
    return FmSignedUrlDto.fromJson(data);
  });

  Future<FmSignedUrl> folderDownloadUrl({
    required String externalId,
    FmPhase? phase,
    String? path,
  }) => _guard(() async {
    final body = <String, dynamic>{
      'externalId': externalId,
      'phase': ?phase?.apiValue,
      'path': ?(path?.isEmpty ?? true ? null : path),
    };
    final resp = await _dio.post<dynamic>(
      ApiEndpoints.fmFolderDownloadUrl,
      data: body,
    );
    final data = FmJson.asMap(FmJson.unwrap(resp.data)) ?? const {};
    return FmSignedUrlDto.fromJson(data);
  });

  Future<FmDeleteResult> delete(String filepath) => _guard(() async {
    final resp = await _dio.post<dynamic>(
      ApiEndpoints.fmDelete,
      data: {'filepath': filepath},
    );
    final data = FmJson.asMap(FmJson.unwrap(resp.data)) ?? const {};
    return FmDeleteResultDto.fromJson(data);
  });

  Future<FmCopyResult> copyFiles({
    required String externalId,
    required FmPhase phase,
    required String targetPath,
    required List<String> sourcePaths,
  }) => _guard(() async {
    final resp = await _dio.post<dynamic>(
      ApiEndpoints.fmCopyFiles,
      data: {
        'externalId': externalId,
        'phase': phase.apiValue,
        'targetPath': targetPath,
        'sourcePaths': sourcePaths,
      },
    );
    final data = FmJson.asMap(FmJson.unwrap(resp.data)) ?? const {};
    return FmCopyResultDto.fromJson(data);
  });

  Future<FmRevisionResult> reviewRevision({
    required String externalId,
    required String filepath,
    required FmRevisionAction action,
  }) => _guard(() async {
    final resp = await _dio.post<dynamic>(
      ApiEndpoints.fmRevisionReview,
      data: {
        'externalId': externalId,
        'filepath': filepath,
        'action': action.apiValue,
      },
    );
    final data = FmJson.asMap(FmJson.unwrap(resp.data)) ?? const {};
    return FmRevisionResultDto.fromJson(data);
  });
}
