import 'package:flutter/material.dart';

import '../utility/imges_icons.dart';

class ManageAvailabilityController extends ChangeNotifier {

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  String selectedFilter = "All Events";

  List<Map<String, dynamic>> get cardDataList => _cardDataList;

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

  final List<Map<String, dynamic>> _cardDataList = [
    {
      'title': 'Wedding Event 2026',
      'date': 'Jan 15, 2026',
      'time': '12:00 PM - 4:00 PM',
      'location': 'Los Angeles, CA',
      'image': AppImages.weddingevent,
    },
    {
      'title': 'Birthday Shoot 2026',
      'date': 'Feb 20, 2026',
      'time': '2:00 PM - 6:00 PM',
      'location': 'New York, NY',
      'image': "assets/home/img.png",
    },
    {
      'title': 'Corporate Event 2026',
      'date': 'Mar 10, 2026',
      'time': '10:00 AM - 2:00 PM',
      'location': 'Chicago, IL',
      'image': "assets/images/video.png",
    },
  ];
}