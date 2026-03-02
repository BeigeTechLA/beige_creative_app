import 'package:flutter/material.dart';

class ManageAvailabilityController extends ChangeNotifier {

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  String selectedFilter = "All Events";

  final List<String> filters = [
    "All Events",
    "Available",
    "Shoot",
    "Conflict",
  ];

  final Map<DateTime, String> events = {
    DateTime(2026, 1, 2): "Available",
    DateTime(2026, 1, 6): "Shoot",
    DateTime(2026, 1, 12): "Conflict",
  };

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay = selected;
    focusedDay = focused;
    notifyListeners();
  }

  void changeFilter(String value) {
    selectedFilter = value;
    notifyListeners();
  }

  String? getEvent(DateTime day) {
    return events[DateTime(day.year, day.month, day.day)];
  }

  bool isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year &&
        day.month == now.month &&
        day.day == now.day;
  }

  bool isDisabled(DateTime day) {
    final now = DateTime.now();
    return day.isBefore(DateTime(now.year, now.month, now.day));
  }

  Color getEventColor(String event) {
    switch (event) {
      case "Available":
        return Colors.green;
      case "Shoot":
        return Colors.blue;
      case "Conflict":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}