import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/sources/notification_remote_source.dart';
import '../../domain/models/notification_item.dart';
import '../../domain/repositories/notification_repository.dart';

/// Available tabs for filtering notifications.
enum NotificationTab { unread, all }

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
      final items = await repo.getNotifications();
      if (items.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          notifications: items,
        );
      } else {
        // Fallback Figma mock data when remote source returns empty list
        state = state.copyWith(
          isLoading: false,
          notifications: _getMockNotifications(),
        );
      }
    } catch (e, st) {
      AppLogger.e('Failed to fetch notifications, loading fallback mock data', e, st);
      state = state.copyWith(
        isLoading: false,
        notifications: _getMockNotifications(),
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

  Future<void> markAsRead(String id) async {
    final updated = state.notifications.map((item) {
      if (item.id == id) {
        return item.copyWith(isRead: true);
      }
      return item;
    }).toList();

    state = state.copyWith(notifications: updated);

    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAsRead(id);
    } catch (e, st) {
      AppLogger.e('Failed to mark notification as read on remote server', e, st);
    }
  }

  Future<void> markAllAsRead() async {
    final updated = state.notifications.map((item) => item.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated);

    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAllAsRead();
    } catch (e, st) {
      AppLogger.e('Failed to mark all notifications as read on remote server', e, st);
    }
  }

  static List<NotificationItem> _getMockNotifications() {
    final now = DateTime.now();
    return [
      NotificationItem(
        id: '1',
        title: 'Shoot Assigned',
        message: "Shoot Assigned: You've Been Assigned To The 'Project Sunset Shoot' As Pitch Lead.",
        senderName: 'Angela Rio',
        createdAt: now.subtract(const Duration(minutes: 20)),
        isRead: false,
        type: 'Projects',
        category: 'Projects',
        actionLabel: 'View Details',
      ),
      NotificationItem(
        id: '2',
        title: 'Shoot Update',
        message: "Shoot Update: Date And Time Has Been Changed For 'Project Sunset Shoot'. View The Project Details.",
        senderName: 'Angela Rio',
        createdAt: now.subtract(const Duration(hours: 1)),
        isRead: false,
        type: 'Projects',
        category: 'Projects',
        actionLabel: 'View Details',
      ),
      NotificationItem(
        id: '3',
        title: 'Shoot Rescheduled',
        message: "Shoot Rescheduled: Date And Time Updated For 'Project Sunset Shoot'. View The Updated Schedule.",
        senderName: 'Angela Rio',
        createdAt: now.subtract(const Duration(hours: 2, minutes: 15)),
        isRead: false,
        type: 'Status',
        category: 'Status',
      ),
      NotificationItem(
        id: '4',
        title: 'Shoot Cancelled',
        message: "Shoot Cancelled: 'Project Sunset Shoot' Has Been Cancelled.",
        senderName: 'Angela Rio',
        createdAt: now.subtract(const Duration(hours: 4)),
        isRead: false,
        type: 'Status',
        category: 'Status',
      ),
      NotificationItem(
        id: '5',
        title: 'Invoice Changed',
        message: "Invoice Changed: Sheet Notifications Received For Project Sunset.",
        senderName: 'Connor Frazier',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        isRead: true,
        type: 'Payments',
        category: 'Payments',
        actionLabel: 'Tap to view',
      ),
    ];
  }
}

final notificationListProvider =
    AutoDisposeNotifierProvider<NotificationListNotifier, NotificationListState>(
  NotificationListNotifier.new,
);
