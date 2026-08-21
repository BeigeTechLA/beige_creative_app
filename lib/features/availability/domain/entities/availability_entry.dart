enum AvailabilityStatus { available, shoot, unavailable, none }

/// A calendar day's status plus, when [status] is `shoot`, the booking id
/// (`projectDetails.booking_id` in the `creator/availability` response) so
/// the UI can deep-link straight to that shoot's details without a second
/// lookup.
class AvailabilityDay {
  final AvailabilityStatus status;
  final int? bookingId;
  final String? startTime;
  final String? endTime;
  final bool isFullDay;

  const AvailabilityDay({
    required this.status,
    this.bookingId,
    this.startTime,
    this.endTime,
    this.isFullDay = false,
  });

  @override
  bool operator ==(Object other) =>
      other is AvailabilityDay &&
      other.status == status &&
      other.bookingId == bookingId &&
      other.startTime == startTime &&
      other.endTime == endTime &&
      other.isFullDay == isFullDay;

  @override
  int get hashCode => Object.hash(status, bookingId, startTime, endTime, isFullDay);
}

class AvailabilityPayload {
  final String date;
  final int availabilityStatus;
  final int isFullDay;
  final String startTime;
  final String endTime;
  final int recurrence;
  final String notes;
  final String recurrenceUntil;
  final List<String>? recurrenceDays;
  final String? repeatDay;

  const AvailabilityPayload({
    required this.date,
    required this.availabilityStatus,
    required this.isFullDay,
    required this.startTime,
    required this.endTime,
    required this.recurrence,
    required this.notes,
    required this.recurrenceUntil,
    required this.recurrenceDays,
    this.repeatDay,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'availability_status': availabilityStatus,
        'is_full_day': isFullDay,
        'start_time': startTime,
        'end_time': endTime,
        'recurrence': recurrence,
        'notes': notes,
        'recurrence_until': recurrenceUntil,
        'recurrence_days': recurrenceDays,
        if (repeatDay != null && repeatDay!.isNotEmpty)
          'recurrence_day_of_month': int.tryParse(repeatDay!) ?? repeatDay,
      };
}
