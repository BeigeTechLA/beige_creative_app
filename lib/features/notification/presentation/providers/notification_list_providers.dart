import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/sources/notification_remote_source.dart';
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

@immutable
class NotificationListState {
  const NotificationListState({
    this.isLoading = false,
    this.notifications = const [],
    this.selectedTab = NotificationTab.unread,
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.errorMessage,
  });

  final bool isLoading;
  final List<NotificationItem> notifications;
  final NotificationTab selectedTab;
  final String searchQuery;
  final String selectedCategory;
  final String? errorMessage;

  /// Returns filtered list based on tab, search query, and category filter.
  List<NotificationItem> get filteredNotifications {
    return notifications.where((item) {
      // Tab filter
      if (selectedTab == NotificationTab.unread && item.isRead) {
        return false;
      }

      // Search query filter
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesTitle = item.title.toLowerCase().contains(query);
        final matchesMessage = item.message.toLowerCase().contains(query);
        final matchesSender = (item.senderName ?? '').toLowerCase().contains(query);
        if (!matchesTitle && !matchesMessage && !matchesSender) {
          return false;
        }
      }

      // Category filter
      if (selectedCategory != 'All' && selectedCategory.isNotEmpty) {
        final cat = selectedCategory.toLowerCase();
        final itemType = (item.type ?? '').toLowerCase();
        final itemCat = (item.category ?? '').toLowerCase();
        if (cat == 'unread') {
          if (item.isRead) return false;
        } else if (!itemType.contains(cat) && !itemCat.contains(cat)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationListState copyWith({
    bool? isLoading,
    List<NotificationItem>? notifications,
    NotificationTab? selectedTab,
    String? searchQuery,
    String? selectedCategory,
    String? errorMessage,
  }) {
    return NotificationListState(
      isLoading: isLoading ?? this.isLoading,
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
      final notifications = await repo.getNotifications();
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
    state = state.copyWith(selectedTab: tab);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void applyCategoryFilter(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void markAsRead(String id) {
    final updated = state.notifications.map((item) {
      if (item.id == id) {
        return item.copyWith(isRead: true);
      }
      return item;
    }).toList();

    state = state.copyWith(notifications: updated);
  }

  void markAllAsRead() {
    final updated = state.notifications.map((item) => item.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated);
  }

  static List<NotificationItem> _getMockNotifications() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return [
      NotificationItem(
        id: '1',
        title: 'Shoot Assigned',
        message: "Shoot Assigned: You've Been Assigned To The <Project Name> Shoot On May 24",
        senderName: 'Angela Kia',
        createdAt: DateTime(now.year, now.month, now.day, 9, 20),
        isRead: false,
        type: 'Projects',
        category: 'Projects',
        actionLabel: 'View Details',
      ),
      NotificationItem(
        id: '2',
        title: 'Shoot Reassigned',
        message: "Shoot Reassigned: You've Been Assigned To A New Shoot: <New Project Name>",
        senderName: 'Angela Kia',
        createdAt: DateTime(now.year, now.month, now.day, 9, 20),
        isRead: false,
        type: 'Projects',
        category: 'Projects',
      ),
      NotificationItem(
        id: '3',
        title: 'Shoot Schedule Updated',
        message: "Shoot Schedule Updated: Call Time Updated For <Project Name>. Review The Revised Schedule",
        senderName: 'Angela Kia',
        createdAt: DateTime(now.year, now.month, now.day, 9, 20),
        isRead: false,
        type: 'Projects',
        category: 'Projects',
      ),
      NotificationItem(
        id: '4',
        title: 'Shoot Cancelled',
        message: "Shoot Cancelled: <Project Name> Shoot Has Been Cancelled.",
        senderName: 'Angela Kia',
        createdAt: DateTime(now.year, now.month, now.day, 9, 20),
        isRead: false,
        type: 'Projects',
        category: 'Projects',
      ),
      NotificationItem(
        id: '5',
        title: 'Location Changed',
        message: "Location Changed: Shoot Location Changed For <Project Name>.",
        senderName: 'Connor Frazier',
        createdAt: DateTime(yesterday.year, yesterday.month, yesterday.day, 4, 20),
        isRead: false,
        type: 'Projects',
        category: 'Projects',
        actionLabel: 'Tap to view',
      ),
    ];
  }
}

final notificationListProvider =
    AutoDisposeNotifierProvider<NotificationListNotifier, NotificationListState>(
  NotificationListNotifier.new,
);
