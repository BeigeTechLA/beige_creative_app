import '../../../../model_class/upcoming_shoots_model.dart';
import '../entities/availability_entry.dart';

abstract class AvailabilityRepository {
  /// Returns a date→day-info map for the given month/year. Dates with
  /// neither `projectAssigned` nor `available` flags are omitted.
  Future<Map<DateTime, AvailabilityDay>> fetchMonth({
    required int month,
    required int year,
  });

  /// Submits a new availability entry. Throws on non-2xx (callers map to
  /// user-visible error via the notifier).
  Future<void> createAvailability(AvailabilityPayload payload);

  /// GET `creator/upcoming-shoots`. Returns upcoming shoots list.
  Future<List<UpcomingShootDatum>> fetchUpcomingShoots();
}

