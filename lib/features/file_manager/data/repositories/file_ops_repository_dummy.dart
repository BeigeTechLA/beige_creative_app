import '../../domain/models/fm_copy_result.dart';
import '../../domain/models/fm_delete_result.dart';
import '../../domain/models/fm_phase.dart';
import '../../domain/models/fm_revision_action.dart';
import '../../domain/models/fm_revision_result.dart';
import '../../domain/models/fm_signed_url.dart';
import '../../domain/repositories/file_ops_repository.dart';
import '../dummy/dummy_file_tree.dart';

/// In-memory file-ops impl. Returns fake URLs (`https://files.dummy/...`)
/// so the OS-handoff plumbing (`url_launcher`, `share_plus`) can still
/// be exercised end-to-end without a live backend. Delete mutates
/// [DummyFileTree.tree] so the UI sees the row drop.
class FileOpsRepositoryDummy implements FileOpsRepository {
  static const Duration _latency = Duration(milliseconds: 200);

  @override
  Future<FmSignedUrl> viewUrl(String filepath) async {
    await Future<void>.delayed(_latency);
    return FmSignedUrl(url: 'https://files.dummy/view/$filepath');
  }

  @override
  Future<FmSignedUrl> downloadUrl(String filepath) async {
    await Future<void>.delayed(_latency);
    return FmSignedUrl(url: 'https://files.dummy/download/$filepath');
  }

  @override
  Future<FmSignedUrl> folderDownloadUrl({
    required String externalId,
    FmPhase? phase,
    String? path,
  }) async {
    await Future<void>.delayed(_latency);
    final segments = [
      externalId,
      if (phase != null && phase != FmPhase.root) phase.folderSegment,
      if (path != null && path.isNotEmpty) path,
    ].join('/');
    return FmSignedUrl(url: 'https://files.dummy/zip/$segments', filepath: segments);
  }

  @override
  Future<FmDeleteResult> delete(String filepath) async {
    await Future<void>.delayed(_latency);

    // Match either the filepath OR the trailing segment (dummy tree
    // uses opaque folder ids as keys — `filepath` from screens will
    // just be that id for dummy nodes).
    final target = filepath.endsWith('/')
        ? filepath.substring(0, filepath.length - 1)
        : filepath;
    var removed = 0;

    for (final entry in DummyFileTree.tree.entries) {
      final before = entry.value.length;
      entry.value.removeWhere((n) => n.id == target || n.id == filepath);
      removed += before - entry.value.length;
    }

    // Drop subtree so folder deletes look like server-side cascades.
    if (DummyFileTree.tree.containsKey(target)) {
      DummyFileTree.tree.remove(target);
    }

    return FmDeleteResult(
      deleted: removed > 0,
      deletedCount: removed,
    );
  }

  @override
  Future<FmRevisionResult> reviewRevision({
    required String externalId,
    required String filepath,
    required FmRevisionAction action,
  }) async {
    await Future<void>.delayed(_latency);
    switch (action) {
      case FmRevisionAction.requestRevision:
        return FmRevisionResult(
          action: action,
          versionNumber: 1,
          nextVersionNumber: 2,
          nextVersionPath: '$externalId/Post-Production/Edits/Revisions/Version2',
        );
      case FmRevisionAction.approve:
        final name = filepath.split('/').last;
        return FmRevisionResult(
          action: action,
          versionNumber: 1,
          finalDeliverable: FmRevisionDeliverable(
            id: 'fld_dummy_final_${DateTime.now().millisecondsSinceEpoch}',
            path: '$externalId/Post-Production/Final Deliverables/$name',
            name: name,
          ),
        );
    }
  }

  @override
  Future<FmCopyResult> copyFiles({
    required String externalId,
    required FmPhase phase,
    required String targetPath,
    required List<String> sourcePaths,
  }) async {
    await Future<void>.delayed(_latency);
    return FmCopyResult(
      total: sourcePaths.length,
      successCount: sourcePaths.length,
      failedCount: 0,
      sourcePath: sourcePaths.firstOrNull,
      targetPath: targetPath,
      items: [
        for (final p in sourcePaths)
          FmCopyItem(
            sourcePath: p,
            destinationPath: '$targetPath/${p.split('/').last}',
            success: true,
          ),
      ],
    );
  }
}
