import 'package:beige_creative_app/config/env.dart';
import 'package:beige_creative_app/core/firebase/telemetry_client.dart';
import 'package:beige_creative_app/features/shoots/domain/repositories/shoots_repository.dart';
import 'package:beige_creative_app/features/shoots/presentation/providers/upcoming_shoot_providers.dart';
import 'package:beige_creative_app/model_class/shoot_count_model.dart'
    as count_model;
import 'package:beige_creative_app/model_class/shoots_model.dart';
import 'package:beige_creative_app/model_class/upcoming_shootview_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeShootsRepo implements ShootsRepository {
  int fetchCount = 0;
  int respondCount = 0;
  int? lastFetchedId;
  int? lastRespondId;
  String? lastStatus;
  String? lastReason;
  String? lastComment;
  bool throwOnFetch = false;
  bool throwOnRespond = false;

  MyData _sample() => MyData.fromJson(const {
    'project': {
      'project_id': 7,
      'project_name': 'Skyline Shoot',
      'status': 'pending',
      'image_url': 'cover.jpg',
      'event_date': '2026-06-15',
      'start_time': '09:00',
      'end_time': '17:00',
      'event_location': 'NYC',
      'shoot_type': 'Editorial',
      'booking_type': 'Hourly',
      'last_updated': null,
      'total_time_duration_hours': 8,
      'budget': 1200,
      'total_amount': 1200,
      'id_label': 'BG-7',
    },
    'payment_state': 'pending',
    'team_members': <Map<String, dynamic>>[],
    'team_summary': {'assigned_count': 1, 'total_required': 3},
    'client_contact': {
      'full_name': 'Jane',
      'email': 'j@example.com',
      'phone': '+1',
    },
  });

  @override
  Future<MyData> fetchProjectDetail(int projectId) async {
    fetchCount++;
    lastFetchedId = projectId;
    if (throwOnFetch) throw Exception('boom');
    return _sample();
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

  @override
  Future<List<Shoot>> fetchShoots() async => <Shoot>[];

  @override
  Future<count_model.ShootCountData> fetchShootCount() async =>
      count_model.ShootCountData(
        completedShoots: 0,
        pendingRequests: 0,
        confirmedRequests: 0,
        rejectedRequests: 0,
      );
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

Future<void> _drain(bool Function() done) async {
  for (var i = 0; i < 20; i++) {
    if (done()) return;
    await Future<void>.delayed(Duration.zero);
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

  test('refresh hydrates project detail from repo', () async {
    final repo = _FakeShootsRepo();
    final c = make(repo);
    addTearDown(c.dispose);
    c.listen(upcomingShootDetailProvider(7), (_, _) {});
    await _drain(() => !c.read(upcomingShootDetailProvider(7)).isLoading);
    expect(repo.fetchCount, 1);
    expect(repo.lastFetchedId, 7);
    final s = c.read(upcomingShootDetailProvider(7));
    expect(s.data?.project.projectName, 'Skyline Shoot');
    expect(s.errorMessage, isNull);
  });

  test('refresh surfaces error message on failure', () async {
    final repo = _FakeShootsRepo()..throwOnFetch = true;
    final c = make(repo);
    addTearDown(c.dispose);
    c.listen(upcomingShootDetailProvider(7), (_, _) {});
    await _drain(() => !c.read(upcomingShootDetailProvider(7)).isLoading);
    expect(
      c.read(upcomingShootDetailProvider(7)).errorMessage,
      'Failed to load project',
    );
  });

  test('accept posts accepted status + bumps respondedSignal', () async {
    final repo = _FakeShootsRepo();
    final telemetry = _RecordingTelemetry();
    final c = make(repo, telemetry: telemetry);
    addTearDown(c.dispose);
    c.listen(upcomingShootDetailProvider(7), (_, _) {});
    await _drain(() => !c.read(upcomingShootDetailProvider(7)).isLoading);
    final before = c.read(upcomingShootDetailProvider(7)).respondedSignal;
    final ok = await c.read(upcomingShootDetailProvider(7).notifier).accept();
    expect(ok, isTrue);
    expect(repo.respondCount, 1);
    expect(repo.lastRespondId, 7);
    expect(repo.lastStatus, 'accepted');
    expect(
      c.read(upcomingShootDetailProvider(7)).respondedSignal,
      greaterThan(before),
    );
    expect(telemetry.events.map((e) => e.name), ['shoot_accepted']);
    expect(telemetry.events.single.parameters, {'shoot_id': '7'});
  });

  test('decline carries reason + comment to repo', () async {
    final repo = _FakeShootsRepo();
    final telemetry = _RecordingTelemetry();
    final c = make(repo, telemetry: telemetry);
    addTearDown(c.dispose);
    c.listen(upcomingShootDetailProvider(7), (_, _) {});
    await _drain(() => !c.read(upcomingShootDetailProvider(7)).isLoading);
    final ok = await c
        .read(upcomingShootDetailProvider(7).notifier)
        .decline(reason: 'scheduling', comment: 'busy that week');
    expect(ok, isTrue);
    expect(repo.lastStatus, 'declined');
    expect(repo.lastReason, 'scheduling');
    expect(repo.lastComment, 'busy that week');
    expect(telemetry.events.map((e) => e.name), ['shoot_declined']);
    expect(telemetry.events.single.parameters, {'shoot_id': '7'});
  });

  test('respond failure sets errorMessage + returns false', () async {
    final repo = _FakeShootsRepo()..throwOnRespond = true;
    final telemetry = _RecordingTelemetry();
    final c = make(repo, telemetry: telemetry);
    addTearDown(c.dispose);
    c.listen(upcomingShootDetailProvider(7), (_, _) {});
    await _drain(() => !c.read(upcomingShootDetailProvider(7)).isLoading);
    final ok = await c.read(upcomingShootDetailProvider(7).notifier).accept();
    expect(ok, isFalse);
    expect(
      c.read(upcomingShootDetailProvider(7)).errorMessage,
      'Something went wrong',
    );
    expect(c.read(upcomingShootDetailProvider(7)).isSubmitting, isFalse);
    expect(telemetry.events, isEmpty);
  });
}
