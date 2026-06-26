import 'package:flutter/foundation.dart';

import '../../domain/models/fm_node.dart';
import 'file_manager_root_state.dart' show FmListStatus;

@immutable
class FolderContentsState {
  final List<FmNode> items;
  final String? cursor;
  final FmListStatus status;
  final String? errorMessage;
  final String searchQuery;

  const FolderContentsState({
    this.items = const [],
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
    String? cursor,
    bool clearCursor = false,
    FmListStatus? status,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
  }) {
    return FolderContentsState(
      items: items ?? this.items,
      cursor: clearCursor ? null : (cursor ?? this.cursor),
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
