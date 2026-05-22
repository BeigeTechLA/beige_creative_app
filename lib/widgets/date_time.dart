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
  static String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "-";

    try {
      final parsedDate = DateTime.parse(dateTime).toLocal();
      return DateFormat("MMM d, yyyy h:mm a").format(parsedDate);
    } catch (e) {
      return dateTime;
    }
  }

}