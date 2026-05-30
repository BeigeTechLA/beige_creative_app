import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/file_manager_stub_repository.dart';
import '../../domain/entities/file_folder.dart';
import '../../domain/entities/file_item.dart';
import '../../domain/repositories/file_manager_repository.dart';

/// Repository injection point. Swap the override in tests or wire a real
/// Dio-backed impl here once backend endpoints land.
final fileManagerRepositoryProvider = Provider<FileManagerRepository>(
  (_) => const FileManagerStubRepository(),
);

// ─────────────────────────────────────────────────────────────────────────────
// File Manager root screen — folders tab + view mode + search query.
// ─────────────────────────────────────────────────────────────────────────────

enum FileManagerView { card, list }

@immutable
class FileManagerState {
  final List<FileFolder> allFolders;
  final List<FileFolder> recentFolders;
  final FileManagerView view;
  final String query;
  final bool isLoading;

  const FileManagerState({
    this.allFolders = const [],
    this.recentFolders = const [],
    this.view = FileManagerView.card,
    this.query = '',
    this.isLoading = true,
  });

  FileManagerState copyWith({
    List<FileFolder>? allFolders,
    List<FileFolder>? recentFolders,
    FileManagerView? view,
    String? query,
    bool? isLoading,
  }) {
    return FileManagerState(
      allFolders: allFolders ?? this.allFolders,
      recentFolders: recentFolders ?? this.recentFolders,
      view: view ?? this.view,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<FileFolder> _apply(List<FileFolder> source) {
    if (query.isEmpty) return source;
    final q = query.toLowerCase();
    return source
        .where((f) =>
            f.name.toLowerCase().contains(q) ||
            f.category.toLowerCase().contains(q))
        .toList(growable: false);
  }

  List<FileFolder> get filteredAll => _apply(allFolders);
  List<FileFolder> get filteredRecent => _apply(recentFolders);
}

class FileManagerNotifier extends AutoDisposeNotifier<FileManagerState> {
  @override
  FileManagerState build() {
    Future.microtask(_load);
    return const FileManagerState();
  }

  Future<void> _load() async {
    final repo = ref.read(fileManagerRepositoryProvider);
    final all = await repo.fetchAllFolders();
    final recent = await repo.fetchRecentFolders();
    state = state.copyWith(
      allFolders: all,
      recentFolders: recent,
      isLoading: false,
    );
  }

  void toggleView() {
    state = state.copyWith(
      view: state.view == FileManagerView.card
          ? FileManagerView.list
          : FileManagerView.card,
    );
  }

  void setQuery(String value) => state = state.copyWith(query: value);
}

final fileManagerNotifierProvider =
    AutoDisposeNotifierProvider<FileManagerNotifier, FileManagerState>(
  FileManagerNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// Pre-production — files list + search.
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class PreProductionState {
  final List<FileItem> files;
  final String query;
  final bool isLoading;

  const PreProductionState({
    this.files = const [],
    this.query = '',
    this.isLoading = true,
  });

  PreProductionState copyWith({
    List<FileItem>? files,
    String? query,
    bool? isLoading,
  }) {
    return PreProductionState(
      files: files ?? this.files,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<FileItem> get filtered {
    if (query.isEmpty) return files;
    final q = query.toLowerCase();
    return files
        .where((f) => f.name.toLowerCase().contains(q))
        .toList(growable: false);
  }
}

class PreProductionNotifier
    extends AutoDisposeFamilyNotifier<PreProductionState, String> {
  @override
  PreProductionState build(String folderId) {
    Future.microtask(() => _load(folderId));
    return const PreProductionState();
  }

  Future<void> _load(String folderId) async {
    final repo = ref.read(fileManagerRepositoryProvider);
    final files = await repo.fetchPreProductionFiles(folderId);
    state = state.copyWith(files: files, isLoading: false);
  }

  void setQuery(String value) => state = state.copyWith(query: value);
}

final preProductionNotifierProvider = AutoDisposeNotifierProviderFamily<
    PreProductionNotifier, PreProductionState, String>(
  PreProductionNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// Post-production — folders list + search.
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class PostProductionState {
  final List<FileFolder> folders;
  final String query;
  final bool isLoading;

  const PostProductionState({
    this.folders = const [],
    this.query = '',
    this.isLoading = true,
  });

  PostProductionState copyWith({
    List<FileFolder>? folders,
    String? query,
    bool? isLoading,
  }) {
    return PostProductionState(
      folders: folders ?? this.folders,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<FileFolder> get filtered {
    if (query.isEmpty) return folders;
    final q = query.toLowerCase();
    return folders
        .where((f) => f.name.toLowerCase().contains(q))
        .toList(growable: false);
  }
}

class PostProductionNotifier
    extends AutoDisposeFamilyNotifier<PostProductionState, String> {
  @override
  PostProductionState build(String folderId) {
    Future.microtask(() => _load(folderId));
    return const PostProductionState();
  }

  Future<void> _load(String folderId) async {
    final repo = ref.read(fileManagerRepositoryProvider);
    final folders = await repo.fetchPostProductionFolders(folderId);
    state = state.copyWith(folders: folders, isLoading: false);
  }

  void setQuery(String value) => state = state.copyWith(query: value);
}

final postProductionNotifierProvider = AutoDisposeNotifierProviderFamily<
    PostProductionNotifier, PostProductionState, String>(
  PostProductionNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// View details — single folder lookup.
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class ViewDetailsState {
  final FileFolder? folder;
  final bool isLoading;

  const ViewDetailsState({this.folder, this.isLoading = true});

  ViewDetailsState copyWith({FileFolder? folder, bool? isLoading}) {
    return ViewDetailsState(
      folder: folder ?? this.folder,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ViewDetailsNotifier
    extends AutoDisposeFamilyNotifier<ViewDetailsState, String> {
  @override
  ViewDetailsState build(String folderId) {
    Future.microtask(() => _load(folderId));
    return const ViewDetailsState();
  }

  Future<void> _load(String folderId) async {
    final repo = ref.read(fileManagerRepositoryProvider);
    final folder = await repo.fetchFolder(folderId);
    state = state.copyWith(folder: folder, isLoading: false);
  }
}

final viewDetailsNotifierProvider = AutoDisposeNotifierProviderFamily<
    ViewDetailsNotifier, ViewDetailsState, String>(
  ViewDetailsNotifier.new,
);
