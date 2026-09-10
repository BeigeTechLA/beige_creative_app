import '../../domain/models/fm_common_event.dart';
import '../../domain/models/fm_node.dart';
import '../../domain/models/fm_page.dart';
import '../../domain/repositories/workspaces_repository.dart';
import '../dummy/dummy_file_tree.dart';

/// In-memory workspaces impl reusing [DummyFileTree] roots so the UI keeps
/// working while the remote path lights up. Common events use a small
/// hand-rolled list — the dummy tree has no equivalent structure.
class WorkspacesRepositoryDummy implements WorkspacesRepository {
  static const Duration _latency = Duration(milliseconds: 300);

  @override
  Future<FmPage<FmFolder>> list({
    String? cursor,
    int limit = 20,
    String? workspaceType,
  }) async {
    await Future<void>.delayed(_latency);
    final roots = (DummyFileTree.tree[DummyFileTree.rootKey] ?? const [])
        .whereType<FmFolder>()
        .toList();

    // Mimic the server-side `recent` filter: sort newest-first.
    if (workspaceType == 'recent') {
      roots.sort((a, b) => (b.openedAt ?? DateTime(0))
          .compareTo(a.openedAt ?? DateTime(0)));
    }

    final offset = int.tryParse(cursor ?? '0') ?? 0;
    final end = (offset + limit).clamp(0, roots.length);
    final slice = roots.sublist(offset.clamp(0, roots.length), end);
    final nextCursor = end < roots.length ? end.toString() : null;
    return FmPage<FmFolder>(
      items: slice,
      nextCursor: nextCursor,
      total: roots.length,
    );
  }

  @override
  Future<List<FmCommonEvent>> listCommonEvents() async {
    await Future<void>.delayed(_latency);
    return [
      FmCommonEvent(
        eventId: 1,
        eventName: 'Common',
        eventSlug: 'common',
        externalId: 'event_common_1776350861294',
        rootPath: 'Event - Common/',
        createdAt: DateTime(2026, 4, 16),
        updatedAt: DateTime(2026, 4, 16),
      ),
      FmCommonEvent(
        eventId: 2,
        eventName: 'Diwana December Event',
        eventSlug: 'diwana_december_event',
        externalId: 'event_diwana_december_event_1776415230475',
        rootPath: 'Event - Diwana December Event/',
        createdAt: DateTime(2026, 4, 17),
        updatedAt: DateTime(2026, 4, 17),
      ),
    ];
  }
}
