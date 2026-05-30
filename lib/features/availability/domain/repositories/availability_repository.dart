import '../entities/availability_entry.dart';

abstract class AvailabilityRepository {
  /// Returns a date→status map for the given month/year. Dates with neither
  /// `projectAssigned` nor `available` flags are omitted.
  Future<Map<DateTime, AvailabilityStatus>> fetchMonth({
    required int month,
    required int year,
  });

  /// Submits a new availability entry. Throws on non-2xx (callers map to
  /// user-visible error via the notifier).
  Future<void> createAvailability(AvailabilityPayload payload);
}
