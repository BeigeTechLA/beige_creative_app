import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../ManageAvailability/manage_asvailability_conttoller.dart';

class CustomCalendar extends StatelessWidget {
  final ManageAvailabilityController controller;

  const CustomCalendar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime(2020),
      lastDay: DateTime(2035),
      focusedDay: controller.focusedDay,
      selectedDayPredicate: (day) =>
          isSameDay(controller.selectedDay, day),
      onDaySelected: controller.onDaySelected,

      /// 🔹 Normal Header
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        leftChevronIcon:
        Icon(Icons.chevron_left, color: Colors.white),
        rightChevronIcon:
        Icon(Icons.chevron_right, color: Colors.white),
      ),

      /// 🔹 Simple Calendar Style
      calendarStyle: const CalendarStyle(
        defaultTextStyle:
        TextStyle(color: Colors.white70),
        weekendTextStyle:
        TextStyle(color: Colors.white70),
        outsideTextStyle:
        TextStyle(color: Colors.white24),
        selectedDecoration: BoxDecoration(
          color: Colors.amber,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.brown,
          shape: BoxShape.circle,
        ),
      ),

      /// 🔹 Small Event Dot Marker
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, _) {
          final event = controller.getEvent(day);

          if (event == null) return const SizedBox();

          return Positioned(
            bottom: 4,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: controller.getEventColor(event),
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}