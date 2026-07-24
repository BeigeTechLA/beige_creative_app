import 'package:beige_creative_app/core/firebase/telemetry_client.dart';
import 'package:beige_creative_app/features/availability/domain/entities/availability_entry.dart';
import 'package:beige_creative_app/features/availability/domain/repositories/availability_repository.dart';
import 'package:beige_creative_app/features/availability/presentation/providers/availability_providers.dart';
import 'package:beige_creative_app/model_class/upcoming_shoots_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Notifier gap-fill for 6.06. The existing
/// `screens/availability_test.dart` covers ManageAvailability happy load,
/// shiftMonth, AddAvailability missing-type / happy / repo-throw. This file
/// pins what was missing: ManageAvailability refresh-failure path,
/// setFocusedDay, setFilter; AddAvailability date/time validation, mutator
/// surface (setRecurrence resets dependent fields), clearMessages.

class _FakeRepo implements AvailabilityRepository {
  bool throwOnFetch = false;
  bool throwOnCreate = false;
  int fetchCount = 0;
  int? lastMonth;
  int? lastYear;

  Map<DateTime, AvailabilityDay> events = const {};

  @override
  Future<Map<DateTime, AvailabilityDay>> fetchMonth({
    required int month,
    required int year,
  }) async {
    fetchCount++;
    lastMonth = month;
    lastYear = year;
    if (throwOnFetch) throw Exception('fetch boom');
    return events;
  }

  @override
  Future<List<UpcomingShootDatum>> fetchUpcomingShoots() async {
    if (throwOnFetch) throw Exception('fetch upcoming boom');
    return const [];
  }

  @override
  Future<void> createAvailability(AvailabilityPayload payload) async {
    if (throwOnCreate) throw Exception('create boom');
  }
}


class _StubTelemetry implements TelemetryClient {
  @override
  Future<void> setUserIdentity({
    required String userId,
    String? userRole,
    String loginMethod = 'password',
  }) async {}
  @override
  Future<void> clearUserIdentity({bool emitLogoutEvent = false}) async {}
  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {}
  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {}
}

Future<void> _drain(ProviderContainer c, bool Function() done) async {
  for (var i = 0; i < 30; i++) {
    if (done()) return;
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('ManageAvailabilityNotifier — gap-fill', () {
    test('refresh failure clears loading but keeps events empty', () async {
      final repo = _FakeRepo()..throwOnFetch = true;
      final c = ProviderContainer(
        overrides: [availabilityRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      c.listen(manageAvailabilityNotifierProvider, (_, _) {});

      await _drain(
        c,
        () => !c.read(manageAvailabilityNotifierProvider).isLoading,
      );

      final s = c.read(manageAvailabilityNotifierProvider);
      expect(s.isLoading, isFalse);
      expect(s.events, isEmpty);
    });

    test('setFocusedDay re-fetches for the new month', () async {
      final repo = _FakeRepo();
      final c = ProviderContainer(
        overrides: [availabilityRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      c.listen(manageAvailabilityNotifierProvider, (_, _) {});
      await _drain(
        c,
        () => !c.read(manageAvailabilityNotifierProvider).isLoading,
      );
      final fetchBefore = repo.fetchCount;

      c
          .read(manageAvailabilityNotifierProvider.notifier)
          .setFocusedDay(DateTime(2027, 3, 15));
      await _drain(
        c,
        () => !c.read(manageAvailabilityNotifierProvider).isLoading,
      );

      expect(repo.fetchCount, fetchBefore + 1);
      expect(repo.lastMonth, 3);
      expect(repo.lastYear, 2027);
      expect(
        c.read(manageAvailabilityNotifierProvider).focusedDay,
        DateTime(2027, 3, 15),
      );
    });

    test('setFilter updates eventFilter without re-fetching', () async {
      final repo = _FakeRepo();
      final c = ProviderContainer(
        overrides: [availabilityRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      c.listen(manageAvailabilityNotifierProvider, (_, _) {});
      await _drain(
        c,
        () => !c.read(manageAvailabilityNotifierProvider).isLoading,
      );
      final fetchBefore = repo.fetchCount;

      c
          .read(manageAvailabilityNotifierProvider.notifier)
          .setFilter('Shoots only');

      expect(
        c.read(manageAvailabilityNotifierProvider).eventFilter,
        'Shoots only',
      );
      expect(repo.fetchCount, fetchBefore);
    });
  });

  group('AddAvailabilityNotifier — gap-fill', () {
    ProviderContainer make(_FakeRepo repo) {
      return ProviderContainer(
        overrides: [
          availabilityRepositoryProvider.overrideWithValue(repo),
          telemetryClientProvider.overrideWithValue(_StubTelemetry()),
        ],
      );
    }

    test('submit rejects empty date with validation message', () async {
      final repo = _FakeRepo();
      final c = make(repo);
      addTearDown(c.dispose);

      final notifier = c.read(addAvailabilityNotifierProvider.notifier);
      notifier.setType(AvailabilityType.available);

      final ok = await notifier.submit(
        formattedDate: '',
        startTime: '09:00',
        endTime: '17:00',
        recurrenceUntil: '',
        repeatDay: '',
        notes: '',
      );

      expect(ok, isFalse);
      expect(
        c.read(addAvailabilityNotifierProvider).validationMessage,
        'Please select date',
      );
    });

    test('submit rejects empty time when not all-day', () async {
      final repo = _FakeRepo();
      final c = make(repo);
      addTearDown(c.dispose);

      final notifier = c.read(addAvailabilityNotifierProvider.notifier);
      notifier.setType(AvailabilityType.available);
      // isAllDay defaults to false → start/end required.

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
        c.read(addAvailabilityNotifierProvider).validationMessage,
        'Please select time',
      );
    });

    test('submit rejects end time before or equal to start time', () async {
      final repo = _FakeRepo();
      final c = make(repo);
      addTearDown(c.dispose);

      final notifier = c.read(addAvailabilityNotifierProvider.notifier);
      notifier.setType(AvailabilityType.available);

      final ok = await notifier.submit(
        formattedDate: '2026-06-01',
        startTime: '10:00 AM',
        endTime: '09:30 AM',
        recurrenceUntil: '',
        repeatDay: '',
        notes: '',
      );

      expect(ok, isFalse);
      expect(
        c.read(addAvailabilityNotifierProvider).validationMessage,
        'End time must be after start time',
      );
    });

    test('submit rejects end time with less than 1-hour gap', () async {
      final repo = _FakeRepo();
      final c = make(repo);
      addTearDown(c.dispose);

      final notifier = c.read(addAvailabilityNotifierProvider.notifier);
      notifier.setType(AvailabilityType.available);

      final ok = await notifier.submit(
        formattedDate: '2026-06-01',
        startTime: '10:00 AM',
        endTime: '10:30 AM',
        recurrenceUntil: '',
        repeatDay: '',
        notes: '',
      );

      expect(ok, isFalse);
      expect(
        c.read(addAvailabilityNotifierProvider).validationMessage,
        'Minimum duration between start and end time must be at least 1 hour',
      );
    });

    test('submit accepts valid time range (gap >= 1 hour)', () async {
      final repo = _FakeRepo();
      final c = make(repo);
      addTearDown(c.dispose);

      final notifier = c.read(addAvailabilityNotifierProvider.notifier);
      notifier.setType(AvailabilityType.available);

      final ok = await notifier.submit(
        formattedDate: '01/01/2030',
        startTime: '10:00 AM',
        endTime: '11:00 AM',
        recurrenceUntil: '',
        repeatDay: '',
        notes: '',
      );

      expect(ok, isTrue);
    });

    test('submit rejects start time in past when date is today', () async {
      final repo = _FakeRepo();
      final c = make(repo);
      addTearDown(c.dispose);

      final notifier = c.read(addAvailabilityNotifierProvider.notifier);
      notifier.setType(AvailabilityType.available);

      final now = DateTime.now();
      final todayStr =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      final ok = await notifier.submit(
        formattedDate: todayStr,
        startTime: '00:01 AM',
        endTime: '02:00 AM',
        recurrenceUntil: '',
        repeatDay: '',
        notes: '',
      );

      expect(ok, isFalse);
      expect(
        c.read(addAvailabilityNotifierProvider).validationMessage,
        'Start time cannot be in the past',
      );
    });

    test('setRecurrence wipes weekday + weekend selections', () {
      final repo = _FakeRepo();
      final c = make(repo);
      addTearDown(c.dispose);

      final notifier = c.read(addAvailabilityNotifierProvider.notifier);
      notifier.setType(AvailabilityType.available);
      notifier.toggleAllDay(true);
      notifier.setRecurrence(RecurrenceKind.weekly);
      notifier.toggleWeekDay('Mon');
      notifier.toggleIncludeWeekends(true);
      expect(
        c.read(addAvailabilityNotifierProvider).selectedWeekDays,
        ['Mon'],
      );
      expect(
        c.read(addAvailabilityNotifierProvider).includeWeekends,
        isTrue,
      );

      notifier.setRecurrence(RecurrenceKind.daily);

      final s = c.read(addAvailabilityNotifierProvider);
      expect(s.recurrence, RecurrenceKind.daily);
      expect(s.selectedWeekDays, isEmpty);
      expect(s.includeWeekends, isFalse);
      // type + isAllDay are preserved across the reset.
      expect(s.type, AvailabilityType.available);
      expect(s.isAllDay, isTrue);
    });

    test('toggleWeekDay adds then removes the same day', () {
      final repo = _FakeRepo();
      final c = make(repo);
      addTearDown(c.dispose);

      final notifier = c.read(addAvailabilityNotifierProvider.notifier);
      notifier.toggleWeekDay('Fri');
      expect(
        c.read(addAvailabilityNotifierProvider).selectedWeekDays,
        ['Fri'],
      );
      notifier.toggleWeekDay('Fri');
      expect(
        c.read(addAvailabilityNotifierProvider).selectedWeekDays,
        isEmpty,
      );
    });

    test('clearMessages wipes validation + error in one shot', () async {
      final repo = _FakeRepo();
      final c = make(repo);
      addTearDown(c.dispose);

      final notifier = c.read(addAvailabilityNotifierProvider.notifier);
      // Force a validation message via missing type.
      await notifier.submit(
        formattedDate: '2026-06-01',
        startTime: '09:00',
        endTime: '17:00',
        recurrenceUntil: '',
        repeatDay: '',
        notes: '',
      );
      expect(
        c.read(addAvailabilityNotifierProvider).validationMessage,
        isNotNull,
      );

      notifier.clearMessages();

      final s = c.read(addAvailabilityNotifierProvider);
      expect(s.validationMessage, isNull);
      expect(s.errorMessage, isNull);
    });

    test('daily recurrence sends Mon-Fri when weekends excluded', () async {
      final repo = _FakeRepo();
      final c = make(repo);
      addTearDown(c.dispose);

      final notifier = c.read(addAvailabilityNotifierProvider.notifier);
      notifier.setType(AvailabilityType.available);
      notifier.toggleAllDay(true);
      notifier.setRecurrence(RecurrenceKind.daily);

      final ok = await notifier.submit(
        formattedDate: '2026-06-01',
        startTime: '',
        endTime: '',
        recurrenceUntil: '2026-06-05',
        repeatDay: '',
        notes: '',
      );

      expect(ok, isTrue);
    });

    test('submit rejects recurring availability when recurrenceUntil is empty', () async {
      final repo = _FakeRepo();
      final c = make(repo);
      addTearDown(c.dispose);

      final notifier = c.read(addAvailabilityNotifierProvider.notifier);
      notifier.setType(AvailabilityType.available);
      notifier.toggleAllDay(true);
      notifier.setRecurrence(RecurrenceKind.daily);

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
        c.read(addAvailabilityNotifierProvider).validationMessage,
        'Until date is required for recurring availability',
      );
    });

    test('submit rejects weekly recurrence when selectedWeekDays is empty', () async {
      final repo = _FakeRepo();
      final c = make(repo);
      addTearDown(c.dispose);

      final notifier = c.read(addAvailabilityNotifierProvider.notifier);
      notifier.setType(AvailabilityType.available);
      notifier.toggleAllDay(true);
      notifier.setRecurrence(RecurrenceKind.weekly);

      final ok = await notifier.submit(
        formattedDate: '2026-06-01',
        startTime: '',
        endTime: '',
        recurrenceUntil: '2026-06-30',
        repeatDay: '',
        notes: '',
      );

      expect(ok, isFalse);
      expect(
        c.read(addAvailabilityNotifierProvider).validationMessage,
        'Please select at least one day for weekly recurrence',
      );
    });

    test('submit rejects monthly recurrence when repeatDay is invalid', () async {
      final repo = _FakeRepo();
      final c = make(repo);
      addTearDown(c.dispose);

      final notifier = c.read(addAvailabilityNotifierProvider.notifier);
      notifier.setType(AvailabilityType.available);
      notifier.toggleAllDay(true);
      notifier.setRecurrence(RecurrenceKind.monthly);

      // Empty repeatDay
      var ok = await notifier.submit(
        formattedDate: '2026-06-01',
        startTime: '',
        endTime: '',
        recurrenceUntil: '2026-12-31',
        repeatDay: '',
        notes: '',
      );
      expect(ok, isFalse);
      expect(
        c.read(addAvailabilityNotifierProvider).validationMessage,
        'Repeat day of month is required',
      );

      // Out of range repeatDay (32)
      ok = await notifier.submit(
        formattedDate: '2026-06-01',
        startTime: '',
        endTime: '',
        recurrenceUntil: '2026-12-31',
        repeatDay: '32',
        notes: '',
      );
      expect(ok, isFalse);
      expect(
        c.read(addAvailabilityNotifierProvider).validationMessage,
        'Repeat day of month must be between 1 and 31',
      );
    });

    test('submit accepts monthly recurrence with valid repeatDay between 1 and 31', () async {
      final repo = _FakeRepo();
      final c = make(repo);
      addTearDown(c.dispose);

      final notifier = c.read(addAvailabilityNotifierProvider.notifier);
      notifier.setType(AvailabilityType.available);
      notifier.toggleAllDay(true);
      notifier.setRecurrence(RecurrenceKind.monthly);

      final ok = await notifier.submit(
        formattedDate: '2026-06-01',
        startTime: '',
        endTime: '',
        recurrenceUntil: '2026-12-31',
        repeatDay: '15',
        notes: '',
      );

      expect(ok, isTrue);
    });
  });
}
