import '../entities/file_folder.dart';
import '../entities/file_item.dart';

/// Repository contract for the File Manager feature.
///
/// All methods are async so the swap to a real Dio-backed implementation
/// is a body-only change. The current implementation
/// (`FileManagerStubRepository`) returns hardcoded lists; replace it once
/// backend endpoints land.
abstract class FileManagerRepository {
  Future<List<FileFolder>> fetchAllFolders();

  Future<List<FileFolder>> fetchRecentFolders();

  Future<List<FileItem>> fetchPreProductionFiles(String folderId);

  Future<List<FileFolder>> fetchPostProductionFolders(String folderId);

  Future<FileFolder?> fetchFolder(String folderId);
}
