import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/file_manager_repository.dart';
import 'file_manager_repository_provider.dart';
import 'file_manager_root_state.dart' show FmListStatus;
import 'folder_contents_state.dart';

class FolderContentsNotifier
    extends AutoDisposeFamilyNotifier<FolderContentsState, String> {
  late FileManagerRepository _repo;
  late String _folderId;

  @override
  FolderContentsState build(String folderId) {
    _repo = ref.watch(fileManagerRepositoryProvider);
    _folderId = folderId;
    Future.microtask(_loadFirst);
    return const FolderContentsState(status: FmListStatus.loading);
  }

  Future<void> _loadFirst() async {
    state = state.copyWith(
      status: FmListStatus.loading,
      items: const [],
      clearCursor: true,
      clearError: true,
    );
    try {
      final page = await _repo.listFolder(folderId: _folderId);
      state = state.copyWith(
        items: page.items,
        cursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        status: FmListStatus.ready,
      );
    } catch (e) {
      state = state.copyWith(
        status: FmListStatus.error,
        errorMessage: 'Failed to load folder',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.status == FmListStatus.loadingMore || !state.hasMore) return;
    state = state.copyWith(status: FmListStatus.loadingMore);
    try {
      final page = await _repo.listFolder(
        folderId: _folderId,
        cursor: state.cursor,
      );
      state = state.copyWith(
        items: [...state.items, ...page.items],
        cursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        status: FmListStatus.ready,
      );
    } catch (e) {
      state = state.copyWith(
        status: FmListStatus.ready,
        errorMessage: 'Failed to load more',
      );
    }
  }

  Future<void> refresh() => _loadFirst();

  void setSearchQuery(String query) {
    if (query == state.searchQuery) return;
    state = state.copyWith(searchQuery: query);
  }
}

final folderContentsNotifierProvider = AutoDisposeNotifierProvider
    .family<FolderContentsNotifier, FolderContentsState, String>(
      FolderContentsNotifier.new,
    );
