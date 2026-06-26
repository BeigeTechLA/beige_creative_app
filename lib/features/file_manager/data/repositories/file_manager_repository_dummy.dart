import 'package:dio/dio.dart' show CancelToken;

import '../../domain/models/fm_node.dart';
import '../../domain/models/fm_page.dart';
import '../../domain/models/fm_tab.dart';
import '../../domain/models/link_state.dart';
import '../../domain/repositories/file_manager_repository.dart';
import '../dummy/dummy_file_tree.dart';

/// In-memory implementation backed by [DummyFileTree]. Used while UI ships
/// against fake data — flipped off at FM6 by `useDummyFileManagerProvider`.
///
/// Mutations (delete) operate on the shared `DummyFileTree.tree` map so the
/// effect persists across notifier rebuilds within a single app session.
class FileManagerRepositoryDummy implements FileManagerRepository {
  static const Duration _latency = Duration(milliseconds: 300);

  /// Working copy so deletes survive notifier rebuilds without mutating the
  /// declared seed map literal.
  final Map<String, List<FmNode>> _tree = {
    for (final entry in DummyFileTree.tree.entries)
      entry.key: List<FmNode>.from(entry.value),
  };

  @override
  Future<FmPage<FmFolder>> listRoot({
    required FmTab tab,
    String? cursor,
    int limit = 20,
  }) async {
    await Future<void>.delayed(_latency);

    final roots = (_tree[DummyFileTree.rootKey] ?? const <FmNode>[])
        .whereType<FmFolder>()
        .toList();

    final filtered = _applyTabFilter(roots, tab);
    return _paginate(filtered, cursor: cursor, limit: limit);
  }

  @override
  Future<FmPage<FmNode>> listFolder({
    required String folderId,
    String? cursor,
    int limit = 20,
  }) async {
    await Future<void>.delayed(_latency);
    final children = _tree[folderId] ?? const <FmNode>[];
    return _paginate(children, cursor: cursor, limit: limit);
  }

  @override
  Future<String> getShareLink({
    required String nodeId,
    required FmNodeKind kind,
  }) async {
    await Future<void>.delayed(_latency);
    return 'https://files.dummy/share/${kind.apiValue}/$nodeId';
  }

  @override
  Future<void> deleteNode({
    required String nodeId,
    required FmNodeKind kind,
  }) async {
    await Future<void>.delayed(_latency);

    // Remove from whichever parent owns the node.
    for (final entry in _tree.entries) {
      entry.value.removeWhere((n) => n.id == nodeId);
    }

    // For folders, also drop the subtree so it can't be reached after delete.
    if (kind == FmNodeKind.folder) {
      _tree.remove(nodeId);
    }
  }

  @override
  Future<String> downloadFile({
    required String fileId,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    // Simulate streaming progress over ~600 ms in 6 ticks.
    for (int i = 1; i <= 6; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (cancelToken?.isCancelled ?? false) {
        throw StateError('Download cancelled');
      }
      onProgress?.call(i / 6);
    }
    return '/tmp/file_manager_dummy/$fileId';
  }

  // ── Internal helpers ────────────────────────────────────────────────

  List<FmFolder> _applyTabFilter(List<FmFolder> folders, FmTab tab) {
    switch (tab) {
      case FmTab.all:
        return folders;
      case FmTab.recent:
        final sorted = [...folders]
          ..sort((a, b) =>
              (b.openedAt ?? DateTime(0)).compareTo(a.openedAt ?? DateTime(0)));
        return sorted;
      case FmTab.linked:
        return folders.where((f) => f.linkState == LinkState.linked).toList();
      case FmTab.commonEvents:
        // Backend semantics for "common events" still TBD — surface as empty
        // so the empty-state branch gets exercised during UI work.
        return const [];
    }
  }

  FmPage<T> _paginate<T>(
    List<T> items, {
    required String? cursor,
    required int limit,
  }) {
    final offset = int.tryParse(cursor ?? '0') ?? 0;
    final end = (offset + limit).clamp(0, items.length);
    final slice = items.sublist(offset.clamp(0, items.length), end);
    final nextCursor = end < items.length ? end.toString() : null;
    return FmPage<T>(items: slice, nextCursor: nextCursor, total: items.length);
  }
}
