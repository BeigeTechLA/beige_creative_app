import 'package:intl/intl.dart';

/// Central date/time formatting helpers.
///
/// Meetings module uses [formatMeetingDate] on both the card and the details
/// sheet so the on-screen date format stays consistent.
class DateTimeUtils {
  DateTimeUtils._();

  /// `May 19,2026` — meeting listing / details.
  static const String kMeetingDatePattern = 'MMM dd,yyyy';

  /// Format DateTime → `May 19,2026`.
  ///
  /// Returns [fallback] when [date] is null or when the underlying formatter
  /// throws (defensive; DateFormat is total for non-null input).
  static String formatMeetingDate(DateTime? date, {String fallback = '--'}) {
    try {
      if (date == null) return fallback;
      return DateFormat(kMeetingDatePattern).format(date);
    } catch (_) {
      return fallback;
    }
  }
}
