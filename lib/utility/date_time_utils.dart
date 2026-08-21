import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeUtils {
  // ───────────────────────────────────────────────────────────────
  // Format pattern constants (single source of truth).
  // ───────────────────────────────────────────────────────────────

  /// `05-19-2026`
  static const String kDatePattern = "MM-dd-yyyy";

  /// `May 19, 2026`
  static const String kReadableDatePattern = "MMM dd, yyyy";

  /// `Tue, 19 May 2026`
  static const String kWeekdayDatePattern = "EEE, dd MMM yyyy";

  /// `Tue, 19 May • 09:00 AM`
  static const String kTimelineDateTimePattern = "EEE, dd MMM • hh:mm a";

  /// `May 19, 2026`
  static const String kFullMonthDatePattern = "MMMM dd, yyyy";

  /// `May 2026`
  static const String kMonthYearPattern = "MMM yyyy";

  /// `May 2026` — full month name.
  static const String kFullMonthYearPattern = "MMMM yyyy";

  /// `Tue`
  static const String kWeekdayShortPattern = "EEE";

  /// `09:00:00` — API/parse input.
  static const String kTime24HmsPattern = "HH:mm:ss";

  /// `09:00` — API/parse input.
  static const String kTime24HmPattern = "HH:mm";

  /// `09:00 AM`
  static const String kTime12HourPattern = "hh:mm a";

  /// `9:00 AM`
  static const String kTime12HourShortPattern = "h:mm a";

  /// `19` — day-of-month only.
  static const String kDayOfMonthPattern = "d";

  /// `May` — month only.
  static const String kMonthShortPattern = "MMM";

  /// `2026` — year only.
  static const String kYearPattern = "yyyy";

  /// `May 19` — month + day (range start).
  static const String kMonthDayPattern = "MMM d";

  /// `05-19-2026 09:00 AM`
  static const String kDateTimePattern = "MM-dd-yyyy hh:mm a";

  /// `May 19, 2026 9:00 AM` — readable date + time (replaces old DateTimeUtils.formatDateTime shape).
  static const String kReadableDateTimePattern = "MMM dd, yyyy h:mm a";

  /// `19/05/2026` — date picker input (non-US, day-first). Intentional.
  static const String kDatePickerInputPattern = "dd/MM/yyyy";

  /// `05/19/2026` — month-first date input.
  static const String kMonthFirstDateInputPattern = "MM/dd/yyyy";

  // ───────────────────────────────────────────────────────────────

  /// ✅ Format Date → MM-dd-yyyy
  static String formatDate(String? date, {String fallback = "--"}) {
    try {
      if (date == null || date.isEmpty) return fallback;

      final parsed = DateTime.parse(date).toLocal();
      return formatDateValue(parsed, fallback: fallback);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format DateTime → MM-dd-yyyy
  static String formatDateValue(DateTime? date, {String fallback = "--"}) {
    try {
      if (date == null) return fallback;

      return DateFormat(kDatePattern).format(date);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Date → May 19, 2026
  static String formatReadableDate(String? date, {String fallback = "--"}) {
    try {
      if (date == null || date.isEmpty) return fallback;

      final parsed = DateTime.parse(date).toLocal();
      return DateFormat(kReadableDatePattern).format(parsed);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Date → Tue, 19 May 2026
  static String formatWeekdayDate(String? date, {String fallback = "--"}) {
    try {
      if (date == null || date.isEmpty) return fallback;

      final parsed = DateTime.parse(date).toLocal();
      return DateFormat(kWeekdayDatePattern).format(parsed);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Date Time → Tue, 19 May • 09:00 AM
  static String formatTimelineDateTime(
    String? isoTime, {
    String fallback = "--",
  }) {
    try {
      if (isoTime == null || isoTime.isEmpty) return fallback;

      final parsed = DateTime.parse(isoTime).toLocal();
      return DateFormat(kTimelineDateTimePattern).format(parsed);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Date → May 19, 2026
  static String formatFullMonthDate(DateTime? date, {String fallback = "--"}) {
    try {
      if (date == null) return fallback;

      return DateFormat(kFullMonthDatePattern).format(date);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Date → May 2026
  static String formatMonthYear(DateTime? date, {String fallback = "--"}) {
    try {
      if (date == null) return fallback;

      return DateFormat(kMonthYearPattern).format(date);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Date → May 2026 (full month name)
  static String formatFullMonthYear(DateTime? date, {String fallback = "--"}) {
    try {
      if (date == null) return fallback;

      return DateFormat(kFullMonthYearPattern).format(date);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Date → Tue
  static String formatWeekdayShort(DateTime? date, {String fallback = "--"}) {
    try {
      if (date == null) return fallback;

      return DateFormat(kWeekdayShortPattern).format(date);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Time → 09:00 AM
  static String formatTime(String? time, {String fallback = "--"}) {
    try {
      if (time == null || time.isEmpty) return fallback;

      DateTime parsed;

      /// 🔥 CASE 1: HH:mm:ss (normal API)
      if (time.contains(":") && time.length == 8) {
        parsed = DateFormat(kTime24HmsPattern).parse(time);
      }
      /// 🔥 CASE 2: HH:mm (sometimes API gives this)
      else if (time.contains(":") && time.length == 5) {
        parsed = DateFormat(kTime24HmPattern).parse(time);
      }
      /// 🔥 CASE 3: already ISO format
      else {
        parsed = DateTime.parse(time).toLocal();
      }

      return DateFormat(kTime12HourPattern).format(parsed);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Time without leading zero → 9:00 AM
  static String formatTimeWithoutLeadingZero(
    String? time, {
    String fallback = "",
  }) {
    try {
      final formatted = formatTime(time, fallback: fallback);
      if (formatted == fallback) return fallback;

      return formatted.startsWith("0") ? formatted.substring(1) : formatted;
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format TimeOfDay (locale-aware) → 9:00 AM
  static String formatTimeOfDay(
    BuildContext context,
    TimeOfDay? time, {
    String fallback = "",
  }) {
    try {
      if (time == null) return fallback;

      return time.format(context);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format TimeOfDay short → 9:00 AM
  static String formatTimeOfDayShort(
    TimeOfDay? time, {
    String fallback = "--",
  }) {
    try {
      if (time == null) return fallback;

      return DateFormat(
        kTime12HourShortPattern,
      ).format(DateTime(2000, 1, 1, time.hour, time.minute));
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format TimeOfDay 12-hour with leading zero → 09:00 AM
  static String formatTimeOfDay12Hour(
    TimeOfDay? time, {
    String fallback = "--",
  }) {
    try {
      if (time == null) return fallback;

      return DateFormat(
        kTime12HourPattern,
      ).format(DateTime(2000, 1, 1, time.hour, time.minute));
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Duration → 2h 30m
  static String formatDuration(double? hours, {String fallback = "--"}) {
    try {
      if (hours == null || hours.isNaN || hours.isInfinite) return fallback;

      int h = hours.floor();
      int m = ((hours - h) * 60).round();

      if (m == 60) {
        h += 1;
        m = 0;
      }

      if (m == 0) return "${h}h";

      return "${h}h ${m}m";
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format API date payload → 2026-05-19
  static String formatApiDate(DateTime? date, {String fallback = "--"}) {
    try {
      if (date == null) return fallback;

      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format API time payload → 09:00:00
  static String formatApiTime(TimeOfDay? time, {String fallback = "--"}) {
    try {
      if (time == null) return fallback;

      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return "$hour:$minute:00";
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Date picker input format → 19/05/2026 (dd/MM/yyyy, non-US, intentional)
  static String formatDatePickerInput(
    DateTime? date, {
    String fallback = "",
  }) {
    try {
      if (date == null) return fallback;

      return DateFormat(kDatePickerInputPattern).format(date);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Parse date picker input → DateTime (or null on bad input)
  static DateTime? parseDatePickerInput(String? input) {
    try {
      if (input == null || input.isEmpty) return null;

      return DateFormat(kDatePickerInputPattern).parse(input);
    } catch (_) {
      return null;
    }
  }

  /// ✅ Month-first date input format → 05/19/2026
  static String formatMonthFirstDateInput(
    DateTime? date, {
    String fallback = "",
  }) {
    try {
      if (date == null) return fallback;

      return DateFormat(kMonthFirstDateInputPattern).format(date);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Parse month-first date input → DateTime (or null on bad input)
  static DateTime? parseMonthFirstDateInput(String? input) {
    try {
      if (input == null || input.isEmpty) return null;

      return DateFormat(kMonthFirstDateInputPattern).parseStrict(input);
    } catch (_) {
      return null;
    }
  }

  /// ✅ Readable date + time → May 19, 2026 9:00 AM
  /// Accepts ISO string (preferred) or already-parsed input.
  static String formatReadableDateTime(
    String? isoDateTime, {
    String fallback = "--",
  }) {
    try {
      if (isoDateTime == null || isoDateTime.isEmpty) return fallback;

      final parsed = DateTime.parse(isoDateTime).toLocal();
      return DateFormat(kReadableDateTimePattern).format(parsed);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format month + days summary → May 19 & 20, 2026
  static String formatMonthDaysWithCommaYear(
    List<DateTime> dates, {
    String fallback = "",
  }) {
    try {
      if (dates.isEmpty) return fallback;

      dates.sort();

      final days = dates
          .map((date) => DateFormat(kDayOfMonthPattern).format(date))
          .toList();
      final lastDate = dates.last;
      final month = DateFormat(kMonthShortPattern).format(lastDate);
      final year = DateFormat(kYearPattern).format(lastDate);

      return "$month ${_joinDays(days)}, $year";
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Selected-days label → Selected Days: 19 & 20 May 2026
  static String formatSelectedDaysWithLastMonthYear(
    List<DateTime> dates, {
    String fallback = "",
  }) {
    try {
      if (dates.isEmpty) return fallback;

      dates.sort();

      final days = dates
          .map((date) => DateFormat(kDayOfMonthPattern).format(date))
          .toList();
      final monthYear = DateFormat(kMonthYearPattern).format(dates.last);

      return "Selected Days: ${_joinDays(days)} $monthYear";
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Grouped selected-days label → Selected Days: 19 & 20 May 2026
  static String formatGroupedSelectedDaysLabel(
    List<DateTime> dates, {
    String fallback = "",
  }) {
    try {
      if (dates.isEmpty) return fallback;

      return "Selected Days: ${_formatGroupedMonthDays(dates)}";
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Grouped compact summary → May 2026 19 & 20
  static String formatGroupedMonthDays(
    List<DateTime> dates, {
    String fallback = "",
  }) {
    try {
      if (dates.isEmpty) return fallback;

      return _formatGroupedMonthDays(dates, monthFirst: true);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Card single/range date → May 19, 2026 or May 19–21, 2026
  static String formatCardDateRange(String? value, {String fallback = ""}) {
    try {
      if (value == null || value.isEmpty) return fallback;

      final rawDates = value
          .split(',')
          .map((date) => date.trim())
          .where((date) => date.isNotEmpty)
          .toList();

      if (rawDates.isEmpty) return fallback;

      final parsedDates = rawDates
          .map((date) => DateTime.tryParse(date)?.toLocal())
          .whereType<DateTime>()
          .toList();

      if (parsedDates.length != rawDates.length) return value;
      if (parsedDates.length == 1) {
        return DateFormat(kReadableDatePattern).format(parsedDates.first);
      }

      final first = parsedDates.first;
      final last = parsedDates.last;

      if (first.year == last.year && first.month == last.month) {
        return "${DateFormat(kMonthDayPattern).format(first)}–${last.day}, ${last.year}";
      }

      if (first.year == last.year) {
        return "${DateFormat(kMonthDayPattern).format(first)} – "
            "${DateFormat(kReadableDatePattern).format(last)}";
      }

      return "${DateFormat(kReadableDatePattern).format(first)} – "
          "${DateFormat(kReadableDatePattern).format(last)}";
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Date + Time together → MM-dd-yyyy 09:00 AM
  static String formatDateTime(
    String? date,
    String? time, {
    String fallback = "--",
  }) {
    try {
      if (date == null || time == null) return fallback;

      final dateParsed = DateTime.parse(date).toLocal();
      final timeParsed = DateFormat(kTime24HmsPattern).parse(time);

      final combined = DateTime(
        dateParsed.year,
        dateParsed.month,
        dateParsed.day,
        timeParsed.hour,
        timeParsed.minute,
      );

      return DateFormat(kDateTimePattern).format(combined);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Combine date and time string into a single DateTime object
  static DateTime? combineDateAndTime(DateTime? date, String? timeStr) {
    if (date == null || timeStr == null || timeStr.trim().isEmpty) return date;

    try {
      final cleanTime = timeStr.trim();
      DateTime timeParsed;

      if (cleanTime.toUpperCase().contains("AM") ||
          cleanTime.toUpperCase().contains("PM")) {
        try {
          timeParsed = DateFormat(kTime12HourPattern).parse(cleanTime);
        } catch (_) {
          timeParsed = DateFormat(kTime12HourShortPattern).parse(cleanTime);
        }
      } else if (cleanTime.split(":").length == 3) {
        timeParsed = DateFormat(kTime24HmsPattern).parse(cleanTime);
      } else {
        timeParsed = DateFormat(kTime24HmPattern).parse(cleanTime);
      }

      return DateTime(
        date.year,
        date.month,
        date.day,
        timeParsed.hour,
        timeParsed.minute,
      );
    } catch (_) {
      return date;
    }
  }

  /// ✅ Parse time string (12-hour or 24-hour) into [TimeOfDay]
  static TimeOfDay? parseTimeOfDay(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return null;
    try {
      final cleanTime = timeStr.trim();
      DateTime timeParsed;

      if (cleanTime.toUpperCase().contains("AM") ||
          cleanTime.toUpperCase().contains("PM")) {
        try {
          timeParsed = DateFormat(kTime12HourPattern).parse(cleanTime);
        } catch (_) {
          timeParsed = DateFormat(kTime12HourShortPattern).parse(cleanTime);
        }
      } else if (cleanTime.split(":").length == 3) {
        timeParsed = DateFormat(kTime24HmsPattern).parse(cleanTime);
      } else {
        timeParsed = DateFormat(kTime24HmPattern).parse(cleanTime);
      }

      return TimeOfDay(hour: timeParsed.hour, minute: timeParsed.minute);
    } catch (_) {
      return null;
    }
  }

  /// Default minimum gap required between start time and end time (in minutes).
  /// Configured to 60 minutes (1 hour). Can be changed at any time.
  static const int kMinAvailabilityGapMinutes = 60;

  /// ✅ Calculate difference in minutes between start time and end time (end - start)
  static int? timeDifferenceInMinutes(String? startTimeStr, String? endTimeStr) {
    final start = parseTimeOfDay(startTimeStr);
    final end = parseTimeOfDay(endTimeStr);
    if (start == null || end == null) return null;

    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes - startMinutes;
  }

  /// ✅ Validates time range between start time and end time.
  ///
  /// Returns `null` if valid, or a human-readable validation error string if invalid.
  static String? validateTimeRange(
    String? startTime,
    String? endTime, {
    int minGapMinutes = kMinAvailabilityGapMinutes,
    DateTime? date,
    DateTime? now,
  }) {
    if (startTime == null ||
        startTime.trim().isEmpty ||
        endTime == null ||
        endTime.trim().isEmpty) {
      return 'Please select time';
    }

    final start = parseTimeOfDay(startTime);
    final end = parseTimeOfDay(endTime);
    if (start == null || end == null) {
      return 'Please select time';
    }

    final currentTime = now ?? DateTime.now();

    // If selected date is today, check if start time is in the past
    if (date != null) {
      final isToday = date.year == currentTime.year &&
          date.month == currentTime.month &&
          date.day == currentTime.day;

      if (isToday) {
        final currentMinutes = currentTime.hour * 60 + currentTime.minute;
        final startMinutes = start.hour * 60 + start.minute;
        if (startMinutes < currentMinutes) {
          return 'Start time cannot be in the past';
        }
      }
    }

    final diffMinutes = timeDifferenceInMinutes(startTime, endTime);
    if (diffMinutes == null) {
      return 'Please select time';
    }

    if (diffMinutes <= 0) {
      return 'End time must be after start time';
    }

    if (diffMinutes < minGapMinutes) {
      if (minGapMinutes >= 60 && minGapMinutes % 60 == 0) {
        final hours = minGapMinutes ~/ 60;
        final hourLabel = hours == 1 ? '1 hour' : '$hours hours';
        return 'Minimum duration between start and end time must be at least $hourLabel';
      }
      return 'Minimum duration between start and end time must be at least $minGapMinutes minutes';
    }

    return null;
  }


  /// ✅ Check if shoot is actionable (unaccepted and current time is > 1 hour before start time)
  static bool isActionableBeforeOneHour({
    required DateTime? eventDate,
    required String? startTime,
    required String? status,
    int crewAccept = 0,
    DateTime? now,
  }) {
    // Check acceptance status
    final lowerStatus = (status ?? '').toLowerCase().trim();
    if (lowerStatus == 'confirmed' || lowerStatus == 'accepted' || crewAccept == 1 || crewAccept == 2) {
      return false;
    }

    if (eventDate == null || startTime == null || startTime.trim().isEmpty) {
      return false;
    }

    final shootStart = combineDateAndTime(eventDate, startTime);
    if (shootStart == null) return false;

    final currentTime = now ?? DateTime.now();
    final cutoffTime = shootStart.subtract(const Duration(hours: 1));

    return currentTime.isBefore(cutoffTime);
  }

  static String _formatGroupedMonthDays(
    List<DateTime> dates, {
    bool monthFirst = false,
  }) {
    dates.sort();

    final monthMap = <String, List<int>>{};

    for (final date in dates) {
      final key = DateFormat(kMonthYearPattern).format(date);
      monthMap.putIfAbsent(key, () => []);
      monthMap[key]!.add(date.day);
    }

    final result = <String>[];

    monthMap.forEach((month, days) {
      days.sort();
      final daysText = _joinDays(days.map((day) => "$day").toList());
      result.add(monthFirst ? "$month $daysText" : "$daysText $month");
    });

    return result.join(", ");
  }

  static String _joinDays(List<String> days) {
    if (days.length == 1) return days.first;
    if (days.length == 2) return "${days[0]} & ${days[1]}";

    return "${days.sublist(0, days.length - 1).join(', ')} & ${days.last}";
  }
}
