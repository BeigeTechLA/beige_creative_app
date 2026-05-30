import 'package:beige_creative_app/features/availability/domain/entities/availability_entry.dart';
import 'package:beige_creative_app/features/availability/domain/repositories/availability_repository.dart';
import 'package:beige_creative_app/features/availability/presentation/providers/availability_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements AvailabilityRepository {
  bool createCalled = false;
  AvailabilityPayload? lastPayload;
  bool throwOnCreate = false;

  @override
  Future<Map<DateTime, AvailabilityStatus>> fetchMonth({
    required int month,
    required int year,
  }) async {
    return {
      DateTime(year, month, 5): AvailabilityStatus.available,
      DateTime(year, month, 12): AvailabilityStatus.shoot,
      DateTime(year, month, 14): AvailabilityStatus.available,
    };
  }

  @override
  Future<void> createAvailability(AvailabilityPayload payload) async {
    createCalled = true;
    lastPayload = payload;
    if (throwOnCreate) throw Exception('boom');
  }
}

void main() {
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
        if (!container
            .read(manageAvailabilityNotifierProvider)
            .isLoading) {
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
        if (!container
            .read(manageAvailabilityNotifierProvider)
            .isLoading) {
          break;
        }
        await Future<void>.delayed(Duration.zero);
      }

      final notifier =
          container.read(manageAvailabilityNotifierProvider.notifier);
      final beforeMonth =
          container.read(manageAvailabilityNotifierProvider).focusedDay.month;
      notifier.shiftMonth(1);
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      final after =
          container.read(manageAvailabilityNotifierProvider).focusedDay;
      expect(after.month, isNot(beforeMonth));
    });
  });

  group('AddAvailabilityNotifier', () {
    test('submit rejects when type missing', () async {
      final repo = _FakeRepo();
      final container = ProviderContainer(
        overrides: [
          availabilityRepositoryProvider.overrideWithValue(repo),
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
    });

    test('submit posts payload when all-day + type set', () async {
      final repo = _FakeRepo();
      final container = ProviderContainer(
        overrides: [
          availabilityRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier =
          container.read(addAvailabilityNotifierProvider.notifier);
      notifier.setType(AvailabilityType.available);
      notifier.toggleAllDay(true);
      notifier.setRecurrence(RecurrenceKind.weekly);
      notifier.toggleWeekDay('Mon');
      notifier.toggleWeekDay('Wed');

      final ok = await notifier.submit(
        formattedDate: '2026-06-01',
        startTime: '',
        endTime: '',
        recurrenceUntil: '2026-12-31',
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
    });

    test('submit surfaces error on repo throw', () async {
      final repo = _FakeRepo()..throwOnCreate = true;
      final container = ProviderContainer(
        overrides: [
          availabilityRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier =
          container.read(addAvailabilityNotifierProvider.notifier);
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
    });
  });
}
