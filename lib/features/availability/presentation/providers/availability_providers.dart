import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/repositories/availability_repository_impl.dart';
import '../../domain/entities/availability_entry.dart';
import '../../domain/repositories/availability_repository.dart';

final availabilityRepositoryProvider = Provider<AvailabilityRepository>(
  (ref) => AvailabilityRepositoryImpl(ref.read(dioClientProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// Manage Availability — month-scoped calendar of statuses + filter.
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class ManageAvailabilityState {
  final DateTime focusedDay;
  final Map<DateTime, AvailabilityStatus> events;
  final String eventFilter;
  final bool isLoading;

  ManageAvailabilityState({
    DateTime? focusedDay,
    this.events = const {},
    this.eventFilter = 'All Events',
    this.isLoading = true,
  }) : focusedDay = focusedDay ?? DateTime.now();

  ManageAvailabilityState copyWith({
    DateTime? focusedDay,
    Map<DateTime, AvailabilityStatus>? events,
    String? eventFilter,
    bool? isLoading,
  }) {
    return ManageAvailabilityState(
      focusedDay: focusedDay ?? this.focusedDay,
      events: events ?? this.events,
      eventFilter: eventFilter ?? this.eventFilter,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int countOf(AvailabilityStatus status) {
    return events.entries
        .where((e) =>
            e.key.year == focusedDay.year &&
            e.key.month == focusedDay.month &&
            e.value == status)
        .length;
  }

  int get availableDaysCount => countOf(AvailabilityStatus.available);
  int get shootDaysCount => countOf(AvailabilityStatus.shoot);
}

class ManageAvailabilityNotifier
    extends AutoDisposeNotifier<ManageAvailabilityState> {
  @override
  ManageAvailabilityState build() {
    Future.microtask(refresh);
    return ManageAvailabilityState();
  }

  Future<void> refresh() async {
    final repo = ref.read(availabilityRepositoryProvider);
    final day = state.focusedDay;
    try {
      final events =
          await repo.fetchMonth(month: day.month, year: day.year);
      state = state.copyWith(events: events, isLoading: false);
    } catch (e, st) {
      AppLogger.e('ManageAvailability.refresh failed', e, st);
      state = state.copyWith(isLoading: false);
    }
  }

  void shiftMonth(int delta) {
    final next = DateTime(state.focusedDay.year, state.focusedDay.month + delta);
    state = state.copyWith(focusedDay: next, isLoading: true);
    refresh();
  }

  void setFocusedDay(DateTime day) {
    state = state.copyWith(focusedDay: day, isLoading: true);
    refresh();
  }

  void setFilter(String value) {
    state = state.copyWith(eventFilter: value);
  }
}

final manageAvailabilityNotifierProvider = AutoDisposeNotifierProvider<
    ManageAvailabilityNotifier, ManageAvailabilityState>(
  ManageAvailabilityNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// Add Availability — form state + submit.
// ─────────────────────────────────────────────────────────────────────────────

enum AvailabilityType { available, notAvailable }

enum RecurrenceKind { daily, weekly, monthly, doesNotRepeat }

@immutable
class AddAvailabilityState {
  final AvailabilityType? type;
  final RecurrenceKind? recurrence;
  final bool includeWeekends;
  final bool isAllDay;
  final List<String> selectedWeekDays;
  final bool isSubmitting;
  final bool submittedOk;
  final String? errorMessage;
  final String? validationMessage;

  const AddAvailabilityState({
    this.type,
    this.recurrence,
    this.includeWeekends = false,
    this.isAllDay = false,
    this.selectedWeekDays = const [],
    this.isSubmitting = false,
    this.submittedOk = false,
    this.errorMessage,
    this.validationMessage,
  });

  AddAvailabilityState copyWith({
    AvailabilityType? type,
    RecurrenceKind? recurrence,
    bool? includeWeekends,
    bool? isAllDay,
    List<String>? selectedWeekDays,
    bool? isSubmitting,
    bool? submittedOk,
    String? errorMessage,
    String? validationMessage,
    bool clearMessages = false,
  }) {
    return AddAvailabilityState(
      type: type ?? this.type,
      recurrence: recurrence ?? this.recurrence,
      includeWeekends: includeWeekends ?? this.includeWeekends,
      isAllDay: isAllDay ?? this.isAllDay,
      selectedWeekDays: selectedWeekDays ?? this.selectedWeekDays,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submittedOk: submittedOk ?? this.submittedOk,
      errorMessage:
          clearMessages ? null : (errorMessage ?? this.errorMessage),
      validationMessage:
          clearMessages ? null : (validationMessage ?? this.validationMessage),
    );
  }
}

class AddAvailabilityNotifier
    extends AutoDisposeNotifier<AddAvailabilityState> {
  @override
  AddAvailabilityState build() => const AddAvailabilityState();

  void setType(AvailabilityType? value) =>
      state = state.copyWith(type: value, clearMessages: true);

  void setRecurrence(RecurrenceKind? value) {
    state = AddAvailabilityState(
      type: state.type,
      recurrence: value,
      isAllDay: state.isAllDay,
      includeWeekends: false,
      selectedWeekDays: const [],
    );
  }

  void toggleAllDay(bool value) =>
      state = state.copyWith(isAllDay: value, clearMessages: true);

  void toggleIncludeWeekends(bool value) =>
      state = state.copyWith(includeWeekends: value);

  void toggleWeekDay(String day) {
    final updated = [...state.selectedWeekDays];
    if (updated.contains(day)) {
      updated.remove(day);
    } else {
      updated.add(day);
    }
    state = state.copyWith(selectedWeekDays: updated);
  }

  void clearMessages() =>
      state = state.copyWith(clearMessages: true);

  List<String>? _recurrenceDays() {
    switch (state.recurrence) {
      case RecurrenceKind.weekly:
        return state.selectedWeekDays.map((d) => d.toLowerCase()).toList();
      case RecurrenceKind.daily:
        return state.includeWeekends
            ? const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
            : const ['mon', 'tue', 'wed', 'thu', 'fri'];
      case RecurrenceKind.monthly:
      case RecurrenceKind.doesNotRepeat:
      case null:
        return null;
    }
  }

  int _recurrenceInt() {
    switch (state.recurrence) {
      case RecurrenceKind.daily:
        return 2;
      case RecurrenceKind.weekly:
        return 3;
      case RecurrenceKind.monthly:
        return 4;
      case RecurrenceKind.doesNotRepeat:
      case null:
        return 1;
    }
  }

  /// Returns true on success, false on validation/network failure.
  /// `lastError` / `validationMessage` carry detail.
  Future<bool> submit({
    required String formattedDate,
    required String startTime,
    required String endTime,
    required String recurrenceUntil,
    required String repeatDay,
    required String notes,
  }) async {
    if (state.type == null) {
      state = state.copyWith(validationMessage: 'Please select type');
      return false;
    }
    if (formattedDate.isEmpty) {
      state = state.copyWith(validationMessage: 'Please select date');
      return false;
    }
    if (!state.isAllDay && (startTime.isEmpty || endTime.isEmpty)) {
      state = state.copyWith(validationMessage: 'Please select time');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearMessages: true);
    final payload = AvailabilityPayload(
      date: formattedDate,
      availabilityStatus: state.type == AvailabilityType.available ? 1 : 2,
      isFullDay: state.isAllDay ? 1 : 0,
      startTime: state.isAllDay ? '' : startTime,
      endTime: state.isAllDay ? '' : endTime,
      recurrence: _recurrenceInt(),
      notes: notes.trim(),
      recurrenceUntil: recurrenceUntil,
      recurrenceDays: _recurrenceDays(),
      repeatDay: repeatDay.isEmpty ? null : repeatDay,
    );

    try {
      await ref
          .read(availabilityRepositoryProvider)
          .createAvailability(payload);
      state = state.copyWith(isSubmitting: false, submittedOk: true);
      return true;
    } catch (e, st) {
      AppLogger.e('AddAvailability.submit failed', e, st);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
}

final addAvailabilityNotifierProvider = AutoDisposeNotifierProvider<
    AddAvailabilityNotifier, AddAvailabilityState>(
  AddAvailabilityNotifier.new,
);
