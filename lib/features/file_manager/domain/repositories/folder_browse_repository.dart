import '../models/fm_folder_contents.dart';
import '../models/fm_folder_created.dart';
import '../models/fm_folder_key.dart';
import '../models/fm_phase.dart';

/// Folder-level browse contract. Backed by:
///
/// - [open] → `GET /external-file-manager/workspace/{extId}` when
///   `phase == root`, else `GET /external-file-manager/workspace/{extId}/
///   files?phase&path`. Both responses share the same envelope shape so
///   the source layer normalizes them to [FmFolderContents].
/// - [createFolder] → `POST /external-file-manager/folder` — used by
///   the "Create Folder" CTA on Revisions and the free-form folder
///   create surface.
abstract class FolderBrowseRepository {
  Future<FmFolderContents> open(FmFolderKey key);

  Future<FmFolderCreated> createFolder({
    required String externalId,
    required FmPhase phase,
    String path = '',
    required String folderName,
  });
}
