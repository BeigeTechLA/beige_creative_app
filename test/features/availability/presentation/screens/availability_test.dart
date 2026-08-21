import 'package:beige_creative_app/core/firebase/analytics_events.dart';
import 'package:beige_creative_app/core/firebase/crashlytics_breadcrumbs.dart';
import 'package:beige_creative_app/core/firebase/crashlytics_keys.dart';
import 'package:beige_creative_app/core/firebase/telemetry_client.dart';
import 'package:beige_creative_app/features/availability/domain/entities/availability_entry.dart';
import 'package:beige_creative_app/features/availability/domain/repositories/availability_repository.dart';
import 'package:beige_creative_app/features/availability/presentation/providers/availability_providers.dart';
import 'package:beige_creative_app/model_class/upcoming_shoots_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements AvailabilityRepository {
  bool createCalled = false;
  AvailabilityPayload? lastPayload;
  bool throwOnCreate = false;

  @override
  Future<Map<DateTime, AvailabilityDay>> fetchMonth({
    required int month,
    required int year,
  }) async {
    return {
      DateTime(year, month, 5):
          const AvailabilityDay(status: AvailabilityStatus.available),
      DateTime(year, month, 12):
          const AvailabilityDay(status: AvailabilityStatus.shoot, bookingId: 12),
      DateTime(year, month, 14):
          const AvailabilityDay(status: AvailabilityStatus.available),
    };
  }

  @override
  Future<List<UpcomingShootDatum>> fetchUpcomingShoots() async {
    return const [];
  }

  @override
  Future<void> createAvailability(AvailabilityPayload payload) async {
    createCalled = true;
    lastPayload = payload;
    if (throwOnCreate) throw Exception('boom');
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

void main() {
  final keys = <({String key, Object value})>[];
  final logs = <String>[];

  setUp(() {
    keys.clear();
    logs.clear();
    CrashlyticsBreadcrumbs.setCustomKey = (key, value) async {
      keys.add((key: key, value: value));
    };
    CrashlyticsBreadcrumbs.log = (message) async {
      logs.add(message);
    };
  });

  tearDown(CrashlyticsBreadcrumbs.resetForTesting);

  group('ManageAvailabilityNotifier', () {
    test('loads month and exposes count getters', () async {
      final container = ProviderContainer(
        overrides: [
          availabilityRepositoryProvider.overrideWithValue(_FakeRepo()),
        ],
      );
      addTearDown(container.dispose);
      final sub = container.listen<ManageAvailabilityState>(
        manageAvailabilityNotifierProvider,
        (_, _) {},
      );
      addTearDown(sub.close);

      for (var i = 0; i < 20; i++) {
        if (!container.read(manageAvailabilityNotifierProvider).isLoading) {
          break;
        }
        await Future<void>.delayed(Duration.zero);
      }

      final state = container.read(manageAvailabilityNotifierProvider);
      expect(state.isLoading, isFalse);
      expect(state.availableDaysCount, 2);
      expect(state.shootDaysCount, 1);
    });

    test('shiftMonth updates focused day + reloads', () async {
      final container = ProviderContainer(
        overrides: [
          availabilityRepositoryProvider.overrideWithValue(_FakeRepo()),
        ],
      );
      addTearDown(container.dispose);
      final sub = container.listen<ManageAvailabilityState>(
        manageAvailabilityNotifierProvider,
        (_, _) {},
      );
      addTearDown(sub.close);

      for (var i = 0; i < 20; i++) {
        if (!container.read(manageAvailabilityNotifierProvider).isLoading) {
          break;
        }
        await Future<void>.delayed(Duration.zero);
      }

      final notifier = container.read(
        manageAvailabilityNotifierProvider.notifier,
      );
      final beforeMonth = container
          .read(manageAvailabilityNotifierProvider)
          .focusedDay
          .month;
      notifier.shiftMonth(1);
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      final after = container
          .read(manageAvailabilityNotifierProvider)
          .focusedDay;
      expect(after.month, isNot(beforeMonth));
    });
  });

  group('AddAvailabilityNotifier', () {
    test('submit rejects when type missing', () async {
      final repo = _FakeRepo();
      final telemetry = _RecordingTelemetry();
      final container = ProviderContainer(
        overrides: [
          availabilityRepositoryProvider.overrideWithValue(repo),
          telemetryClientProvider.overrideWithValue(telemetry),
        ],
      );
      addTearDown(container.dispose);

      final ok = await container
          .read(addAvailabilityNotifierProvider.notifier)
          .submit(
            formattedDate: '2026-06-01',
            startTime: '',
            endTime: '',
            recurrenceUntil: '',
            repeatDay: '',
            notes: '',
          );
      expect(ok, isFalse);
      expect(repo.createCalled, isFalse);
      expect(
        container.read(addAvailabilityNotifierProvider).validationMessage,
        'Please select type',
      );
      expect(
        telemetry.events.where(
          (e) => e.name == AnalyticsEvents.availabilityAdded,
        ),
        isEmpty,
      );
    });

    test('submit posts payload when all-day + type set', () async {
      final repo = _FakeRepo();
      final telemetry = _RecordingTelemetry();
      final container = ProviderContainer(
        overrides: [
          availabilityRepositoryProvider.overrideWithValue(repo),
          telemetryClientProvider.overrideWithValue(telemetry),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(addAvailabilityNotifierProvider.notifier);
      notifier.setType(AvailabilityType.available);
      notifier.toggleAllDay(true);
      notifier.setRecurrence(RecurrenceKind.weekly);
      notifier.toggleWeekDay('Mon');
      notifier.toggleWeekDay('Wed');

      final ok = await notifier.submit(
        formattedDate: '2026-06-01',
        startTime: '',
        endTime: '',
        recurrenceUntil: '2026-06-07',
        repeatDay: '',
        notes: '  hello  ',
      );

      expect(ok, isTrue);
      expect(repo.createCalled, isTrue);
      expect(repo.lastPayload!.availabilityStatus, 1);
      expect(repo.lastPayload!.isFullDay, 1);
      expect(repo.lastPayload!.recurrence, 3);
      expect(repo.lastPayload!.recurrenceDays, ['mon', 'wed']);
      expect(repo.lastPayload!.notes, 'hello');
      expect(
        container.read(addAvailabilityNotifierProvider).submittedOk,
        isTrue,
      );
      final hits = telemetry.events
          .where((e) => e.name == AnalyticsEvents.availabilityAdded)
          .toList();
      expect(hits, hasLength(1));
      expect(hits.single.parameters, {'duration_days': 7});

      expect(keys, [
        (key: CrashlyticsKeys.featureArea, value: 'availability.add'),
      ]);
      expect(logs, [
        'availability.add.start days=7',
        'availability.add.success days=7',
      ]);
    });

    test('submit surfaces error on repo throw', () async {
      final repo = _FakeRepo()..throwOnCreate = true;
      final telemetry = _RecordingTelemetry();
      final container = ProviderContainer(
        overrides: [
          availabilityRepositoryProvider.overrideWithValue(repo),
          telemetryClientProvider.overrideWithValue(telemetry),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(addAvailabilityNotifierProvider.notifier);
      notifier.setType(AvailabilityType.notAvailable);
      notifier.toggleAllDay(true);

      final ok = await notifier.submit(
        formattedDate: '2026-06-01',
        startTime: '',
        endTime: '',
        recurrenceUntil: '',
        repeatDay: '',
        notes: '',
      );
      expect(ok, isFalse);
      expect(
        container.read(addAvailabilityNotifierProvider).errorMessage,
        contains('boom'),
      );
      expect(
        telemetry.events.where(
          (e) => e.name == AnalyticsEvents.availabilityAdded,
        ),
        isEmpty,
      );

      expect(keys, [
        (key: CrashlyticsKeys.featureArea, value: 'availability.add'),
      ]);
      expect(logs, [
        'availability.add.start days=1',
        'availability.add.failure days=1',
      ]);
    });
  });
}
