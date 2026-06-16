import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/session/session_store.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../model_class/create_dashboard_details_model.dart';
import '../../../../model_class/crewstatus_model.dart';
import '../../../../model_class/dashboard_count_model.dart' as dashboard;
import '../../../../model_class/myprofile_model.dart' as profile;
import '../../../../model_class/upcoming_shoots_model.dart';
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

/// Orchestrates the 7 parallel fetchers that populate the Home dashboard.
///
/// `build()` kicks off a coordinated `Future.wait` via [refresh]. Each
/// sub-fetch is wrapped in a `_safe*` helper so partial failures don't block
/// the whole dashboard — individual sections simply retain their default
/// values when their endpoint fails.
class HomeNotifier extends AutoDisposeNotifier<HomeState> {
  @override
  HomeState build() {
    Future.microtask(refresh);
    return HomeState(isLoading: true);
  }

  // ── Public API ──────────────────────────────────────────────────────────

  /// Coordinated refresh of all 7 data domains. Each fetch is individually
  /// guarded so partial failures don't block the rest.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final repo = ref.read(homeRepositoryProvider);

    final filterValue = _filterValueForRange(state.selectedRange);
    final tab = state.selectedTab == 0 ? 'photo' : 'video';
    final day = state.focusedDay;

    final results = await Future.wait([
      _safeFetchDashboardCount(repo), // 0
      _safeFetchUpcomingShoots(repo), // 1
      _safeFetchPendingRequests(repo), // 2
      _safeFetchCrewStats(repo, filterValue), // 3
      _safeFetchShootCategories(repo, tab), // 4
      _safeFetchAvailability(repo, day.month, day.year), // 5
      _safeFetchProfile(repo), // 6
    ]);

    final counts = results[0] as dashboard.DashboardCountData?;
    final upcoming = results[1] as List<UpcomingShootDatum>?;
    final pending = results[2] as List<PendingRequestCard>?;
    final stats = results[3] as CrewStatsData?;
    final categories = results[4] as Map<String, dynamic>?;
    final availability = results[5] as Map<String, dynamic>?;
    final profileData = results[6] as profile.MyProfileData?;

    state = state.copyWith(
      // Dashboard counts
      completedShoots: counts?.completedShoots,
      upcomingShoots: counts?.upcomingShoots,
      pendingRequests: counts?.pendingRequests,
      // Upcoming carousel
      upcomingShootsList: upcoming,
      // Pending requests
      pendingRequestCards: pending,
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
      acceptPhotographyShoots:
          categories?['photo']?['acceptedShoots'] as int?,
      acceptVideographyShoots:
          categories?['video']?['acceptedShoots'] as int?,
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

  /// Re-fetch crew stats with a new time-range filter.
  Future<void> changeStatsRange(String range) async {
    state = state.copyWith(selectedRange: range);
    final repo = ref.read(homeRepositoryProvider);
    final filter = _filterValueForRange(range);
    final stats = await _safeFetchCrewStats(repo, filter);
    if (stats != null) {
      state = state.copyWith(
        successfulShoots: stats.completedShoots,
        pendingShootsCount: stats.pendingShoots,
        rejectedShoots: stats.rejectedShoots,
        shootRequests: stats.shootRequests,
        photographyShoots: stats.photographyShoots,
        videographyShoots: stats.videographyShoots,
      );
    }
  }

  /// Re-fetch shoot categories with a new tab (0=photo, 1=video).
  Future<void> changeShootCategoryTab(int tab) async {
    state = state.copyWith(selectedTab: tab);
    final repo = ref.read(homeRepositoryProvider);
    final tabStr = tab == 0 ? 'photo' : 'video';
    final categories = await _safeFetchShootCategories(repo, tabStr);
    if (categories != null) {
      state = state.copyWith(
        categoryPhotoTotal: categories['photo']?['total'] as int? ?? 0,
        categoryVideoTotal: categories['video']?['total'] as int? ?? 0,
        acceptPhotographyShoots:
            categories['photo']?['acceptedShoots'] as int? ?? 0,
        acceptVideographyShoots:
            categories['video']?['acceptedShoots'] as int? ?? 0,
        rejectedPhoto: categories['photo']?['rejectedShoots'] as int? ?? 0,
        rejectedVideo: categories['video']?['rejectedShoots'] as int? ?? 0,
        requestPhoto: categories['photo']?['shootRequests'] as int? ?? 0,
        requestVideo: categories['video']?['shootRequests'] as int? ?? 0,
      );
    }
  }

  /// Adjust focusedDay by [delta] months and re-fetch availability.
  Future<void> changeMonth(int delta) async {
    final current = state.focusedDay;
    final next = DateTime(current.year, current.month + delta);
    state = state.copyWith(focusedDay: next);
    final repo = ref.read(homeRepositoryProvider);
    final availability =
        await _safeFetchAvailability(repo, next.month, next.year);
    if (availability != null) {
      state = state.copyWith(events: _prepareAvailabilityEvents(availability));
    }
  }

  /// Calendar page changed — update focusedDay and re-fetch availability.
  Future<void> onPageChanged(DateTime day) async {
    state = state.copyWith(focusedDay: day);
    final repo = ref.read(homeRepositoryProvider);
    final availability =
        await _safeFetchAvailability(repo, day.month, day.year);
    if (availability != null) {
      state = state.copyWith(events: _prepareAvailabilityEvents(availability));
    }
  }

  /// Accept or decline a pending shoot request. Refreshes pending list +
  /// dashboard counts on success.
  Future<void> acceptDecline(int projectId, int crewAccept) async {
    final repo = ref.read(homeRepositoryProvider);
    try {
      await repo.acceptDeclineProject(projectId, crewAccept);
      // Refresh only the affected sections.
      final pending = await _safeFetchPendingRequests(repo);
      final counts = await _safeFetchDashboardCount(repo);
      state = state.copyWith(
        pendingRequestCards: pending,
        completedShoots: counts?.completedShoots,
        upcomingShoots: counts?.upcomingShoots,
        pendingRequests: counts?.pendingRequests,
      );
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

  /// Re-fetch profile only (used when returning from profile screen).
  Future<void> refreshAfterProfileReturn() async {
    final repo = ref.read(homeRepositoryProvider);
    final profileData = await _safeFetchProfile(repo);
    if (profileData != null) {
      state = state.copyWith(profileData: profileData);
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────

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

  Future<dashboard.DashboardCountData?> _safeFetchDashboardCount(HomeRepository repo) async {
    try {
      return await repo.fetchDashboardCount();
    } catch (e, st) {
      AppLogger.e('Home fetchDashboardCount failed', e, st);
      return null;
    }
  }

  Future<List<UpcomingShootDatum>?> _safeFetchUpcomingShoots(
    HomeRepository repo,
  ) async {
    try {
      return await repo.fetchUpcomingShoots();
    } catch (e, st) {
      AppLogger.e('Home fetchUpcomingShoots failed', e, st);
      return null;
    }
  }

  Future<List<PendingRequestCard>?> _safeFetchPendingRequests(
    HomeRepository repo,
  ) async {
    try {
      return await repo.fetchPendingRequests();
    } catch (e, st) {
      AppLogger.e('Home fetchPendingRequests failed', e, st);
      return null;
    }
  }

  Future<CrewStatsData?> _safeFetchCrewStats(
    HomeRepository repo,
    String filter,
  ) async {
    try {
      return await repo.fetchCrewStats(filter);
    } catch (e, st) {
      AppLogger.e('Home fetchCrewStats failed', e, st);
      return null;
    }
  }

  Future<Map<String, dynamic>?> _safeFetchShootCategories(
    HomeRepository repo,
    String tab,
  ) async {
    try {
      return await repo.fetchShootCategories(tab);
    } catch (e, st) {
      AppLogger.e('Home fetchShootCategories failed', e, st);
      return null;
    }
  }

  Future<Map<String, dynamic>?> _safeFetchAvailability(
    HomeRepository repo,
    int month,
    int year,
  ) async {
    try {
      return await repo.fetchAvailability(month, year);
    } catch (e, st) {
      AppLogger.e('Home fetchAvailability failed', e, st);
      return null;
    }
  }

  Future<profile.MyProfileData?> _safeFetchProfile(HomeRepository repo) async {
    try {
      final profileData = await repo.fetchProfile();
      try {
        final session = ref.read(sessionStoreProvider);
        final currentUser = await session.readUser();
        final updatedUser = UserSnapshot(
          id: profileData.user.id.toString(),
          name: profileData.user.name,
          email: profileData.user.email,
          role: currentUser?.role ?? (profileData.user.primaryRole.isNotEmpty ? profileData.user.primaryRole : null),
          userType: currentUser?.userType ?? profileData.user.userType.toString(),
          profileImageUrl: profileData.user.profileImageUrl.isNotEmpty
              ? profileData.user.profileImageUrl
              : currentUser?.profileImageUrl,
        );
        await session.writeUser(updatedUser);
      } catch (e) {
        AppLogger.w('Failed to update session user snapshot: $e');
      }
      return profileData;
    } catch (e, st) {
      AppLogger.e('Home fetchProfile failed', e, st);
      return null;
    }
  }
}
