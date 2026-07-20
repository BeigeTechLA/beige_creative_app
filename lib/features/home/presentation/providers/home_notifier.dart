import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/session/session_store.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../model_class/create_dashboard_details_model.dart';
import '../../../../model_class/creator_dashboard_model.dart';
import '../../../../model_class/crewstatus_model.dart';
import '../../../../model_class/dashboard_count_model.dart' as dashboard;
import '../../../../model_class/myprofile_model.dart' as profile;
import '../../../../model_class/upcoming_shoots_model.dart';
import '../../../meetings/domain/models/meeting.dart';
import '../../../meetings/domain/models/meetings_tab.dart';
import '../../../meetings/presentation/providers/meetings_repository_provider.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepositoryImpl(ref.read(dioClientProvider)),
);

final homeNotifierProvider =
    AutoDisposeNotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// Orchestrates fetching of the Home dashboard via the consolidated
/// `GET creator/dashboard` endpoint.
class HomeNotifier extends AutoDisposeNotifier<HomeState> {
  @override
  HomeState build() {
    Future.microtask(refresh);
    return HomeState(isLoading: true);
  }

  // ── Public API ──────────────────────────────────────────────────────────

  /// Fetches consolidated dashboard data in a single GET creator/dashboard call.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final repo = ref.read(homeRepositoryProvider);

    final filterValue = _filterValueForRange(state.selectedRange);
    final tab = state.selectedTab == 0 ? 'photo' : 'video';
    final day = state.focusedDay;

    final dashboardData = await _safeFetchCreatorDashboard(
      repo,
      filterValue,
      tab,
      day.month,
      day.year,
    );

    if (dashboardData == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    _applyDashboardData(dashboardData);
  }

  /// Re-fetch crew stats with a new time-range filter via consolidated endpoint.
  Future<void> changeStatsRange(String range) async {
    state = state.copyWith(selectedRange: range);
    final repo = ref.read(homeRepositoryProvider);
    final filter = _filterValueForRange(range);
    final tabStr = state.selectedTab == 0 ? 'photo' : 'video';
    final day = state.focusedDay;

    final dashboardData = await _safeFetchCreatorDashboard(
      repo,
      filter,
      tabStr,
      day.month,
      day.year,
    );

    if (dashboardData != null) {
      _applyDashboardData(dashboardData);
    }
  }

  /// Re-fetch shoot categories with a new tab (0=photo, 1=video) via consolidated endpoint.
  Future<void> changeShootCategoryTab(int tab) async {
    state = state.copyWith(selectedTab: tab);
    final repo = ref.read(homeRepositoryProvider);
    final filter = _filterValueForRange(state.selectedRange);
    final tabStr = tab == 0 ? 'photo' : 'video';
    final day = state.focusedDay;

    final dashboardData = await _safeFetchCreatorDashboard(
      repo,
      filter,
      tabStr,
      day.month,
      day.year,
    );

    if (dashboardData != null) {
      _applyDashboardData(dashboardData);
    }
  }

  /// Adjust focusedDay by [delta] months and re-fetch availability via consolidated endpoint.
  Future<void> changeMonth(int delta) async {
    final current = state.focusedDay;
    final next = DateTime(current.year, current.month + delta);
    state = state.copyWith(focusedDay: next);
    final repo = ref.read(homeRepositoryProvider);
    final filter = _filterValueForRange(state.selectedRange);
    final tabStr = state.selectedTab == 0 ? 'photo' : 'video';

    final dashboardData = await _safeFetchCreatorDashboard(
      repo,
      filter,
      tabStr,
      next.month,
      next.year,
    );

    if (dashboardData != null) {
      _applyDashboardData(dashboardData);
    }
  }

  /// Calendar page changed — update focusedDay and re-fetch availability via consolidated endpoint.
  Future<void> onPageChanged(DateTime day) async {
    state = state.copyWith(focusedDay: day);
    final repo = ref.read(homeRepositoryProvider);
    final filter = _filterValueForRange(state.selectedRange);
    final tabStr = state.selectedTab == 0 ? 'photo' : 'video';

    final dashboardData = await _safeFetchCreatorDashboard(
      repo,
      filter,
      tabStr,
      day.month,
      day.year,
    );

    if (dashboardData != null) {
      _applyDashboardData(dashboardData);
    }
  }

  /// Accept or decline a pending shoot request. Refreshes dashboard on success.
  Future<void> acceptDecline(int projectId, int crewAccept) async {
    final repo = ref.read(homeRepositoryProvider);
    try {
      await repo.acceptDeclineProject(projectId, crewAccept);
      await refresh();
    } catch (e, st) {
      AppLogger.e('Home acceptDecline failed', e, st);
      state = state.copyWith(errorMessage: 'Failed to respond to shoot');
    }
  }

  void selectDashboardCard(int index) {
    state = state.copyWith(selectedDashboardIndex: index);
  }

  void selectEvent(String event) {
    state = state.copyWith(selectedEvent: event);
  }

  void setUpcomingSearchQuery(String query) {
    state = state.copyWith(upcomingSearchQuery: query);
  }

  void setUpcomingFilters({
    String? date,
    String? status,
    String? category,
    String? type,
  }) {
    state = state.copyWith(
      upcomingSelectedDate: date,
      upcomingSelectedStatus: status,
      upcomingSelectedCategory: category,
      upcomingSelectedType: type,
    );
  }

  void clearUpcomingFilters() {
    state = state.copyWith(clearFilters: true);
  }

  /// Re-fetch profile only (used when returning from profile screen).
  Future<void> refreshAfterProfileReturn() async {
    final repo = ref.read(homeRepositoryProvider);
    final profileData = await _safeFetchProfile(repo);
    if (profileData != null) {
      state = state.copyWith(profileData: profileData);
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────

  void _applyDashboardData(CreatorDashboardPayload data) {
    final counts = data.dashboardCounts;
    final stats = data.crewStats;
    final categories = data.shootCategories;
    final availability = data.availability;
    final profileData = data.profileDetail;

    if (profileData != null) {
      _updateSessionUserSnapshot(profileData);
    }

    state = state.copyWith(
      // Dashboard counts
      completedShoots: counts?.completedShoots,
      upcomingShoots: counts?.upcomingShoots,
      pendingRequests: counts?.pendingRequests,
      completedShootsLabel: counts?.percentages?.completedShoots.label ?? "",
      upcomingShootsLabel: counts?.percentages?.upcomingShoots.label ?? "",
      pendingRequestsLabel: counts?.percentages?.pendingRequests.label ?? "",
      // Upcoming carousel
      upcomingShootsList: data.upcomingShoots,
      // Upcoming meetings carousel
      upcomingMeetingsList: data.upcomingMeetings,
      // Pending requests
      pendingRequestCards: data.pendingRequests,
      // Crew stats
      successfulShoots: stats?.completedShoots,
      pendingShootsCount: stats?.pendingShoots,
      rejectedShoots: stats?.rejectedShoots,
      shootRequests: stats?.shootRequests,
      photographyShoots: stats?.photographyShoots,
      videographyShoots: stats?.videographyShoots,
      // Shoot categories
      categoryPhotoTotal: categories?['photo']?['total'] as int?,
      categoryVideoTotal: categories?['video']?['total'] as int?,
      acceptPhotographyShoots: categories?['photo']?['acceptedShoots'] as int?,
      acceptVideographyShoots: categories?['video']?['acceptedShoots'] as int?,
      rejectedPhoto: categories?['photo']?['rejectedShoots'] as int?,
      rejectedVideo: categories?['video']?['rejectedShoots'] as int?,
      requestPhoto: categories?['photo']?['shootRequests'] as int?,
      requestVideo: categories?['video']?['shootRequests'] as int?,
      // Availability
      events: availability != null
          ? _prepareAvailabilityEvents(availability)
          : null,
      // Profile
      profileData: profileData,
      // Done
      isLoading: false,
    );
  }

  Future<void> _updateSessionUserSnapshot(profile.MyProfileData profileData) async {
    try {
      final session = ref.read(sessionStoreProvider);
      final currentUser = await session.readUser();
      final profileId = profileData.user.id != 0
          ? profileData.user.id.toString()
          : null;
      final sessionId =
          (currentUser?.id.isNotEmpty ?? false) && currentUser!.id != '0'
              ? currentUser.id
              : null;
      final resolvedId = profileId ?? sessionId;
      if (resolvedId == null) {
        AppLogger.w(
          'Skipping session user snapshot update: no valid user id '
          '(profile=${profileData.user.id}, session=${currentUser?.id})',
        );
      } else {
        final updatedUser = UserSnapshot(
          id: resolvedId,
          name: profileData.user.name,
          email: profileData.user.email,
          role:
              currentUser?.role ??
              (profileData.user.primaryRole.isNotEmpty
                  ? profileData.user.primaryRole
                  : null),
          userType:
              currentUser?.userType ?? profileData.user.userType.toString(),
          profileImageUrl: profileData.user.profileImageUrl.isNotEmpty
              ? profileData.user.profileImageUrl
              : currentUser?.profileImageUrl,
        );
        await session.writeUser(updatedUser);
      }
    } catch (e) {
      AppLogger.w('Failed to update session user snapshot: $e');
    }
  }

  String _filterValueForRange(String range) {
    switch (range) {
      case 'Week':
        return 'this_week';
      case 'Year':
        return 'this_year';
      default:
        return 'this_month';
    }
  }

  /// Parses raw availability map into the `{DateTime → label}` format
  /// consumed by `CommonCalendar`.
  Map<DateTime, String> _prepareAvailabilityEvents(
    Map<String, dynamic> availability,
  ) {
    final events = <DateTime, String>{};
    availability.forEach((dateString, value) {
      final date = DateTime.parse(dateString);
      final cleanDate = DateTime(date.year, date.month, date.day);
      final isAvailable = value['available'] == true;
      final isAssigned = value['projectAssigned'] == true;
      if (isAssigned) {
        events[cleanDate] = 'Shoot';
      } else if (isAvailable) {
        events[cleanDate] = 'Available';
      }
    });
    return events;
  }

  // ── Safe wrappers (partial-failure resilient) ───────────────────────────

  Future<CreatorDashboardPayload?> _safeFetchCreatorDashboard(
    HomeRepository repo,
    String statsFilter,
    String categoriesTab,
    int month,
    int year,
  ) async {
    try {
      return await repo.fetchCreatorDashboard(
        statsDateFilter: statsFilter,
        categoriesTab: categoriesTab,
        availabilityMonth: month,
        availabilityYear: year,
      );
    } catch (e, st) {
      AppLogger.e('Home fetchCreatorDashboard failed', e, st);
      return null;
    }
  }

  Future<profile.MyProfileData?> _safeFetchProfile(HomeRepository repo) async {
    try {
      final profileData = await repo.fetchProfile();
      await _updateSessionUserSnapshot(profileData);
      return profileData;
    } catch (e, st) {
      AppLogger.e('Home fetchProfile failed', e, st);
      return null;
    }
  }
}
