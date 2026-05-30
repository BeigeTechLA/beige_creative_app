import '../../domain/entities/file_folder.dart';
import '../../domain/entities/file_item.dart';
import '../../domain/repositories/file_manager_repository.dart';

/// Hardcoded-data stand-in until backend endpoints land.
///
/// Mirrors the shape the legacy screens hardcoded inline (20 identical
/// "Lana #123456" folders, alternating pdf/doc files). When the real API
/// arrives, swap this for a Dio-backed impl that hits `ApiEndpoints.*`;
/// no notifier or screen code should need to change.
class FileManagerStubRepository implements FileManagerRepository {
  const FileManagerStubRepository();

  static const _folder = FileFolder(
    id: 'lana-123456',
    name: 'Lana #123456',
    fileCount: 2,
    category: 'Corporate Event',
    ownerInitials: 'DP',
    openedAtLabel: 'Opened 2 hours ago',
  );

  @override
  Future<List<FileFolder>> fetchAllFolders() async =>
      List.generate(20, (_) => _folder);

  @override
  Future<List<FileFolder>> fetchRecentFolders() async =>
      List.generate(20, (_) => _folder);

  @override
  Future<List<FileItem>> fetchPreProductionFiles(String folderId) async {
    return List.generate(6, (index) {
      final isPdf = index % 2 == 0;
      return FileItem(
        id: '$folderId-$index',
        name: isPdf ? 'Example.pdf' : 'Example.docx',
        kind: isPdf ? FileKind.pdf : FileKind.doc,
        ownerInitials: 'DP',
        openedAtLabel: 'Opened 2 hours ago',
      );
    });
  }

  @override
  Future<List<FileFolder>> fetchPostProductionFolders(String folderId) async =>
      List.generate(20, (_) => _folder);

  @override
  Future<FileFolder?> fetchFolder(String folderId) async => _folder;
}
