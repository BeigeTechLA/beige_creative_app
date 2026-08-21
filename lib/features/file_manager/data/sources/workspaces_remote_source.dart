import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../domain/models/fm_common_event.dart';
import '../../domain/models/fm_node.dart';
import '../../domain/models/fm_page.dart';
import '../dtos/fm_common_event_dto.dart';
import '../dtos/fm_envelope_dto.dart';
import '../dtos/fm_workspace_dto.dart';

/// Dio-backed source for the workspace root endpoints. Thin wrapper —
/// DioException → AppException via [ExceptionHandler.mapDioException].
class WorkspacesRemoteSource {
  WorkspacesRemoteSource(this._client);

  final DioClient _client;
  Dio get _dio => _client.dio;

  Future<FmPage<FmFolder>> list({String? cursor, int limit = 20}) async {
    try {
      final page = int.tryParse(cursor ?? '') ?? 1;
      final resp = await _dio.get<dynamic>(
        ApiEndpoints.fmWorkspaces,
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = FmJson.asMap(FmJson.unwrap(resp.data)) ?? const {};
      final items = FmJson.asList(data['workspaces'])
          .map(FmWorkspaceDto.fromJson)
          .toList();
      final pagination = FmJson.asMap(data['pagination']);
      final nextCursor = pagination != null
          ? FmPaginationDto.fromJson(pagination).nextPageCursor
          : null;
      return FmPage<FmFolder>(
        items: items,
        nextCursor: nextCursor,
        total: pagination == null ? null : FmJson.asInt(pagination['total']),
      );
    } on DioException catch (e, st) {
      throw ExceptionHandler.mapDioException(e, st);
    }
  }

  Future<List<FmCommonEvent>> listCommonEvents() async {
    try {
      final resp = await _dio.get<dynamic>(ApiEndpoints.fmCommonEvents);
      return FmCommonEventDto.listFromJson(FmJson.unwrap(resp.data));
    } on DioException catch (e, st) {
      throw ExceptionHandler.mapDioException(e, st);
    }
  }
}
