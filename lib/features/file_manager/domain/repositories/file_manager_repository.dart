import 'package:dio/dio.dart' show CancelToken;

import '../models/fm_node.dart';
import '../models/fm_page.dart';
import '../models/fm_tab.dart';

/// Stable interface for the file-manager surface. Two implementations live
/// side-by-side and are selected via `useDummyFileManagerProvider`:
///
/// - [FileManagerRepositoryDummy] (FM1.04) — in-memory recursive tree, used
///   while UI ships against fake data.
/// - [FileManagerRepositoryRemote] (FM6.02) — Dio against
///   `/api/file-manager/...` (see `FILE_MANAGER_UI_PLAN.md` §8).
///
/// Test fakes implement this contract directly so production code never
/// branches on test vs prod.
abstract class FileManagerRepository {
  /// Root tab — only folders show at the root per the reference design.
  /// `cursor == null` requests the first page; backend returns
  /// `page.nextCursor == null` to signal end-of-stream.
  Future<FmPage<FmFolder>> listRoot({
    required FmTab tab,
    String? cursor,
    int limit = 20,
  });

  /// Children of a folder — a mixed list of nested folders + files in the
  /// order the backend returns. The UI never re-sorts.
  Future<FmPage<FmNode>> listFolder({
    required String folderId,
    String? cursor,
    int limit = 20,
  });

  /// Generates / fetches a shareable URL. Returns the URL alone (the
  /// expiry is server-tracked; UI doesn't surface it in FM4).
  Future<String> getShareLink({
    required String nodeId,
    required FmNodeKind kind,
  });

  /// Hard delete. Caller invalidates the appropriate notifier on success.
  Future<void> deleteNode({
    required String nodeId,
    required FmNodeKind kind,
  });

  /// Streams the binary to a temp file. Returns the absolute local path so
  /// the caller can pipe it into `share_plus` "open with". [onProgress]
  /// receives values in `0.0..1.0`; [cancelToken] aborts the transfer
  /// (e.g. when the user pops the action sheet mid-download).
  Future<String> downloadFile({
    required String fileId,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  });
}
