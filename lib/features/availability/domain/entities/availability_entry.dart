enum AvailabilityStatus { available, shoot, none }

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
      };
}
