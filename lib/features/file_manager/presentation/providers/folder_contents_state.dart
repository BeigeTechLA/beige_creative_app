import 'package:flutter/foundation.dart';

import '../../domain/models/fm_node.dart';
import 'file_manager_root_state.dart' show FmListStatus;

@immutable
class FolderContentsState {
  final List<FmNode> items;

  /// Present after the first successful load. Used by mutations
  /// (`FmPath` composition, delete, upload) that need the folder's
  /// absolute object-store path.
  final String basePath;

  /// Workspace-root folder returned alongside the listing — surfaces
  /// project badge / breadcrumb metadata to the screen.
  final FmFolder? workspace;

  /// Kept for API compatibility with the old cursor-paginated shape.
  /// The current `/files` endpoint returns a single unpaginated page,
  /// so this stays null. Re-enable when server adds paging.
  final String? cursor;
  final FmListStatus status;
  final String? errorMessage;
  final String searchQuery;

  const FolderContentsState({
    this.items = const [],
    this.basePath = '',
    this.workspace,
    this.cursor,
    this.status = FmListStatus.idle,
    this.errorMessage,
    this.searchQuery = '',
  });

  bool get hasMore => cursor != null;

  List<FmNode> get visibleItems {
    if (searchQuery.trim().isEmpty) return items;
    final q = searchQuery.trim().toLowerCase();
    return items.where((n) => n.name.toLowerCase().contains(q)).toList();
  }

  FolderContentsState copyWith({
    List<FmNode>? items,
    String? basePath,
    FmFolder? workspace,
    bool clearWorkspace = false,
    String? cursor,
    bool clearCursor = false,
    FmListStatus? status,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
  }) {
    return FolderContentsState(
      items: items ?? this.items,
      basePath: basePath ?? this.basePath,
      workspace: clearWorkspace ? null : (workspace ?? this.workspace),
      cursor: clearCursor ? null : (cursor ?? this.cursor),
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
