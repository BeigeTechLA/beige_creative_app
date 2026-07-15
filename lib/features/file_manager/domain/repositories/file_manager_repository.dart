import 'package:dio/dio.dart' show CancelToken;

import '../models/fm_node.dart';
import '../models/fm_page.dart';
import '../models/fm_tab.dart';

/// **DEPRECATED — being removed in FM8.**
///
/// Superseded by the four path-addressed repositories introduced in the
/// FM7 series:
///
/// - `WorkspacesRepository` — root workspaces + common events.
/// - `FolderBrowseRepository` — open folder + create folder.
/// - `FileOpsRepository` — view / download / folder-download / delete.
/// - Upload flow rewrites through a dedicated multipart source in FM8.
///
/// Only remaining production caller is `FmUploadSheet._completeUpload`
/// (dummy-only save path). Delete once FM8.03 lands a real
/// `UploadNotifier`.
@Deprecated('Use Workspaces / FolderBrowse / FileOps repositories. Removed in FM8.')
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

  /// Uploads a batch of files to a specific target folder.
  Future<void> uploadFiles({
    required String folderId,
    required List<FmFile> files,
  });
}
