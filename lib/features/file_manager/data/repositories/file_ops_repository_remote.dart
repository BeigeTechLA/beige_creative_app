import '../../domain/models/fm_copy_result.dart';
import '../../domain/models/fm_delete_result.dart';
import '../../domain/models/fm_phase.dart';
import '../../domain/models/fm_revision_action.dart';
import '../../domain/models/fm_revision_result.dart';
import '../../domain/models/fm_signed_url.dart';
import '../../domain/repositories/file_ops_repository.dart';
import '../sources/file_ops_remote_source.dart';

class FileOpsRepositoryRemote implements FileOpsRepository {
  FileOpsRepositoryRemote(this._remote);

  final FileOpsRemoteSource _remote;

  @override
  Future<FmSignedUrl> viewUrl(String filepath) => _remote.viewUrl(filepath);

  @override
  Future<FmSignedUrl> downloadUrl(String filepath) =>
      _remote.downloadUrl(filepath);

  @override
  Future<FmSignedUrl> folderDownloadUrl({
    required String externalId,
    FmPhase? phase,
    String? path,
  }) => _remote.folderDownloadUrl(
    externalId: externalId,
    phase: phase,
    path: path,
  );

  @override
  Future<FmDeleteResult> delete(String filepath) => _remote.delete(filepath);

  @override
  Future<FmCopyResult> copyFiles({
    required String externalId,
    required FmPhase phase,
    required String targetPath,
    required List<String> sourcePaths,
  }) => _remote.copyFiles(
    externalId: externalId,
    phase: phase,
    targetPath: targetPath,
    sourcePaths: sourcePaths,
  );

  @override
  Future<FmRevisionResult> reviewRevision({
    required String externalId,
    required String filepath,
    required FmRevisionAction action,
  }) => _remote.reviewRevision(
    externalId: externalId,
    filepath: filepath,
    action: action,
  );
}
