import '../../domain/models/fm_folder_contents.dart';
import '../../domain/models/fm_folder_created.dart';
import '../../domain/models/fm_folder_key.dart';
import '../../domain/models/fm_phase.dart';
import '../../domain/repositories/folder_browse_repository.dart';
import '../sources/folder_browse_remote_source.dart';

class FolderBrowseRepositoryRemote implements FolderBrowseRepository {
  FolderBrowseRepositoryRemote(this._remote);

  final FolderBrowseRemoteSource _remote;

  @override
  Future<FmFolderContents> open(FmFolderKey key) => _remote.open(key);

  @override
  Future<FmFolderCreated> createFolder({
    required String externalId,
    required FmPhase phase,
    String path = '',
    required String folderName,
  }) => _remote.createFolder(
    externalId: externalId,
    phase: phase,
    path: path,
    folderName: folderName,
  );
}
