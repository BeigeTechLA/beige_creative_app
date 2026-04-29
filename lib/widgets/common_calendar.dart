import 'package:beige_creative_app/utility/ColorCode.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CommonCalendar extends StatefulWidget {
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
  State<CommonCalendar> createState() => _CommonCalendarState();
}

class _CommonCalendarState extends State<CommonCalendar>
    with TickerProviderStateMixin {

  late DateTime _internalFocusedDay;

  @override
  void initState() {
    super.initState();
    _internalFocusedDay = widget.focusedDay;
  }

  @override
  void didUpdateWidget(CommonCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedDay != widget.focusedDay) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            _internalFocusedDay = widget.focusedDay;
          });
        }
      });
    }
  }

  int _getRowCount(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final firstWeekday = firstDay.weekday % 7;
    final totalDays = firstWeekday + lastDay.day;
    return (totalDays / 7).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cellHeight = width * 0.20;
        final daysRowHeight = width * 0.13;
        final rowCount = _getRowCount(_internalFocusedDay);

        return Container(
          color: const Color(0xFF1C1C1E),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 0.5,
                  color: ColorCode.kWhiteOpacity70
              ),
              _buildDaysRow(width),
              Container(
                width: double.infinity,
                height: 0.5,
                  color: ColorCode.kWhiteOpacity70
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  // height: cellHeight * rowCount,
                  child: TableCalendar(
                    daysOfWeekVisible: false,
                    firstDay: DateTime(2020),
                    lastDay: DateTime(3000),
                    availableGestures: AvailableGestures.horizontalSwipe,
                    focusedDay: widget.focusedDay,
                    headerVisible: false,
                    onPageChanged: widget.onPageChanged,
                    pageAnimationEnabled: true,
                    pageAnimationDuration: const Duration(milliseconds: 70),
                    pageAnimationCurve: Curves.linear,
                    rowHeight: cellHeight,
                    daysOfWeekHeight: daysRowHeight,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: true,
                      cellMargin: EdgeInsets.zero,
                      cellPadding: EdgeInsets.zero,
                      tableBorder: TableBorder(
                        horizontalInside: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                          width: 0.6,
                        ),
                        verticalInside: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                          width: 0.6,
                        ),
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                          width: 0.6,
                        ),
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, _) =>
                          _buildCell(width, day, isOutside: false),
                      outsideBuilder: (context, day, _) =>
                          _buildCell(width, day, isOutside: true),
                      todayBuilder: (context, day, _) =>
                          _buildCell(width, day, isOutside: false),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDaysRow(double width) {
    final days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    return Container(
      decoration: BoxDecoration(
        color: ColorCode.black,
        border: Border.all(width: 0.5, color: Color(0xff626262)),
      ),
      child: Row(
        children: List.generate(days.length, (index) {
          return Expanded(
            child: Container(
              color: const Color(0xff626262).withOpacity(0.5),
              height: width * 0.13,
              alignment: Alignment.center,
              child: Text(
                days[index],
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: Colors.white,
                  fontSize: width * 0.038,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // 🔥 FIXED _buildCell WITH FILTER LOGIC
  Widget _buildCell(double width, DateTime day, {required bool isOutside}) {
    final dateKey = DateTime(day.year, day.month, day.day);
    final eventText = widget.events[dateKey];

    // 🔥 FILTER LOGIC
    bool shouldShowEvent = false;
    if (widget.selectedEvent == "All Events") {
      shouldShowEvent = eventText != null;
    } else if (widget.selectedEvent == "Available" && eventText == "Available") {
      shouldShowEvent = true;
    } else if (widget.selectedEvent == "Shoot" && eventText == "Shoot") {
      shouldShowEvent = true;
    }

    bool isStrikethrough = day.month == 1 && day.day >= 13 && day.day <= 17 && !isOutside;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${day.day}",
            style: TextStyle(
              fontSize: width * 0.045,
              color: isOutside || isStrikethrough
                  ? Colors.white.withOpacity(0.25)
                  : Colors.white,
              decoration: isStrikethrough ? TextDecoration.lineThrough : null,
            ),
          ),
          SizedBox(height: width * 0.01),
          SizedBox(
            height: width * 0.08,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (shouldShowEvent)
                  _buildEventTag(width, eventText!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTag(double width, String text) {
    bool isAvailable = text.toLowerCase() == "available";
    return Container(
      width: width * 0.18,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(
        horizontal: width * 0.01,
        vertical: width * 0.005,
      ),
      padding: EdgeInsets.symmetric(horizontal: width * 0.006),
      decoration: BoxDecoration(
        color: isAvailable ? const Color(0xffD8FDE6) : const Color(0xffE1E8F9),
        borderRadius: BorderRadius.circular(width * 0.01),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isAvailable ? const Color(0xFF2F855A) : const Color(0xFF4338CA),
          fontSize: width * 0.024,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}