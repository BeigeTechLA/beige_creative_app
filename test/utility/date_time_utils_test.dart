import 'package:flutter_test/flutter_test.dart';
import 'package:beige_creative_app/utility/date_time_utils.dart';

void main() {
  group('month-first date input', () {
    test('formats a date as MM/dd/yyyy', () {
      expect(
        DateTimeUtils.formatMonthFirstDateInput(DateTime(2026, 5, 9)),
        '05/09/2026',
      );
    });

    test('parses MM/dd/yyyy back to the same calendar date', () {
      expect(
        DateTimeUtils.parseMonthFirstDateInput('05/09/2026'),
        DateTime(2026, 5, 9),
      );
    });

    test('returns null for a day-first or invalid date', () {
      expect(DateTimeUtils.parseMonthFirstDateInput('19/05/2026'), isNull);
      expect(DateTimeUtils.parseMonthFirstDateInput('02/30/2026'), isNull);
    });
  });

  group('DateTimeUtils.isActionableBeforeOneHour', () {
    final eventDate = DateTime(2026, 7, 20);
    const startTime = "18:00:00"; // 6:00 PM

    test('returns true when current time is more than 1 hour before start time', () {
      final now = DateTime(2026, 7, 20, 16, 30); // 4:30 PM (1.5 hours before 6 PM)
      final actionable = DateTimeUtils.isActionableBeforeOneHour(
        eventDate: eventDate,
        startTime: startTime,
        status: 'pending',
        crewAccept: 0,
        now: now,
      );
      expect(actionable, isTrue);
    });

    test('returns false when current time is within 1 hour of start time', () {
      final now = DateTime(2026, 7, 20, 17, 15); // 5:15 PM (45 mins before 6 PM)
      final actionable = DateTimeUtils.isActionableBeforeOneHour(
        eventDate: eventDate,
        startTime: startTime,
        status: 'pending',
        crewAccept: 0,
        now: now,
      );
      expect(actionable, isFalse);
    });

    test('returns false when shoot is already confirmed/accepted', () {
      final now = DateTime(2026, 7, 20, 14, 00); // 4 hours before 6 PM
      final actionable = DateTimeUtils.isActionableBeforeOneHour(
        eventDate: eventDate,
        startTime: startTime,
        status: 'confirmed',
        crewAccept: 1,
        now: now,
      );
      expect(actionable, isFalse);
    });
  });
}
