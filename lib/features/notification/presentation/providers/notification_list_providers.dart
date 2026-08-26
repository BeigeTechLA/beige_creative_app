import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/sources/notification_remote_source.dart';
import '../../domain/models/notification_counts.dart';
import '../../domain/models/notification_item.dart';
import '../../domain/repositories/notification_repository.dart';

/// Available tabs for filtering notifications.
enum NotificationTab { unread, Read }

final notificationRemoteSourceProvider = Provider<NotificationRemoteSource>(
  (ref) => NotificationRemoteSource(ref.read(dioClientProvider)),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(ref.read(notificationRemoteSourceProvider)),
);

final notificationCountProvider = FutureProvider.autoDispose<NotificationCounts>((ref) async {
  final repo = ref.read(notificationRepositoryProvider);
  return repo.getNotificationCounts();
});

@immutable
class NotificationListState {
  const NotificationListState({
    this.isLoading = false,
    this.isMarkingAllAsRead = false,
    this.notifications = const [],
    this.selectedTab = NotificationTab.unread,
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.errorMessage,
  });

  final bool isLoading;
  final bool isMarkingAllAsRead;
  final List<NotificationItem> notifications;
  final NotificationTab selectedTab;
  final String searchQuery;
  final String selectedCategory;
  final String? errorMessage;

  /// Returns list since backend is handling filtering,
  /// but we filter locally for unread tab to instantly remove marked-as-read items.
  List<NotificationItem> get filteredNotifications {
    if (selectedTab == NotificationTab.unread) {
      return notifications.where((n) => !n.isRead).toList();
    }
    return notifications;
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationListState copyWith({
    bool? isLoading,
    bool? isMarkingAllAsRead,
    List<NotificationItem>? notifications,
    NotificationTab? selectedTab,
    String? searchQuery,
    String? selectedCategory,
    String? errorMessage,
  }) {
    return NotificationListState(
      isLoading: isLoading ?? this.isLoading,
      isMarkingAllAsRead: isMarkingAllAsRead ?? this.isMarkingAllAsRead,
      notifications: notifications ?? this.notifications,
      selectedTab: selectedTab ?? this.selectedTab,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: errorMessage,
    );
  }
}

class NotificationListNotifier extends AutoDisposeNotifier<NotificationListState> {
  @override
  NotificationListState build() {
    // Initial fetch
    Future.microtask(fetchNotifications);
    return const NotificationListState(isLoading: true);
  }

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(notificationRepositoryProvider);
      
      String status = state.selectedTab == NotificationTab.unread ? 'unread' : 'read';
      // If they are on the Read tab, they actually want all notifications or just read? The API allows 'read' and 'all'.
      // If we look at the user request: "GET /app-notifications?status=read&page=1&limit=20".
      
      String? category = state.selectedCategory == 'All' ? null : state.selectedCategory.toLowerCase();
      String? search = state.searchQuery.isNotEmpty ? state.searchQuery : null;

      // The user request shows status=all when selecting All / View All
      // Or search: GET /app-notifications?status=all&search=test
      // So if search or category is active, or maybe we just pass what they want.
      
      if (search != null || category != null) {
        status = 'all'; // Usually search/filters run across all notifications
      }

      final notifications = await repo.getNotifications(
        status: status,
        search: search,
        category: category,
      );
      state = state.copyWith(
        isLoading: false,
        notifications: notifications,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void selectTab(NotificationTab tab) {
    state = state.copyWith(selectedTab: tab, selectedCategory: 'All', searchQuery: '');
    fetchNotifications();
  }

  Timer? _searchDebouncer;

  void setSearchQuery(String query) {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query);
    
    _searchDebouncer?.cancel();
    _searchDebouncer = Timer(const Duration(milliseconds: 500), () {
      fetchNotifications();
    });
  }

  void applyCategoryFilter(String category) {
    state = state.copyWith(selectedCategory: category);
    fetchNotifications();
  }

  Future<void> markAsRead(String id) async {
    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAsRead(id);
      
      final updated = state.notifications.map((item) {
        if (item.id == id) {
          return item.copyWith(isRead: true);
        }
        return item;
      }).toList();

      state = state.copyWith(notifications: updated);
      ref.invalidate(notificationCountProvider);
    } catch (e) {
      // Keep existing state on error or handle gracefully
    }
  }

  Future<void> markAsUnread(String id) async {
    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAsUnread(id);
      
      final updated = state.notifications.map((item) {
        if (item.id == id) {
          return item.copyWith(isRead: false);
        }
        return item;
      }).toList();

      state = state.copyWith(notifications: updated);
      ref.invalidate(notificationCountProvider);
    } catch (e) {
      // Keep existing state on error
    }
  }

  Future<void> markAllAsRead() async {
    try {
      state = state.copyWith(isMarkingAllAsRead: true);
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAllAsRead();
      
      final updated = state.notifications.map((item) => item.copyWith(isRead: true)).toList();
      state = state.copyWith(notifications: updated, isMarkingAllAsRead: false);
      ref.invalidate(notificationCountProvider);
    } catch (e) {
      state = state.copyWith(isMarkingAllAsRead: false);
      // Keep existing state on error
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.deleteNotification(id);
      
      final updated = state.notifications.where((item) => item.id != id).toList();
      state = state.copyWith(notifications: updated);
      ref.invalidate(notificationCountProvider);
    } catch (e) {
      // Keep existing state on error
    }
  }

}

final notificationListProvider =
    AutoDisposeNotifierProvider<NotificationListNotifier, NotificationListState>(
  NotificationListNotifier.new,
);
