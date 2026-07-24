import 'package:beige_creative_app/app/colors.dart';
import 'package:beige_creative_app/app/spacing.dart';
import 'package:beige_creative_app/app/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CommonCalendar extends StatefulWidget {
  final DateTime focusedDay;
  final Map<DateTime, String> events;
  final Function(DateTime) onPageChanged;
  final String selectedEvent;
  final void Function(DateTime day, String? event)? onDaySelected;

  const CommonCalendar({
    super.key,
    required this.focusedDay,
    required this.events,
    required this.onPageChanged,
    required this.selectedEvent,
    this.onDaySelected,
  });

  @override
  State<CommonCalendar> createState() => _CommonCalendarState();
}

class _CommonCalendarState extends State<CommonCalendar>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cellHeight = width * 0.20;
        final daysRowHeight = width * 0.13;
        final weekdayFontSize = (width * 0.034).clamp(12.0, 16.0);
        return Container(
          color: AppColors.calendarCell,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 0.5,
                color: AppColors.calendarGrid,
              ),
              _buildDaysRow(width, weekdayFontSize),
              Container(
                width: double.infinity,
                height: 0.5,
                color: AppColors.calendarGrid,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  child: TableCalendar(
                    daysOfWeekVisible: false,
                    firstDay: DateTime(2020),
                    lastDay: DateTime(3000),
                    availableGestures: AvailableGestures.horizontalSwipe,
                    focusedDay: widget.focusedDay,
                    headerVisible: false,
                    onPageChanged: widget.onPageChanged,
                    onDaySelected: widget.onDaySelected == null
                        ? null
                        : (selected, focused) {
                            final key = DateTime(
                              selected.year,
                              selected.month,
                              selected.day,
                            );
                            widget.onDaySelected!(key, widget.events[key]);
                          },
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
                          color: AppColors.calendarGrid,
                          width: 0.6,
                        ),
                        verticalInside: BorderSide(
                          color: AppColors.calendarGrid,
                          width: 0.6,
                        ),
                        bottom: BorderSide(
                          color: AppColors.calendarGrid,
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

  Widget _buildDaysRow(double width, double fontSize) {
    final days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(width: 0.5, color: AppColors.calendarGrid),
      ),
      child: Row(
        children: List.generate(days.length, (index) {
          return Expanded(
            child: Container(
              color: AppColors.background,
              height: width * 0.13,
              alignment: Alignment.center,
              child: Text(
                days[index],
                style: AppTextStyles.body14.copyWith(
                  color: AppColors.white,
                  fontSize: fontSize,
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
    final dayFontSize = (width * 0.045).clamp(14.0, 20.0);

    // 🔥 FILTER LOGIC
    bool shouldShowEvent = false;
    if (widget.selectedEvent == "All Events") {
      shouldShowEvent = eventText != null;
    } else if (widget.selectedEvent == "Available" &&
        eventText == "Available") {
      shouldShowEvent = true;
    } else if (widget.selectedEvent == "Shoot" && eventText == "Shoot") {
      shouldShowEvent = true;
    }

    bool isStrikethrough =
        day.month == 1 && day.day >= 13 && day.day <= 17 && !isOutside;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (widget.onDaySelected != null) {
          widget.onDaySelected!(dateKey, eventText);
        }
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${day.day}",
              style: AppTextStyles.inherit.copyWith(
                fontSize: dayFontSize,
                color: isOutside || isStrikethrough
                    ? AppColors.white24
                    : AppColors.white,
                decoration: isStrikethrough ? TextDecoration.lineThrough : null,
              ),
            ),
            SizedBox(height: width * 0.01),
            SizedBox(
              height: width * 0.08,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (shouldShowEvent) _buildEventTag(width, eventText!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTag(double width, String text) {
    bool isAvailable = text.toLowerCase() == "available";
    final eventFontSize = (width * 0.021).clamp(11.0, 14.0);
    return Container(
      width: width * 0.155,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(
        horizontal: width * AppSpacing.calendarEventMarginHFactor,
        vertical: width * AppSpacing.calendarEventMarginVFactor,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: width * AppSpacing.calendarEventPaddingHFactor,
      ),
      decoration: BoxDecoration(
        color: isAvailable ? AppColors.softMint : AppColors.bluePale,
        borderRadius: BorderRadius.circular(width * 0.008),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: AppTextStyles.inheritSemiBold.copyWith(
          color: isAvailable ? AppColors.greenForest : AppColors.indigoDeep,
          fontSize: eventFontSize,
        ),
      ),
    );
  }
}
