import 'package:flutter/foundation.dart';

import '../../domain/models/fm_node.dart';
import '../../domain/models/fm_tab.dart';

enum FmListStatus { idle, loading, loadingMore, ready, error }

@immutable
class FileManagerRootState {
  final FmTab tab;
  final List<FmFolder> items;
  final String? cursor;
  final FmListStatus status;
  final String? errorMessage;
  final String searchQuery;

  const FileManagerRootState({
    this.tab = FmTab.all,
    this.items = const [],
    this.cursor,
    this.status = FmListStatus.idle,
    this.errorMessage,
    this.searchQuery = '',
  });

  bool get hasMore => cursor != null;

  /// Client-side filter — backend may add `q` later (plan §7).
  List<FmFolder> get visibleItems {
    if (searchQuery.trim().isEmpty) return items;
    final q = searchQuery.trim().toLowerCase();
    return items.where((f) => f.name.toLowerCase().contains(q)).toList();
  }

  FileManagerRootState copyWith({
    FmTab? tab,
    List<FmFolder>? items,
    String? cursor,
    bool clearCursor = false,
    FmListStatus? status,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
  }) {
    return FileManagerRootState(
      tab: tab ?? this.tab,
      items: items ?? this.items,
      cursor: clearCursor ? null : (cursor ?? this.cursor),
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
