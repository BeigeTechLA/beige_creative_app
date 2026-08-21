import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../domain/models/fm_node.dart';
import '../../domain/models/fm_page.dart';
import '../../domain/models/fm_tab.dart';
import '../dtos/fm_folder_dto.dart';
import '../dtos/fm_node_dto.dart';
import '../dtos/fm_page_dto.dart';

/// REST source for the file-manager endpoints. Mirrors the meetings remote
/// source: thin Dio wrapper + DioException → AppException via
/// [ExceptionHandler.mapDioException].
class FileManagerRemoteSource {
  FileManagerRemoteSource(this._client);

  final DioClient _client;
  Dio get _dio => _client.dio;

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DioException catch (e, st) {
      throw ExceptionHandler.mapDioException(e, st);
    }
  }

  Future<FmPage<FmFolder>> listRoot({
    required FmTab tab,
    String? cursor,
    int limit = 20,
  }) {
    return _guard(() async {
      final resp = await _dio.get<dynamic>(
        ApiEndpoints.fileManagerRoot,
        queryParameters: {
          'tab': tab.apiValue,
          'cursor': ?cursor,
          'limit': limit,
        },
      );
      return FmPageDto.fromJson<FmFolder>(
        _unwrap(resp.data),
        (j) => FmFolderDto.fromJson(j),
      );
    });
  }

  Future<FmPage<FmNode>> listFolder({
    required String folderId,
    String? cursor,
    int limit = 20,
  }) {
    return _guard(() async {
      final resp = await _dio.get<dynamic>(
        ApiEndpoints.fileManagerFolder(folderId),
        queryParameters: {
          'cursor': ?cursor,
          'limit': limit,
        },
      );
      return FmPageDto.fromJson<FmNode>(
        _unwrap(resp.data),
        (j) => FmNodeDto.fromJson(j),
      );
    });
  }

  Future<String> getShareLink({
    required String nodeId,
    required FmNodeKind kind,
  }) {
    return _guard(() async {
      final resp = await _dio.post<dynamic>(
        ApiEndpoints.fileManagerShare,
        data: {'nodeId': nodeId, 'kind': kind.apiValue},
      );
      final data = _unwrap(resp.data);
      if (data is Map && data['shareUrl'] is String) {
        return data['shareUrl'] as String;
      }
      throw const FormatException('share endpoint missing shareUrl field');
    });
  }

  Future<void> deleteNode({
    required String nodeId,
    required FmNodeKind kind,
  }) {
    return _guard(() async {
      final path = kind == FmNodeKind.folder
          ? ApiEndpoints.fileManagerFolderDelete(nodeId)
          : ApiEndpoints.fileManagerFileDelete(nodeId);
      await _dio.delete<dynamic>(path);
    });
  }

  Future<String> downloadFile({
    required String fileId,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) {
    return _guard(() async {
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/fm_$fileId';
      await _dio.download(
        ApiEndpoints.fileManagerFileDownload(fileId),
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (onProgress == null || total <= 0) return;
          onProgress(received / total);
        },
      );
      return savePath;
    });
  }

  /// `{ success, data, message }` envelope unwrap. Returns the raw `data`
  /// when present; otherwise returns the body unchanged so endpoints that
  /// already deliver the data directly still work.
  dynamic _unwrap(dynamic raw) {
    if (raw is Map && raw.containsKey('data')) return raw['data'];
    return raw;
  }
}
