import '../../domain/models/fm_folder_contents.dart';
import '../../domain/models/fm_folder_created.dart';
import '../../domain/models/fm_folder_key.dart';
import '../../domain/models/fm_node.dart';
import '../../domain/models/fm_phase.dart';
import '../../domain/repositories/folder_browse_repository.dart';
import '../dummy/dummy_file_tree.dart';

/// In-memory browse impl reusing [DummyFileTree]. Ignores `phase` and
/// `path` — the fake tree is keyed by opaque folder id, which the screen
/// passes as `FmFolderKey.externalId` (default fallback when a real
/// `nextKey` is not attached).
class FolderBrowseRepositoryDummy implements FolderBrowseRepository {
  static const Duration _latency = Duration(milliseconds: 300);

  final Map<String, List<FmNode>> _tree = {
    for (final entry in DummyFileTree.tree.entries)
      entry.key: List<FmNode>.from(entry.value),
  };

  @override
  Future<FmFolderContents> open(FmFolderKey key) async {
    await Future<void>.delayed(_latency);
    final children = _tree[key.externalId] ?? const [];
    return FmFolderContents(
      key: key,
      basePath: '${key.externalId}/',
      items: List<FmNode>.from(children),
    );
  }

  @override
  Future<FmFolderCreated> createFolder({
    required String externalId,
    required FmPhase phase,
    String path = '',
    required String folderName,
  }) async {
    await Future<void>.delayed(_latency);
    final id = 'fld_dummy_${DateTime.now().millisecondsSinceEpoch}';
    return FmFolderCreated(
      id: id,
      path: '$externalId/${phase.folderSegment}/${path.isEmpty ? '' : '$path/'}$folderName/',
      name: folderName,
    );
  }
}
