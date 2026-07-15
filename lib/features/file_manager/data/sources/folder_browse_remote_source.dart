import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../domain/models/fm_folder_contents.dart';
import '../../domain/models/fm_folder_created.dart';
import '../../domain/models/fm_folder_key.dart';
import '../../domain/models/fm_phase.dart';
import '../dtos/fm_envelope_dto.dart';
import '../dtos/fm_folder_created_dto.dart';
import '../dtos/fm_workspace_detail_dto.dart';

/// Dio-backed source for the folder-browse surface. Thin wrapper — feature
/// logic (envelope unwrap, DTO → domain) lives on the DTOs.
class FolderBrowseRemoteSource {
  FolderBrowseRemoteSource(this._client);

  final DioClient _client;
  Dio get _dio => _client.dio;

  Future<FmFolderContents> open(FmFolderKey key) async {
    try {
      // Root of a workspace = detail endpoint (returns Pre/Post cards).
      // Anything below root = /files endpoint scoped by phase + path.
      final resp = await _dio.get<dynamic>(
        key.phase == FmPhase.root
            ? ApiEndpoints.fmWorkspace(key.externalId)
            : ApiEndpoints.fmWorkspaceFiles(key.externalId),
        queryParameters: key.phase == FmPhase.root
            ? null
            : {
                'phase': key.phase.apiValue,
                if (key.path.isNotEmpty) 'path': key.path,
              },
      );
      final data = FmJson.asMap(FmJson.unwrap(resp.data)) ?? const {};
      return FmWorkspaceDetailDto.fromJson(data, externalId: key.externalId);
    } on DioException catch (e, st) {
      throw ExceptionHandler.mapDioException(e, st);
    }
  }

  Future<FmFolderCreated> createFolder({
    required String externalId,
    required FmPhase phase,
    String path = '',
    required String folderName,
  }) async {
    try {
      // Doc §3.6 shows two request-body variants (endpoint 5 uses
      // `bookingId`, endpoint 12 uses `externalId`). Send both keys until
      // backend picks one — see PLAN §11 Q4. Numeric `bookingId` is
      // best-effort; string ids skip that field.
      final bookingId = int.tryParse(externalId);
      final body = <String, dynamic>{
        'bookingId': ?bookingId,
        'externalId': externalId,
        'phase': phase.apiValue,
        'path': path,
        'folderName': folderName,
      };
      final resp = await _dio.post<dynamic>(ApiEndpoints.fmFolder, data: body);
      final data = FmJson.asMap(FmJson.unwrap(resp.data)) ?? const {};
      return FmFolderCreatedDto.fromJson(data);
    } on DioException catch (e, st) {
      throw ExceptionHandler.mapDioException(e, st);
    }
  }
}
