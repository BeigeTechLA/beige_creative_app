import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/guest_mode_provider.dart';
import '../../../../core/session/session_store.dart';
import '../../../../core/session/temporary_auth_session.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../model_class/creator_dashboard_model.dart';
import '../../../../model_class/myprofile_model.dart' as profile;
import '../../../availability/data/repositories/availability_repository_impl.dart';
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
    if (ref.read(guestModeProvider)) {
      state = state.copyWith(isLoading: false);
      return;
    }
    final repo = ref.read(homeRepositoryProvider);

    final filterValue = _filterValueForRange(state.selectedRange);
    final day = state.focusedDay;

    final dashboardData = await _safeFetchCreatorDashboard(
      repo,
      filterValue,
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
    final day = state.focusedDay;

    final dashboardData = await _safeFetchCreatorDashboard(
      repo,
      filter,
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
    final day = state.focusedDay;

    final dashboardData = await _safeFetchCreatorDashboard(
      repo,
      filter,
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

    final dashboardData = await _safeFetchCreatorDashboard(
      repo,
      filter,
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

    final dashboardData = await _safeFetchCreatorDashboard(
      repo,
      filter,
      day.month,
      day.year,
    );

    if (dashboardData != null) {
      _applyDashboardData(dashboardData);
    }
  }

  /// Accept or decline a pending shoot request. Refreshes dashboard on success.
  Future<bool> acceptDecline(int projectId, int crewAccept) async {
    state = state.copyWith(
      actionInFlightProjectId: projectId,
      clearError: true,
    );
    final repo = ref.read(homeRepositoryProvider);
    try {
      await repo.acceptDeclineProject(projectId, crewAccept);
      await refresh();
      state = state.copyWith(actionInFlightProjectId: 0);
      return true;
    } catch (e, st) {
      AppLogger.e('Home acceptDecline failed', e, st);
      state = state.copyWith(
        actionInFlightProjectId: 0,
        errorMessage: 'Failed to respond to shoot',
      );
      return false;
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

  Future<void> setUpcomingFilters({
    String? date,
    DateTime? customStartDate,
    DateTime? customEndDate,
    String? status,
    String? category,
    String? type,
  }) async {
    state = state.copyWith(
      upcomingSelectedDate: date,
      upcomingCustomStartDate: customStartDate,
      upcomingCustomEndDate: customEndDate,
      upcomingSelectedStatus: status,
      upcomingSelectedCategory: category,
      upcomingSelectedType: type,
    );
    await refresh();
  }

  Future<void> clearUpcomingFilters() async {
    state = state.copyWith(clearFilters: true);
    await refresh();
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

  String? _mapDateFilterToApi(String? date) {
    if (date == null || date.isEmpty) return null;
    switch (date) {
      case 'Today':
        return 'today';
      case 'This Week':
        return 'this_week';
      case 'This Month':
        return 'this_month';
      case 'Custom Range':
        return 'custom';
      default:
        return date.toLowerCase().replaceAll(' ', '_');
    }
  }

  String? _mapStatusToApi(String? status) {
    if (status == null || status.isEmpty) return null;
    return status.toLowerCase();
  }

  String? _formatDateForApi(DateTime? date) {
    if (date == null) return null;
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void _applyDashboardData(CreatorDashboardPayload data) {
    final counts = data.dashboardCounts;
    final stats = data.crewStats;
    final categories = data.shootCategories;
    final availability = data.availability;
    final profileData = data.profileDetail;

    final hasPhotoCrewStats =
        stats != null &&
        (stats.photographyShoots > 0 ||
            stats.photoRejectedShoots > 0 ||
            stats.photoShootRequests > 0);

    final hasVideoCrewStats =
        stats != null &&
        (stats.videographyShoots > 0 ||
            stats.videoRejectedShoots > 0 ||
            stats.videoShootRequests > 0);

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
      categoryPhotoTotal:
          (hasPhotoCrewStats &&
              (stats.photoRejectedShoots > 0 || stats.photoShootRequests > 0))
          ? (stats.photographyShoots +
                stats.photoRejectedShoots +
                stats.photoShootRequests)
          : (categories?['photo']?['total'] as int? ??
                ((stats?.photographyShoots ??
                        categories?['photo']?['acceptedShoots'] as int? ??
                        0) +
                    (stats?.photoRejectedShoots ??
                        categories?['photo']?['rejectedShoots'] as int? ??
                        0) +
                    (stats?.photoShootRequests ??
                        categories?['photo']?['shootRequests'] as int? ??
                        0))),
      categoryVideoTotal:
          (hasVideoCrewStats &&
              (stats.videoRejectedShoots > 0 || stats.videoShootRequests > 0))
          ? (stats.videographyShoots +
                stats.videoRejectedShoots +
                stats.videoShootRequests)
          : (categories?['video']?['total'] as int? ??
                ((stats?.videographyShoots ??
                        categories?['video']?['acceptedShoots'] as int? ??
                        0) +
                    (stats?.videoRejectedShoots ??
                        categories?['video']?['rejectedShoots'] as int? ??
                        0) +
                    (stats?.videoShootRequests ??
                        categories?['video']?['shootRequests'] as int? ??
                        0))),
      acceptPhotographyShoots: hasPhotoCrewStats
          ? stats.photographyShoots
          : (categories?['photo']?['acceptedShoots'] as int?),
      acceptVideographyShoots: hasVideoCrewStats
          ? stats.videographyShoots
          : (categories?['video']?['acceptedShoots'] as int?),
      rejectedPhoto: (stats != null && stats.photoRejectedShoots > 0)
          ? stats.photoRejectedShoots
          : (categories?['photo']?['rejectedShoots'] as int?),
      rejectedVideo: (stats != null && stats.videoRejectedShoots > 0)
          ? stats.videoRejectedShoots
          : (categories?['video']?['rejectedShoots'] as int?),
      requestPhoto: (stats != null && stats.photoShootRequests > 0)
          ? stats.photoShootRequests
          : (categories?['photo']?['shootRequests'] as int?),
      requestVideo: (stats != null && stats.videoShootRequests > 0)
          ? stats.videoShootRequests
          : (categories?['video']?['shootRequests'] as int?),
      // Availability
      availabilityDays: availability != null
          ? AvailabilityRepositoryImpl.parseAvailability(availability)
          : null,
      events: availability != null
          ? _prepareAvailabilityEvents(availability)
          : null,
      // Profile
      profileData: profileData,
      // Done
      isLoading: false,
    );
  }

  Future<void> _updateSessionUserSnapshot(
    profile.MyProfileData profileData,
  ) async {
    try {
      final session = ref.read(sessionStoreProvider);
      final temporarySession = ref.read(temporaryAuthSessionProvider);
      final currentUser = temporarySession.user ?? await session.readUser();
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
          firstName: profileData.firstName.isNotEmpty
              ? profileData.firstName
              : currentUser?.firstName,
          lastName: profileData.lastName.isNotEmpty
              ? profileData.lastName
              : currentUser?.lastName,
          name: profileData.user.name,
          email: profileData.user.email,
          phoneNumber: profileData.phoneNumber.isNotEmpty
              ? profileData.phoneNumber
              : currentUser?.phoneNumber,
          location: profileData.location.isNotEmpty
              ? profileData.location
              : currentUser?.location,
          workingDistance: profileData.workingDistance.isNotEmpty
              ? profileData.workingDistance
              : currentUser?.workingDistance,
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
          isRegistrationComplete:
              profileData.isRegistrationComplete ??
              currentUser?.isRegistrationComplete,
          isCrewVerified:
              profileData.isCrewVerified ?? currentUser?.isCrewVerified,
          isStep2Complete: currentUser?.isStep2Complete,
          crewMemberId: profileData.crewMemberId != 0
              ? profileData.crewMemberId
              : currentUser?.crewMemberId,
        );
        if (temporarySession.isActive && updatedUser.isCrewVerified == 1) {
          await session.writeToken(temporarySession.token!);
          await session.writeUser(updatedUser);
          await session.writeLastLoginAt(
            temporarySession.loginAt ?? DateTime.now().toUtc(),
          );
          ref.read(temporaryAuthSessionProvider.notifier).clear();
        } else if (temporarySession.isActive) {
          ref
              .read(temporaryAuthSessionProvider.notifier)
              .updateUser(updatedUser);
        } else {
          await session.writeUser(updatedUser);
        }
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
    int month,
    int year,
  ) async {
    if (ref.read(guestModeProvider)) return null;

    final projectsStatus = _mapStatusToApi(state.upcomingSelectedStatus);
    final projectsDateFilter = _mapDateFilterToApi(state.upcomingSelectedDate);
    final projectsStartDate = _formatDateForApi(state.upcomingCustomStartDate);
    final projectsEndDate = _formatDateForApi(state.upcomingCustomEndDate);

    try {
      return await repo.fetchCreatorDashboard(
        statsDateFilter: statsFilter,
        availabilityMonth: month,
        availabilityYear: year,
        projectsStatus: projectsStatus,
        projectsDateFilter: projectsDateFilter,
        projectsStartDate: projectsStartDate,
        projectsEndDate: projectsEndDate,
      );
    } catch (e, st) {
      AppLogger.e('Home fetchCreatorDashboard failed', e, st);
      return null;
    }
  }

  Future<profile.MyProfileData?> _safeFetchProfile(HomeRepository repo) async {
    if (ref.read(guestModeProvider)) return null;

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
