import 'package:beige_creative_app/features/home/domain/repositories/home_repository.dart';
import 'package:beige_creative_app/features/home/presentation/providers/home_notifier.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_category.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_filter.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_platform.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_response.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meeting_status.dart';
import 'package:beige_creative_app/features/meetings/domain/models/meetings_tab.dart';
import 'package:beige_creative_app/features/meetings/domain/models/update_meeting_input.dart';
import 'package:beige_creative_app/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:beige_creative_app/features/meetings/presentation/providers/meetings_repository_provider.dart';
import 'package:beige_creative_app/model_class/create_dashboard_details_model.dart';
import 'package:beige_creative_app/model_class/crewstatus_model.dart';
import 'package:beige_creative_app/model_class/dashboard_count_model.dart'
    as dashboard;
import 'package:beige_creative_app/model_class/myprofile_model.dart' as profile;
import 'package:beige_creative_app/model_class/upcoming_shoots_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fake repository
// ─────────────────────────────────────────────────────────────────────────────

class _FakeHomeRepo implements HomeRepository {
  dashboard.DashboardCountData? dashboardCountResult;
  List<UpcomingShootDatum>? upcomingShoots;
  List<PendingRequestCard>? pendingRequests;
  CrewStatsData? crewStatsResult;
  Map<String, dynamic>? shootCategoriesResult;
  Map<String, dynamic>? availabilityResult;
  profile.MyProfileData? profileResult;

  bool shouldFailCrewStats = false;
  bool shouldFailAcceptDecline = false;

  String? lastStatsFilter;
  String? lastCategoriesTab;
  int? lastAvailabilityMonth;
  int? lastAvailabilityYear;
  int? lastAcceptProjectId;
  int? lastAcceptCrewAccept;

  @override
  Future<dashboard.DashboardCountData> fetchDashboardCount() async {
    if (dashboardCountResult == null) throw Exception('no data');
    return dashboardCountResult!;
  }

  @override
  Future<List<UpcomingShootDatum>> fetchUpcomingShoots() async {
    return upcomingShoots ?? [];
  }

  @override
  Future<List<PendingRequestCard>> fetchPendingRequests() async {
    return pendingRequests ?? [];
  }

  @override
  Future<CrewStatsData> fetchCrewStats(String filter) async {
    lastStatsFilter = filter;
    if (shouldFailCrewStats) throw Exception('stats failed');
    if (crewStatsResult == null) throw Exception('no stats');
    return crewStatsResult!;
  }

  @override
  Future<Map<String, dynamic>> fetchShootCategories(String tab) async {
    lastCategoriesTab = tab;
    return shootCategoriesResult ?? {};
  }

  @override
  Future<Map<String, dynamic>> fetchAvailability(int month, int year) async {
    lastAvailabilityMonth = month;
    lastAvailabilityYear = year;
    return availabilityResult ?? {};
  }

  @override
  Future<profile.MyProfileData> fetchProfile() async {
    if (profileResult == null) throw Exception('no profile');
    return profileResult!;
  }

  @override
  Future<void> acceptDeclineProject(int projectId, int crewAccept) async {
    lastAcceptProjectId = projectId;
    lastAcceptCrewAccept = crewAccept;
    if (shouldFailAcceptDecline) throw Exception('accept failed');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

dashboard.DashboardCountData _makeDashboardCount({
  int completed = 5,
  int upcoming = 3,
  int pending = 2,
}) => dashboard.DashboardCountModel.fromJson({
  'error': false,
  'message': 'ok',
  'data': {
    'completedShoots': completed,
    'upcomingShoots': upcoming,
    'pendingRequests': pending,
    'equipmentRequests': 0,
  },
}).data;

CrewStatsData _makeCrewStats({
  int completed = 10,
  int pendingS = 4,
  int rejected = 1,
  int requests = 7,
  int photo = 6,
  int video = 4,
}) => CrewStatsModel.fromJson({
  'error': false,
  'message': 'ok',
  'data': {
    'completedShoots': completed,
    'pendingShoots': pendingS,
    'rejectedShoots': rejected,
    'shootRequests': requests,
    'photographyShoots': photo,
    'videographyShoots': video,
  },
}).data;

/// Pumps microtasks until the notifier has finished its initial `refresh`.
Future<void> _drain() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class _FakeMeetingsRepo implements MeetingsRepository {
  List<Meeting> meetings = [];
  bool shouldFail = false;

  @override
  Future<List<Meeting>> list({
    MeetingsTab? tab,
    MeetingFilter? filter,
    String? currentUserId,
  }) async {
    if (shouldFail) throw Exception('meetings failed');
    return meetings;
  }

  @override
  Future<Meeting> getById(String id) => throw UnimplementedError();
  @override
  Future<Meeting> update(String id, UpdateMeetingInput patch) =>
      throw UnimplementedError();
  @override
  Future<void> delete(String id) => throw UnimplementedError();
  @override
  Future<Meeting> addParticipants(String id, List<String> userIds) =>
      throw UnimplementedError();
  @override
  Future<Meeting> respond(String id, MeetingResponse response) =>
      throw UnimplementedError();
}

ProviderContainer _createContainer(
  _FakeHomeRepo repo, [
  _FakeMeetingsRepo? meetingsRepo,
]) {
  final container = ProviderContainer(
    overrides: [
      homeRepositoryProvider.overrideWithValue(repo),
      meetingsRepositoryProvider.overrideWithValue(
        meetingsRepo ?? _FakeMeetingsRepo(),
      ),
    ],
  );
  addTearDown(container.dispose);
  // Force notifier creation.
  container.listen(homeNotifierProvider, (_, _) {});
  return container;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('HomeNotifier', () {
    test('refresh hydrates all data domains including meetings', () async {
      final repo = _FakeHomeRepo()
        ..dashboardCountResult = _makeDashboardCount()
        ..crewStatsResult = _makeCrewStats()
        ..shootCategoriesResult = {
          'photo': {
            'total': 12,
            'acceptedShoots': 8,
            'rejectedShoots': 2,
            'shootRequests': 3,
          },
          'video': {
            'total': 7,
            'acceptedShoots': 5,
            'rejectedShoots': 1,
            'shootRequests': 2,
          },
        };

      final dummyMeeting = Meeting(
        id: 'm1',
        title: 'Sync Meeting',
        description: '',
        project: 'Project Alpha',
        platform: MeetingPlatform.meet,
        startAt: DateTime(2026, 7, 17, 10),
        endAt: DateTime(2026, 7, 17, 11),
        link: 'https://meet.google.com/abc',
        reminderMinutes: 10,
        status: MeetingStatus.upcoming,
        category: MeetingCategory.commercial,
        agenda: const [],
        participants: const [],
      );

      final meetingsRepo = _FakeMeetingsRepo()..meetings = [dummyMeeting];
      final container = _createContainer(repo, meetingsRepo);
      await _drain();

      final state = container.read(homeNotifierProvider);
      expect(state.isLoading, false);
      expect(state.completedShoots, 5);
      expect(state.upcomingShoots, 3);
      expect(state.pendingRequests, 2);
      expect(state.successfulShoots, 10);
      expect(state.categoryPhotoTotal, 12);
      expect(state.categoryVideoTotal, 7);
      expect(state.upcomingMeetingsList.length, 1);
      expect(state.upcomingMeetingsList.first.title, 'Sync Meeting');
    });

    test('partial failure — meetings fails but other succeed', () async {
      final repo = _FakeHomeRepo()
        ..dashboardCountResult = _makeDashboardCount(completed: 99);
      final meetingsRepo = _FakeMeetingsRepo()..shouldFail = true;

      final container = _createContainer(repo, meetingsRepo);
      await _drain();

      final state = container.read(homeNotifierProvider);
      expect(state.isLoading, false);
      expect(state.completedShoots, 99);
      expect(state.upcomingMeetingsList, isEmpty);
      expect(state.errorMessage, isNull);
    });

    test('partial failure — crew stats fails but others succeed', () async {
      final repo = _FakeHomeRepo()
        ..dashboardCountResult = _makeDashboardCount(completed: 99)
        ..shouldFailCrewStats = true;

      final container = _createContainer(repo);
      await _drain();

      final state = container.read(homeNotifierProvider);
      expect(state.isLoading, false);
      // Dashboard counts populated.
      expect(state.completedShoots, 99);
      // Crew stats stay at default because the fetch failed.
      expect(state.successfulShoots, 0);
      // No errorMessage — partial failures are silent per legacy behavior.
      expect(state.errorMessage, isNull);
    });

    test('changeStatsRange re-fetches stats with new filter', () async {
      final repo = _FakeHomeRepo()
        ..dashboardCountResult = _makeDashboardCount()
        ..crewStatsResult = _makeCrewStats(completed: 20);

      final container = _createContainer(repo);
      await _drain();

      // Change range to Week.
      await container
          .read(homeNotifierProvider.notifier)
          .changeStatsRange('Week');
      await _drain();

      expect(repo.lastStatsFilter, 'this_week');
      final state = container.read(homeNotifierProvider);
      expect(state.selectedRange, 'Week');
      expect(state.successfulShoots, 20);
    });

    test('changeShootCategoryTab re-fetches categories', () async {
      final repo = _FakeHomeRepo()
        ..dashboardCountResult = _makeDashboardCount()
        ..crewStatsResult = _makeCrewStats()
        ..shootCategoriesResult = {
          'photo': {
            'total': 0,
            'acceptedShoots': 0,
            'rejectedShoots': 0,
            'shootRequests': 0,
          },
          'video': {
            'total': 15,
            'acceptedShoots': 10,
            'rejectedShoots': 3,
            'shootRequests': 5,
          },
        };

      final container = _createContainer(repo);
      await _drain();

      // Switch to video tab.
      await container
          .read(homeNotifierProvider.notifier)
          .changeShootCategoryTab(1);
      await _drain();

      expect(repo.lastCategoriesTab, 'video');
      final state = container.read(homeNotifierProvider);
      expect(state.selectedTab, 1);
      expect(state.categoryVideoTotal, 15);
    });

    test('acceptDecline posts accept and refreshes pending + counts', () async {
      final repo = _FakeHomeRepo()
        ..dashboardCountResult = _makeDashboardCount(pending: 1)
        ..crewStatsResult = _makeCrewStats()
        ..pendingRequests = [];

      final container = _createContainer(repo);
      await _drain();

      // Accept project 42.
      await container.read(homeNotifierProvider.notifier).acceptDecline(42, 1);
      await _drain();

      expect(repo.lastAcceptProjectId, 42);
      expect(repo.lastAcceptCrewAccept, 1);
      final state = container.read(homeNotifierProvider);
      expect(state.pendingRequestCards, isEmpty);
    });

    test('acceptDecline failure sets errorMessage', () async {
      final repo = _FakeHomeRepo()
        ..dashboardCountResult = _makeDashboardCount()
        ..crewStatsResult = _makeCrewStats()
        ..shouldFailAcceptDecline = true;

      final container = _createContainer(repo);
      await _drain();

      await container.read(homeNotifierProvider.notifier).acceptDecline(42, 1);
      await _drain();

      final state = container.read(homeNotifierProvider);
      expect(state.errorMessage, 'Failed to respond to shoot');
    });

    test(
      'changeMonth adjusts focusedDay and re-fetches availability',
      () async {
        final repo = _FakeHomeRepo()
          ..dashboardCountResult = _makeDashboardCount()
          ..crewStatsResult = _makeCrewStats()
          ..availabilityResult = {
            '2026-07-15': {'available': true, 'projectAssigned': false},
            '2026-07-20': {'available': false, 'projectAssigned': true},
          };

        final container = _createContainer(repo);
        await _drain();

        // Move forward one month.
        await container.read(homeNotifierProvider.notifier).changeMonth(1);
        await _drain();

        final state = container.read(homeNotifierProvider);
        // Availability re-fetched with new month.
        expect(repo.lastAvailabilityMonth, isNotNull);
        // Events should be populated from availabilityResult.
        expect(state.events.length, 2);
        expect(state.events.values, containsAll(['Available', 'Shoot']));
      },
    );
  });
}
