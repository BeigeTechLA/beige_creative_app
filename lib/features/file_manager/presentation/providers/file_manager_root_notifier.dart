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
/// - `all` / `recent` / `linked` → `list()` on the workspaces endpoint
///   (paginated). `recent` sorts client-side by `openedAt` desc.
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

      final page = await _repo.list();
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
      final page = await _repo.list(cursor: state.cursor);
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
        final sorted = [...items]
          ..sort((a, b) => (b.openedAt ?? DateTime(0))
              .compareTo(a.openedAt ?? DateTime(0)));
        return sorted;
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

  String _messageFor(Object e) => 'Failed to load folders';
}

final fileManagerRootNotifierProvider = AutoDisposeNotifierProvider<
  FileManagerRootNotifier,
  FileManagerRootState
>(FileManagerRootNotifier.new);
