import 'package:flutter/foundation.dart';

import '../../../../model_class/create_dashboard_details_model.dart';
import '../../../../model_class/myprofile_model.dart' as profile;
import '../../../../model_class/upcoming_shoots_model.dart';
import '../../../meetings/domain/models/meeting.dart';

/// Combined immutable state for the Home dashboard.
///
/// Each section can show partial data if one fetcher fails — the notifier
/// populates fields independently via `_safe*` wrappers around `Future.wait`.
@immutable
class HomeState {
  // ── Dashboard counts ──
  final int completedShoots;
  final int upcomingShoots;
  final int pendingRequests;
  final String completedShootsLabel;
  final String upcomingShootsLabel;
  final String pendingRequestsLabel;

  // ── Upcoming shoots carousel ──
  final List<UpcomingShootDatum> upcomingShootsList;

  // ── Upcoming meetings carousel ──
  final List<Meeting> upcomingMeetingsList;

  // ── Pending requests (dashboard-details filtered to 'pending') ──
  final List<PendingRequestCard> pendingRequestCards;

  // ── Crew stats (shoot status panel) ──
  final int successfulShoots;
  final int pendingShootsCount;
  final int rejectedShoots;
  final int shootRequests;
  final int photographyShoots;
  final int videographyShoots;

  // ── Shoot categories panel ──
  final int categoryPhotoTotal;
  final int categoryVideoTotal;
  final int acceptPhotographyShoots;
  final int acceptVideographyShoots;
  final int rejectedPhoto;
  final int rejectedVideo;
  final int requestPhoto;
  final int requestVideo;

  // ── Availability calendar ──
  final Map<DateTime, String> events;

  // ── Profile ──
  final profile.MyProfileData? profileData;

  // ── Lifecycle ──
  final bool isLoading;
  final String? errorMessage;

  // ── UI-local state driven by notifier ──
  final String selectedRange;
  final int selectedTab;
  final int selectedDashboardIndex;
  final String selectedEvent;
  final DateTime focusedDay;

  // ── Search & Filter for Upcoming Shoots ──
  final String upcomingSearchQuery;
  final String? upcomingSelectedDate;
  final String? upcomingSelectedStatus;
  final String? upcomingSelectedCategory;
  final String? upcomingSelectedType;

  HomeState({
    this.completedShoots = 0,
    this.upcomingShoots = 0,
    this.pendingRequests = 0,
    this.completedShootsLabel = "",
    this.upcomingShootsLabel = "",
    this.pendingRequestsLabel = "",
    this.upcomingShootsList = const [],
    this.upcomingMeetingsList = const [],
    this.pendingRequestCards = const [],
    this.successfulShoots = 0,
    this.pendingShootsCount = 0,
    this.rejectedShoots = 0,
    this.shootRequests = 0,
    this.photographyShoots = 0,
    this.videographyShoots = 0,
    this.categoryPhotoTotal = 0,
    this.categoryVideoTotal = 0,
    this.acceptPhotographyShoots = 0,
    this.acceptVideographyShoots = 0,
    this.rejectedPhoto = 0,
    this.rejectedVideo = 0,
    this.requestPhoto = 0,
    this.requestVideo = 0,
    this.events = const {},
    this.profileData,
    this.isLoading = false,
    this.errorMessage,
    this.selectedRange = 'Month',
    this.selectedTab = 0,
    this.selectedDashboardIndex = 0,
    this.selectedEvent = 'All Events',
    DateTime? focusedDay,
    this.upcomingSearchQuery = "",
    this.upcomingSelectedDate,
    this.upcomingSelectedStatus,
    this.upcomingSelectedCategory,
    this.upcomingSelectedType,
  }) : focusedDay = focusedDay ?? DateTime.now();

  List<UpcomingShootDatum> get filteredUpcomingShootsList {
    if (upcomingSearchQuery.isEmpty &&
        upcomingSelectedDate == null &&
        upcomingSelectedStatus == null &&
        upcomingSelectedCategory == null &&
        upcomingSelectedType == null) {
      return upcomingShootsList;
    }

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDate = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final endOfWeekDate = startOfWeekDate.add(const Duration(days: 7));

    return upcomingShootsList.where((shoot) {
      // 1. Search Query
      if (upcomingSearchQuery.isNotEmpty) {
        final query = upcomingSearchQuery.toLowerCase();
        final matchesQuery =
            shoot.projectName.toLowerCase().contains(query) ||
            shoot.eventLocation.toLowerCase().contains(query) ||
            shoot.shootType.toLowerCase().contains(query);
        if (!matchesQuery) return false;
      }

      // 2. Date Filter
      if (upcomingSelectedDate != null && upcomingSelectedDate!.isNotEmpty) {
        final dateFilter = upcomingSelectedDate!;
        if (dateFilter == "Today") {
          if (shoot.eventDate.isBefore(todayStart) ||
              shoot.eventDate.isAfter(todayEnd)) {
            return false;
          }
        } else if (dateFilter == "This Week") {
          if (shoot.eventDate.isBefore(startOfWeekDate) ||
              shoot.eventDate.isAfter(endOfWeekDate)) {
            return false;
          }
        } else if (dateFilter == "This Month") {
          if (shoot.eventDate.year != now.year ||
              shoot.eventDate.month != now.month) {
            return false;
          }
        } else if (dateFilter == "Marketing Analytics") {
          final isMarketing =
              shoot.projectName.toLowerCase().contains("marketing") ||
              shoot.projectName.toLowerCase().contains("analytics") ||
              shoot.shootType.toLowerCase().contains("marketing") ||
              shoot.shootType.toLowerCase().contains("analytics");
          if (!isMarketing) return false;
        }
      }

      // 3. Status Filter
      if (upcomingSelectedStatus != null &&
          upcomingSelectedStatus!.isNotEmpty) {
        final statusFilter = upcomingSelectedStatus!.toLowerCase();
        if (statusFilter == "upcoming") {
          if (shoot.isCompleted) return false;
        } else if (statusFilter == "completed") {
          if (!shoot.isCompleted) return false;
        } else if (statusFilter == "active") {
          if (shoot.isCompleted) return false;
        } else if (statusFilter == "cancelled") {
          return false;
        }
      }

      // 4. Category Filter
      if (upcomingSelectedCategory != null &&
          upcomingSelectedCategory!.isNotEmpty) {
        final categoryFilter = upcomingSelectedCategory!.toLowerCase();
        if (!shoot.shootType.toLowerCase().contains(categoryFilter) &&
            !shoot.projectName.toLowerCase().contains(categoryFilter)) {
          return false;
        }
      }

      // 5. Type Filter
      if (upcomingSelectedType != null && upcomingSelectedType!.isNotEmpty) {
        final typeFilter = upcomingSelectedType!.toLowerCase();
        if (typeFilter != "all") {
          final isShoot = typeFilter == "shoots" || typeFilter == "shoot";
          final isRental = typeFilter == "rental" || typeFilter == "rentals";
          final shootTypeLower = shoot.shootType.toLowerCase();
          if (isShoot &&
              !(shootTypeLower.contains("shoot") ||
                  shootTypeLower.contains("photo") ||
                  shootTypeLower.contains("video"))) {
            return false;
          }
          if (isRental && !shootTypeLower.contains("rental")) {
            return false;
          }
        }
      }

      return true;
    }).toList();
  }

  HomeState copyWith({
    int? completedShoots,
    int? upcomingShoots,
    int? pendingRequests,
    String? completedShootsLabel,
    String? upcomingShootsLabel,
    String? pendingRequestsLabel,
    List<UpcomingShootDatum>? upcomingShootsList,
    List<Meeting>? upcomingMeetingsList,
    List<PendingRequestCard>? pendingRequestCards,
    int? successfulShoots,
    int? pendingShootsCount,
    int? rejectedShoots,
    int? shootRequests,
    int? photographyShoots,
    int? videographyShoots,
    int? categoryPhotoTotal,
    int? categoryVideoTotal,
    int? acceptPhotographyShoots,
    int? acceptVideographyShoots,
    int? rejectedPhoto,
    int? rejectedVideo,
    int? requestPhoto,
    int? requestVideo,
    Map<DateTime, String>? events,
    profile.MyProfileData? profileData,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? selectedRange,
    int? selectedTab,
    int? selectedDashboardIndex,
    String? selectedEvent,
    DateTime? focusedDay,
    String? upcomingSearchQuery,
    String? upcomingSelectedDate,
    String? upcomingSelectedStatus,
    String? upcomingSelectedCategory,
    String? upcomingSelectedType,
    bool clearFilters = false,
  }) {
    return HomeState(
      completedShoots: completedShoots ?? this.completedShoots,
      upcomingShoots: upcomingShoots ?? this.upcomingShoots,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      completedShootsLabel: completedShootsLabel ?? this.completedShootsLabel,
      upcomingShootsLabel: upcomingShootsLabel ?? this.upcomingShootsLabel,
      pendingRequestsLabel: pendingRequestsLabel ?? this.pendingRequestsLabel,
      upcomingShootsList: upcomingShootsList ?? this.upcomingShootsList,
      upcomingMeetingsList: upcomingMeetingsList ?? this.upcomingMeetingsList,
      pendingRequestCards: pendingRequestCards ?? this.pendingRequestCards,
      successfulShoots: successfulShoots ?? this.successfulShoots,
      pendingShootsCount: pendingShootsCount ?? this.pendingShootsCount,
      rejectedShoots: rejectedShoots ?? this.rejectedShoots,
      shootRequests: shootRequests ?? this.shootRequests,
      photographyShoots: photographyShoots ?? this.photographyShoots,
      videographyShoots: videographyShoots ?? this.videographyShoots,
      categoryPhotoTotal: categoryPhotoTotal ?? this.categoryPhotoTotal,
      categoryVideoTotal: categoryVideoTotal ?? this.categoryVideoTotal,
      acceptPhotographyShoots:
          acceptPhotographyShoots ?? this.acceptPhotographyShoots,
      acceptVideographyShoots:
          acceptVideographyShoots ?? this.acceptVideographyShoots,
      rejectedPhoto: rejectedPhoto ?? this.rejectedPhoto,
      rejectedVideo: rejectedVideo ?? this.rejectedVideo,
      requestPhoto: requestPhoto ?? this.requestPhoto,
      requestVideo: requestVideo ?? this.requestVideo,
      events: events ?? this.events,
      profileData: profileData ?? this.profileData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedRange: selectedRange ?? this.selectedRange,
      selectedTab: selectedTab ?? this.selectedTab,
      selectedDashboardIndex:
          selectedDashboardIndex ?? this.selectedDashboardIndex,
      selectedEvent: selectedEvent ?? this.selectedEvent,
      focusedDay: focusedDay ?? this.focusedDay,
      upcomingSearchQuery: upcomingSearchQuery ?? this.upcomingSearchQuery,
      upcomingSelectedDate: clearFilters
          ? null
          : (upcomingSelectedDate ?? this.upcomingSelectedDate),
      upcomingSelectedStatus: clearFilters
          ? null
          : (upcomingSelectedStatus ?? this.upcomingSelectedStatus),
      upcomingSelectedCategory: clearFilters
          ? null
          : (upcomingSelectedCategory ?? this.upcomingSelectedCategory),
      upcomingSelectedType: clearFilters
          ? null
          : (upcomingSelectedType ?? this.upcomingSelectedType),
    );
  }
}
