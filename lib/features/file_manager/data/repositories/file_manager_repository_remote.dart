import 'package:dio/dio.dart';

import '../../domain/models/fm_node.dart';
import '../../domain/models/fm_page.dart';
import '../../domain/models/fm_tab.dart';
import '../../domain/repositories/file_manager_repository.dart';
import '../sources/file_manager_remote_source.dart';

/// Dio-backed implementation. Pure pass-through to
/// [FileManagerRemoteSource] — feature lives at the source layer.
class FileManagerRepositoryRemote implements FileManagerRepository {
  FileManagerRepositoryRemote(this._remote);

  final FileManagerRemoteSource _remote;

  @override
  Future<FmPage<FmFolder>> listRoot({
    required FmTab tab,
    String? cursor,
    int limit = 20,
  }) => _remote.listRoot(tab: tab, cursor: cursor, limit: limit);

  @override
  Future<FmPage<FmNode>> listFolder({
    required String folderId,
    String? cursor,
    int limit = 20,
  }) => _remote.listFolder(folderId: folderId, cursor: cursor, limit: limit);

  @override
  Future<String> getShareLink({
    required String nodeId,
    required FmNodeKind kind,
  }) => _remote.getShareLink(nodeId: nodeId, kind: kind);

  @override
  Future<void> deleteNode({
    required String nodeId,
    required FmNodeKind kind,
  }) => _remote.deleteNode(nodeId: nodeId, kind: kind);

  @override
  Future<String> downloadFile({
    required String fileId,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) => _remote.downloadFile(
    fileId: fileId,
    onProgress: onProgress,
    cancelToken: cancelToken,
  );
}
