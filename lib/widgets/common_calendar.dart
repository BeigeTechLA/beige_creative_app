import 'package:beige_creative_app/utility/ColorCode.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';

class CommonCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final Map<DateTime, String> events;
  final Function(DateTime) onPageChanged;
  final String selectedEvent;

  const CommonCalendar({
    super.key,
    required this.focusedDay,
    required this.events,
    required this.onPageChanged,
    required this.selectedEvent,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime(2020),
      lastDay: DateTime(2050),
      focusedDay: focusedDay,
      headerVisible: false,
      onPageChanged: onPageChanged,

      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final event = events[DateTime(day.year, day.month, day.day)];

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${day.day}", style: TextStyle(color: ColorCode.white)),
              if (event != null)
                Container(
                  margin: EdgeInsets.all(2),
                  padding: EdgeInsets.all(2),
                  color: ColorCode.green,
                  child: Text(event, style: TextStyle(fontSize: 8)),
                ),
            ],
          );
        },
      ),
    );
  }
}