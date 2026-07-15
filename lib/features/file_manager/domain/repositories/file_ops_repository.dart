import '../models/fm_copy_result.dart';
import '../models/fm_delete_result.dart';
import '../models/fm_phase.dart';
import '../models/fm_revision_action.dart';
import '../models/fm_revision_result.dart';
import '../models/fm_signed_url.dart';

/// Path-addressed file operations. All URL-returning methods hand the
/// URL to the OS via `url_launcher` / `share_plus` — see
/// `FILE_MANAGER_API_PLAN.md` §4.9. The app never streams the bytes.
///
/// Split from the legacy `FileManagerRepository` facade so FM7.05+
/// callers can migrate at their own pace.
abstract class FileOpsRepository {
  /// `POST /external-file-manager/file-view-url` — signed URL suitable
  /// for inline OS render (browser, native player).
  Future<FmSignedUrl> viewUrl(String filepath);

  /// `POST /external-file-manager/file-download-url` — signed URL that
  /// prompts a download when opened in a browser.
  Future<FmSignedUrl> downloadUrl(String filepath);

  /// `POST /external-file-manager/folder-download-url` — server-generated
  /// ZIP URL for an entire folder (or the whole workspace when [path] is
  /// null and [phase] is null).
  Future<FmSignedUrl> folderDownloadUrl({
    required String externalId,
    FmPhase? phase,
    String? path,
  });

  /// `POST /external-file-manager/delete`. Callers pass folder paths
  /// with a trailing `/` and file paths without one — [FmPath.forDelete]
  /// normalizes this at the boundary.
  Future<FmDeleteResult> delete(String filepath);

  /// `POST /external-file-manager/copy-files` — moves the source files
  /// into the target folder inside the workspace. Backs the Send-For-
  /// Edits flow (`sourcePaths` from Raw Footage → `targetPath` =
  /// `Edits/Selected for Edits`). Server fans out email notifications.
  Future<FmCopyResult> copyFiles({
    required String externalId,
    required FmPhase phase,
    required String targetPath,
    required List<String> sourcePaths,
  });

  /// `POST /external-file-manager/revision-file/review` — client-side
  /// review verdict on a revision. `requestRevision` returns
  /// `nextVersionPath` (a new VersionN+1 folder the client should route
  /// to); `approve` returns the final deliverable's landing path.
  Future<FmRevisionResult> reviewRevision({
    required String externalId,
    required String filepath,
    required FmRevisionAction action,
  });
}
