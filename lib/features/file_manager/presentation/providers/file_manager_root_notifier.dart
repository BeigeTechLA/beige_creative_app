import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/fm_common_event.dart';
import '../../domain/models/fm_node.dart';
import '../../domain/models/fm_tab.dart';
import '../../domain/models/fm_workspace_meta.dart';
import '../../domain/models/link_state.dart';
import '../../domain/repositories/workspaces_repository.dart';
import 'file_manager_root_state.dart';
import 'workspaces_repository_provider.dart';

/// Root screen notifier. Backed by [WorkspacesRepository]:
///
/// - `all` / `linked` → `list()` on the workspaces endpoint (paginated).
/// - `recent` → `list(workspaceType: 'recent', limit: 10)` — server
///   returns the feed newest-first; no client-side sort.
/// - `commonEvents` → `listCommonEvents()` (unpaginated in the API doc;
///   surfaced as a single page).
///
/// Filters other than pagination happen in-memory — the API does not
/// currently accept a tab or query param on these endpoints.
class FileManagerRootNotifier extends AutoDisposeNotifier<FileManagerRootState> {
  late WorkspacesRepository _repo;

  @override
  FileManagerRootState build() {
    _repo = ref.watch(workspacesRepositoryProvider);
    Future.microtask(_loadFirst);
    return const FileManagerRootState(status: FmListStatus.loading);
  }

  Future<void> _loadFirst() async {
    state = state.copyWith(
      status: FmListStatus.loading,
      items: const [],
      clearCursor: true,
      clearError: true,
    );
    try {
      if (state.tab == FmTab.commonEvents) {
        final events = await _repo.listCommonEvents();
        state = state.copyWith(
          items: events.map(_commonEventAsFolder).toList(),
          clearCursor: true,
          status: FmListStatus.ready,
        );
        return;
      }

      final page = await _repo.list(
        workspaceType: _workspaceTypeFor(state.tab),
        limit: _limitFor(state.tab),
      );
      state = state.copyWith(
        items: _applyTabFilter(page.items, state.tab),
        cursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        status: FmListStatus.ready,
      );
    } catch (e) {
      state = state.copyWith(
        status: FmListStatus.error,
        errorMessage: _messageFor(e),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.status == FmListStatus.loadingMore || !state.hasMore) return;
    if (state.tab == FmTab.commonEvents) return;
    state = state.copyWith(status: FmListStatus.loadingMore);
    try {
      final page = await _repo.list(
        cursor: state.cursor,
        workspaceType: _workspaceTypeFor(state.tab),
        limit: _limitFor(state.tab),
      );
      state = state.copyWith(
        items: _applyTabFilter(
          [...state.items, ...page.items],
          state.tab,
        ),
        cursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        status: FmListStatus.ready,
      );
    } catch (e) {
      state = state.copyWith(
        status: FmListStatus.ready,
        errorMessage: _messageFor(e),
      );
    }
  }

  Future<void> refresh() => _loadFirst();

  void selectTab(FmTab tab) {
    if (tab == state.tab) return;
    state = state.copyWith(tab: tab);
    _loadFirst();
  }

  void setSearchQuery(String query) {
    if (query == state.searchQuery) return;
    state = state.copyWith(searchQuery: query);
  }

  /// Filters + sorts a list of workspace folders for the current tab.
  /// The `/workspaces` endpoint returns everything; we slice it here.
  List<FmFolder> _applyTabFilter(List<FmFolder> items, FmTab tab) {
    switch (tab) {
      case FmTab.all:
        return items;
      case FmTab.recent:
        // Server returns newest-first via `workspaceType=recent`; no
        // client-side re-sort needed.
        return items;
      case FmTab.linked:
        return items
            .where((f) => f.linkState == LinkState.linked)
            .toList();
      case FmTab.commonEvents:
        return items;
    }
  }

  /// Adapts an [FmCommonEvent] into the [FmFolder] shape [FmRecursiveList]
  /// already renders — keeps the UI branch-free.
  FmFolder _commonEventAsFolder(FmCommonEvent e) => FmFolder(
    id: e.externalId,
    name: e.eventName,
    fileCount: 0,
    openedAt: e.updatedAt ?? e.createdAt,
    tagLabel: 'Common Event',
    linkState: LinkState.linked,
    workspaceMeta: FmWorkspaceMeta(
      rootPath: e.rootPath,
      isCommonEvent: true,
      eventId: e.eventId,
      eventName: e.eventName,
      visibleUntil: e.visibleUntil,
    ),
  );

  /// Server-side `workspaceType` filter for a tab, or `null` for the
  /// default (all) listing. `recent` is the only server-filtered tab;
  /// `linked` still slices client-side.
  String? _workspaceTypeFor(FmTab tab) =>
      tab == FmTab.recent ? 'recent' : null;

  /// Page size per tab. Recent is a short, paginated feed (10); the rest
  /// use the default page size.
  int _limitFor(FmTab tab) => tab == FmTab.recent ? 10 : 20;

  String _messageFor(Object e) => 'Failed to load folders';
}

final fileManagerRootNotifierProvider = AutoDisposeNotifierProvider<
  FileManagerRootNotifier,
  FileManagerRootState
>(FileManagerRootNotifier.new);
