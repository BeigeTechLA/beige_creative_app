import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utility/ColorCode.dart';

class CustomCalendar extends StatelessWidget {
  final bool showHeader;
  final Color selectedColor;
  final Color backgroundColor;
  final double borderRadius;

  const CustomCalendar({
    super.key,
    this.showHeader = true,
    this.selectedColor = Colors.amber,
    this.backgroundColor = const Color(0xFF282828),
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: TableCalendar(
        firstDay: DateTime(2020),
        lastDay: DateTime(2035),
        focusedDay: DateTime.now(),
        headerVisible: showHeader,
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: selectedColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}