import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/fm_tab.dart';
import '../../domain/repositories/file_manager_repository.dart';
import 'file_manager_repository_provider.dart';
import 'file_manager_root_state.dart';

class FileManagerRootNotifier extends AutoDisposeNotifier<FileManagerRootState> {
  late FileManagerRepository _repo;

  @override
  FileManagerRootState build() {
    _repo = ref.watch(fileManagerRepositoryProvider);
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
      final page = await _repo.listRoot(tab: state.tab);
      state = state.copyWith(
        items: page.items,
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
    state = state.copyWith(status: FmListStatus.loadingMore);
    try {
      final page = await _repo.listRoot(tab: state.tab, cursor: state.cursor);
      state = state.copyWith(
        items: [...state.items, ...page.items],
        cursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        status: FmListStatus.ready,
      );
    } catch (e) {
      // loadMore failure surfaces as a snackbar in FM5; for now revert to
      // ready so the existing list stays visible.
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

  String _messageFor(Object e) => 'Failed to load folders';
}

final fileManagerRootNotifierProvider = AutoDisposeNotifierProvider<
  FileManagerRootNotifier,
  FileManagerRootState
>(FileManagerRootNotifier.new);
