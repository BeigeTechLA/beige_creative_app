import 'package:beige_creative_app/config/env.dart';
import 'package:beige_creative_app/core/firebase/telemetry_client.dart';
import 'package:beige_creative_app/features/shoots/domain/repositories/shoots_repository.dart';
import 'package:beige_creative_app/features/shoots/presentation/providers/shoots_providers.dart';
import 'package:beige_creative_app/features/shoots/presentation/providers/upcoming_shoot_providers.dart';
import 'package:beige_creative_app/model_class/shoot_count_model.dart'
    as count_model;
import 'package:beige_creative_app/model_class/shoots_model.dart';
import 'package:beige_creative_app/model_class/upcoming_shootview_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeShootsRepo implements ShootsRepository {
  int fetchShootsCount = 0;
  int fetchCountCount = 0;
  int respondCount = 0;
  int? lastRespondId;
  String? lastStatus;
  String? lastReason;
  String? lastComment;
  bool throwOnFetchShoots = false;
  bool throwOnFetchCount = false;
  bool throwOnRespond = false;

  List<Shoot> requests = const [];
  List<Shoot> shoots = const [];
  count_model.ShootCountData counts = count_model.ShootCountData(
    completedShoots: 0,
    pendingRequests: 0,
    confirmedRequests: 0,
    rejectedRequests: 0,
  );

  List<Shoot> cardShoots = const [];
  int fetchCardDetailsCount = 0;
  String? lastCardStatus;
  bool throwOnFetchCardDetails = false;

  @override
  Future<List<Shoot>> fetchShootCardDetails(String status) async {
    fetchCardDetailsCount++;
    lastCardStatus = status;
    if (throwOnFetchCardDetails) throw Exception('boom');
    return cardShoots;
  }

  @override
  Future<ShootsData> fetchShoots({
    String requestStatus = 'all',
    String shootStatus = 'completed',
  }) async {
    fetchShootsCount++;
    if (throwOnFetchShoots) throw Exception('boom');
    return ShootsData(
      requests: requests.isNotEmpty ? requests : shoots,
      shoots: requests.isNotEmpty ? shoots : [],
    );
  }

  @override
  Future<count_model.ShootCountData> fetchShootCount() async {
    fetchCountCount++;
    if (throwOnFetchCount) throw Exception('boom');
    return counts;
  }

  @override
  Future<MyData> fetchProjectDetail(int projectId) {
    throw UnimplementedError();
  }

  @override
  Future<void> respondToProject({
    required int projectId,
    required String status,
    String? reason,
    String? comment,
  }) async {
    respondCount++;
    lastRespondId = projectId;
    lastStatus = status;
    lastReason = reason;
    lastComment = comment;
    if (throwOnRespond) throw Exception('boom');
  }
}

class _RecordingTelemetry implements TelemetryClient {
  final List<({String name, Map<String, Object>? parameters})> events =
      <({String name, Map<String, Object>? parameters})>[];

  @override
  Future<void> setUserIdentity({
    required String userId,
    String? userRole,
    String loginMethod = 'password',
  }) async {}

  @override
  Future<void> clearUserIdentity({bool emitLogoutEvent = false}) async {}

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    events.add((name: name, parameters: parameters));
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {}
}

Shoot _shoot({
  required int id,
  required int projectId,
  String projectName = 'Sample Project',
  String contentType = 'Wedding',
  String status = 'pending',
  int crewAccept = 0,
}) {
  return Shoot(
    id: id,
    projectId: projectId,
    crewMemberId: 9,
    projectName: projectName,
    eventDate: DateTime(2026, 6, 15),
    startTime: '09:00',
    endTime: '17:00',
    eventLocation: 'NYC',
    contentType: contentType,
    shootTypeId: 1,
    shootType: contentType,
    shootTypeImageUrl: '',
    totalAmount: 1200,
    budget: 1200,
    status: status,
    crewAccept: crewAccept,
    canTakeAction: true,
  );
}

Future<void> _drain(bool Function() done) async {
  for (var i = 0; i < 40; i++) {
    if (done()) return;
    await Future<void>.delayed(Duration.zero);
  }
}

Future<void> _drainTime(Duration d) async {
  // Drains microtasks for at least [d] of real wall time so the notifier's
  // debounce Timer can fire. Using real waits rather than fake_async keeps
  // the test in line with the existing harness pattern.
  final deadline = DateTime.now().add(d);
  while (DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

void main() {
  setUpAll(() => Env.init(Environment.dev));

  ProviderContainer make(
    _FakeShootsRepo repo, {
    _RecordingTelemetry? telemetry,
  }) {
    return ProviderContainer(
      overrides: [
        shootsRepositoryProvider.overrideWithValue(repo),
        if (telemetry != null)
          telemetryClientProvider.overrideWithValue(telemetry),
      ],
    );
  }

  group('ShootsListNotifier — refresh', () {
    test('hydrates shoots + counts on build', () async {
      final repo = _FakeShootsRepo()
        ..shoots = [
          _shoot(id: 1, projectId: 100),
          _shoot(id: 2, projectId: 200),
        ]
        ..counts = count_model.ShootCountData(
          completedShoots: 3,
          pendingRequests: 2,
          confirmedRequests: 4,
          rejectedRequests: 1,
        );
      final c = make(repo);
      addTearDown(c.dispose);
      c.listen(shootsListProvider, (_, _) {});
      await _drain(() => !c.read(shootsListProvider).isLoading);

      final s = c.read(shootsListProvider);
      expect(s.allShoots.length, 2);
      expect(s.visibleShoots.length, 2);
      expect(s.counts?.pendingRequests, 2);
      expect(s.errorMessage, isNull);
      expect(repo.fetchShootsCount, 1);
      expect(repo.fetchCountCount, 1);
    });

    test('count fetch failure does not block list', () async {
      final repo = _FakeShootsRepo()
        ..shoots = [_shoot(id: 1, projectId: 100)]
        ..throwOnFetchCount = true;
      final c = make(repo);
      addTearDown(c.dispose);
      c.listen(shootsListProvider, (_, _) {});
      await _drain(() => !c.read(shootsListProvider).isLoading);
      final s = c.read(shootsListProvider);
      expect(s.allShoots.length, 1);
      expect(s.counts, isNull);
      expect(s.errorMessage, isNull);
    });

    test('shoots fetch failure surfaces errorMessage', () async {
      final repo = _FakeShootsRepo()..throwOnFetchShoots = true;
      final c = make(repo);
      addTearDown(c.dispose);
      c.listen(shootsListProvider, (_, _) {});
      await _drain(() => !c.read(shootsListProvider).isLoading);
      expect(c.read(shootsListProvider).errorMessage, 'Failed to load shoots');
    });
  });

  group('ShootsListNotifier — search debounce', () {
    test(
      'multiple rapid updateSearch calls within window collapse to one filter',
      () async {
        final repo = _FakeShootsRepo()
          ..shoots = [
            _shoot(id: 1, projectId: 100, projectName: 'Beach wedding'),
            _shoot(id: 2, projectId: 200, projectName: 'Office party'),
            _shoot(id: 3, projectId: 300, projectName: 'Bridal shoot'),
          ];
        final c = make(repo);
        addTearDown(c.dispose);
        c.listen(shootsListProvider, (_, _) {});
        await _drain(() => !c.read(shootsListProvider).isLoading);

        final notifier = c.read(shootsListProvider.notifier);

        // Capture fetch baseline — repo should not be re-hit on search.
        final fetchBefore = repo.fetchShootsCount;

        // Rapid-fire keystrokes ("b" → "br" → "bri") within the debounce window.
        notifier.updateSearch('b');
        notifier.updateSearch('br');
        notifier.updateSearch('bri');

        // Before the debounce expires the query is recorded but visibleShoots
        // still reflects the previous filter (full list).
        expect(c.read(shootsListProvider).searchQuery, 'bri');
        expect(c.read(shootsListProvider).visibleShoots.length, 3);

        // Wait past the 250ms debounce window.
        await _drainTime(const Duration(milliseconds: 350));

        // Only one filter pass should have landed → matches 'Bridal shoot' only.
        final s = c.read(shootsListProvider);
        expect(s.visibleShoots.length, 1);
        expect(s.visibleShoots.first.projectName, 'Bridal shoot');

        // Critically: no extra network calls for any of the keystrokes.
        expect(repo.fetchShootsCount, fetchBefore);
      },
    );

    test('empty query returns full list', () async {
      final repo = _FakeShootsRepo()
        ..shoots = [
          _shoot(id: 1, projectId: 100, projectName: 'Beach wedding'),
          _shoot(id: 2, projectId: 200, projectName: 'Office party'),
        ];
      final c = make(repo);
      addTearDown(c.dispose);
      c.listen(shootsListProvider, (_, _) {});
      await _drain(() => !c.read(shootsListProvider).isLoading);

      final notifier = c.read(shootsListProvider.notifier);
      notifier.updateSearch('beach');
      await _drainTime(const Duration(milliseconds: 350));
      expect(c.read(shootsListProvider).visibleShoots.length, 1);

      notifier.updateSearch('');
      await _drainTime(const Duration(milliseconds: 350));
      expect(c.read(shootsListProvider).visibleShoots.length, 2);
    });
  });

  group('ShootsListNotifier — accept flow', () {
    test('acceptShoot posts accepted + refreshes', () async {
      final repo = _FakeShootsRepo()..shoots = [_shoot(id: 1, projectId: 100)];
      final telemetry = _RecordingTelemetry();
      final c = make(repo, telemetry: telemetry);
      addTearDown(c.dispose);
      c.listen(shootsListProvider, (_, _) {});
      await _drain(() => !c.read(shootsListProvider).isLoading);

      final ok = await c.read(shootsListProvider.notifier).acceptShoot(100);
      expect(ok, isTrue);
      expect(repo.respondCount, 1);
      expect(repo.lastStatus, 'accepted');
      expect(repo.lastRespondId, 100);
      // Refresh re-pulls the list after accept.
      expect(repo.fetchShootsCount, greaterThan(1));
      expect(c.read(shootsListProvider).actionInFlightProjectId, 0);
      expect(telemetry.events.map((e) => e.name), ['shoot_accepted']);
      expect(telemetry.events.single.parameters, {'shoot_id': '100'});
    });

    test('accept failure sets errorMessage + clears action flag', () async {
      final repo = _FakeShootsRepo()
        ..shoots = [_shoot(id: 1, projectId: 100)]
        ..throwOnRespond = true;
      final telemetry = _RecordingTelemetry();
      final c = make(repo, telemetry: telemetry);
      addTearDown(c.dispose);
      c.listen(shootsListProvider, (_, _) {});
      await _drain(() => !c.read(shootsListProvider).isLoading);

      final ok = await c.read(shootsListProvider.notifier).acceptShoot(100);
      expect(ok, isFalse);
      final s = c.read(shootsListProvider);
      expect(s.errorMessage, 'Failed to accept shoot');
      expect(s.actionInFlightProjectId, 0);
      expect(telemetry.events, isEmpty);
    });
  });

  group('CancelShootNotifier — decline flow', () {
    test('submit rejects empty reason', () async {
      final repo = _FakeShootsRepo();
      final telemetry = _RecordingTelemetry();
      final c = make(repo, telemetry: telemetry);
      addTearDown(c.dispose);
      c.listen(cancelShootProvider(100), (_, _) {});

      final ok = await c.read(cancelShootProvider(100).notifier).submit();
      expect(ok, isFalse);
      expect(repo.respondCount, 0);
      expect(
        c.read(cancelShootProvider(100)).errorMessage,
        'Please choose a reason',
      );
      expect(telemetry.events, isEmpty);
    });

    test('submit posts declined + bumps submittedSignal', () async {
      final repo = _FakeShootsRepo();
      final telemetry = _RecordingTelemetry();
      final c = make(repo, telemetry: telemetry);
      addTearDown(c.dispose);
      c.listen(cancelShootProvider(100), (_, _) {});

      final notifier = c.read(cancelShootProvider(100).notifier);
      notifier.selectReason('Schedule conflict');
      final before = c.read(cancelShootProvider(100)).submittedSignal;
      final ok = await notifier.submit(comment: 'busy week');
      expect(ok, isTrue);
      expect(repo.respondCount, 1);
      expect(repo.lastStatus, 'declined');
      expect(repo.lastReason, 'Schedule conflict');
      expect(repo.lastComment, 'busy week');
      expect(repo.lastRespondId, 100);
      expect(
        c.read(cancelShootProvider(100)).submittedSignal,
        greaterThan(before),
      );
      expect(telemetry.events.map((e) => e.name), ['shoot_cancelled']);
      expect(telemetry.events.single.parameters, {'shoot_id': '100'});
    });

    test(
      'submit failure surfaces errorMessage + leaves signal untouched',
      () async {
        final repo = _FakeShootsRepo()..throwOnRespond = true;
        final telemetry = _RecordingTelemetry();
        final c = make(repo, telemetry: telemetry);
        addTearDown(c.dispose);
        c.listen(cancelShootProvider(100), (_, _) {});

        final notifier = c.read(cancelShootProvider(100).notifier);
        notifier.selectReason('Rate too low');
        final before = c.read(cancelShootProvider(100)).submittedSignal;
        final ok = await notifier.submit();
        expect(ok, isFalse);
        final s = c.read(cancelShootProvider(100));
        expect(s.errorMessage, 'Something went wrong');
        expect(s.submittedSignal, before);
        expect(s.isSubmitting, isFalse);
        expect(telemetry.events, isEmpty);
      },
    );
  });

  group('selectTopCard & clearTopCardSelection', () {
    test('selectTopCard fetches creator/shoot-card-details and updates visibleShoots', () async {
      final repo = _FakeShootsRepo()
        ..cardShoots = [_shoot(id: 99, projectId: 99, projectName: 'Top Card Shoot', status: 'pending')];
      final c = make(repo);
      addTearDown(c.dispose);
      c.listen(shootsListProvider, (_, _) {});
      await _drain(() => !c.read(shootsListProvider).isLoading);

      await c.read(shootsListProvider.notifier).selectTopCard('Pending Shoots');

      final state = c.read(shootsListProvider);
      expect(state.selectedTopCard, 'Pending Shoots');
      expect(repo.fetchCardDetailsCount, 1);
      expect(repo.lastCardStatus, 'pending');
      expect(state.visibleShoots.length, 1);
      expect(state.visibleShoots.first.projectName, 'Top Card Shoot');
    });

    test('clearTopCardSelection restores standard tab filter view', () async {
      final repo = _FakeShootsRepo()
        ..shoots = [_shoot(id: 1, projectId: 1, projectName: 'Regular Shoot')]
        ..cardShoots = [_shoot(id: 99, projectId: 99, projectName: 'Top Card Shoot')];
      final c = make(repo);
      addTearDown(c.dispose);
      c.listen(shootsListProvider, (_, _) {});
      await _drain(() => !c.read(shootsListProvider).isLoading);

      await c.read(shootsListProvider.notifier).selectTopCard('Pending Shoots');
      expect(c.read(shootsListProvider).selectedTopCard, 'Pending Shoots');

      c.read(shootsListProvider.notifier).clearTopCardSelection();

      final state = c.read(shootsListProvider);
      expect(state.selectedTopCard, isNull);
      expect(state.topCardShoots, isNull);
    });
  });

  group('setStatusFilter', () {
    test('filters requests by Pending, Confirmed, Completed, Declined', () async {
      final repo = _FakeShootsRepo()
        ..requests = [
          _shoot(id: 1, projectId: 10, status: 'pending', crewAccept: 0),
          _shoot(id: 2, projectId: 20, status: 'accepted', crewAccept: 1),
        ]
        ..shoots = [
          _shoot(id: 3, projectId: 30, status: 'completed'),
          _shoot(id: 4, projectId: 40, status: 'declined'),
        ];
      final c = make(repo);
      addTearDown(c.dispose);
      c.listen(shootsListProvider, (_, _) {});
      await _drain(() => !c.read(shootsListProvider).isLoading);

      final notifier = c.read(shootsListProvider.notifier);

      // On Tab 0 (requests): 'Pending' matches 1 item
      notifier.setStatusFilter('Pending');
      expect(c.read(shootsListProvider).selectedStatusFilter, 'Pending');
      expect(c.read(shootsListProvider).visibleShoots.length, 1);
      expect(c.read(shootsListProvider).visibleShoots.first.id, 1);

      // On Tab 0 (requests): 'Confirmed' matches 1 item
      notifier.setStatusFilter('Confirmed');
      expect(c.read(shootsListProvider).selectedStatusFilter, 'Confirmed');
      expect(c.read(shootsListProvider).visibleShoots.length, 1);
      expect(c.read(shootsListProvider).visibleShoots.first.id, 2);

      // Switch to Tab 1 (shoots): 'Completed' matches 1 item
      notifier.selectTab(1);
      notifier.setStatusFilter('Completed');
      expect(c.read(shootsListProvider).selectedStatusFilter, 'Completed');
      expect(c.read(shootsListProvider).visibleShoots.length, 1);
      expect(c.read(shootsListProvider).visibleShoots.first.id, 3);

      // On Tab 1 (shoots): 'Declined' matches 1 item
      notifier.setStatusFilter('Declined');
      expect(c.read(shootsListProvider).selectedStatusFilter, 'Declined');
      expect(c.read(shootsListProvider).visibleShoots.length, 1);
      expect(c.read(shootsListProvider).visibleShoots.first.id, 4);

      // 'All Status' restores tab 1 full list
      notifier.setStatusFilter('All Status');
      expect(c.read(shootsListProvider).visibleShoots.length, 2);
    });

    test('setStatusFilter re-filters even when called with the same status name', () async {
      final repo = _FakeShootsRepo()
        ..requests = [
          _shoot(id: 1, projectId: 10, status: 'pending', crewAccept: 0),
          _shoot(id: 2, projectId: 20, status: 'accepted', crewAccept: 1),
        ];
      final c = make(repo);
      addTearDown(c.dispose);
      c.listen(shootsListProvider, (_, _) {});
      await _drain(() => !c.read(shootsListProvider).isLoading);

      final notifier = c.read(shootsListProvider.notifier);
      notifier.setStatusFilter('Pending');
      expect(c.read(shootsListProvider).visibleShoots.length, 1);

      notifier.setStatusFilter('Pending');
      expect(c.read(shootsListProvider).visibleShoots.length, 1);
    });

    test('setStatusFilter filters topCardShoots dataset when top card is active', () async {
      final repo = _FakeShootsRepo()
        ..cardShoots = [
          _shoot(id: 10, projectId: 10, status: 'pending', crewAccept: 0),
          _shoot(id: 20, projectId: 20, status: 'confirmed', crewAccept: 1),
        ];
      final c = make(repo);
      addTearDown(c.dispose);
      c.listen(shootsListProvider, (_, _) {});
      await _drain(() => !c.read(shootsListProvider).isLoading);

      final notifier = c.read(shootsListProvider.notifier);
      await notifier.selectTopCard('Pending Shoots');
      expect(c.read(shootsListProvider).visibleShoots.length, 2);

      notifier.setStatusFilter('Confirmed');
      expect(c.read(shootsListProvider).visibleShoots.length, 1);
      expect(c.read(shootsListProvider).visibleShoots.first.id, 20);
    });
  });
}
