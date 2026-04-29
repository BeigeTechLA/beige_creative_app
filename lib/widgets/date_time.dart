import 'package:intl/intl.dart';

class DateTimeUtils {

  /// ✅ Format Date → dd-MM-yyyy
  static String formatDate(String? date) {
    if (date == null || date.isEmpty) return "--";
    try {
      final parsed = DateTime.parse(date);
      return DateFormat("dd-MM-yyyy").format(parsed);
    } catch (e) {
      return "--";
    }
  }

  /// ✅ Format Time → 12hr (hh:mm a)
  static String formatTime(String? time) {
    if (time == null || time.isEmpty) return "--";
    try {
      final parsed = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("hh:mm a").format(parsed);
    } catch (e) {
      return "--";
    }
  }

  /// ✅ Date + Time together
  static String formatDateTime(String? date, String? time) {
    if (date == null || time == null) return "--";
    try {
      final dateParsed = DateTime.parse(date);
      final timeParsed = DateFormat("HH:mm:ss").parse(time);

      final combined = DateTime(
        dateParsed.year,
        dateParsed.month,
        dateParsed.day,
        timeParsed.hour,
        timeParsed.minute,
      );

      return DateFormat("dd-MM-yyyy hh:mm a").format(combined);
    } catch (e) {
      return "--";
    }
  }
}