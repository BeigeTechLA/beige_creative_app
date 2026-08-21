import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/fm_folder_key.dart';
import '../../domain/repositories/folder_browse_repository.dart';
import 'file_manager_root_state.dart' show FmListStatus;
import 'folder_browse_repository_provider.dart';
import 'folder_contents_state.dart';

/// Folder listing notifier keyed by [FmFolderKey]. Backed by
/// [FolderBrowseRepository]. Current API returns a single unpaginated
/// page per folder — [loadMore] is a no-op until the endpoint adds
/// paging, and [refresh] is the only way to re-fetch.
class FolderContentsNotifier
    extends AutoDisposeFamilyNotifier<FolderContentsState, FmFolderKey> {
  late FolderBrowseRepository _repo;
  late FmFolderKey _key;

  @override
  FolderContentsState build(FmFolderKey key) {
    _repo = ref.watch(folderBrowseRepositoryProvider);
    _key = key;
    Future.microtask(_loadFirst);
    return const FolderContentsState(status: FmListStatus.loading);
  }

  Future<void> _loadFirst() async {
    state = state.copyWith(
      status: FmListStatus.loading,
      items: const [],
      clearCursor: true,
      clearWorkspace: true,
      clearError: true,
    );
    try {
      final contents = await _repo.open(_key);
      state = state.copyWith(
        items: contents.items,
        basePath: contents.basePath,
        workspace: contents.workspace,
        clearWorkspace: contents.workspace == null,
        status: FmListStatus.ready,
      );
    } catch (e) {
      state = state.copyWith(
        status: FmListStatus.error,
        errorMessage: 'Failed to load folder',
      );
    }
  }

  /// Pagination not implemented server-side — no-op. Kept so consumers
  /// that call `loadMore()` from an infinite scroll trigger don't break.
  Future<void> loadMore() async {}

  Future<void> refresh() => _loadFirst();

  void setSearchQuery(String query) {
    if (query == state.searchQuery) return;
    state = state.copyWith(searchQuery: query);
  }
}

final folderContentsNotifierProvider = AutoDisposeNotifierProvider
    .family<FolderContentsNotifier, FolderContentsState, FmFolderKey>(
      FolderContentsNotifier.new,
    );
