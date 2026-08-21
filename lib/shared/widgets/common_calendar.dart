import 'package:beige_creative_app/app/colors.dart';
import 'package:beige_creative_app/app/spacing.dart';
import 'package:beige_creative_app/app/text_styles.dart';
import 'package:beige_creative_app/utility/date_time_utils.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../features/availability/domain/entities/availability_entry.dart';

class CommonCalendar extends StatefulWidget {
  final DateTime focusedDay;
  final Map<DateTime, String> events;
  final Map<DateTime, AvailabilityDay>? dayDetails;
  final Function(DateTime) onPageChanged;
  final String selectedEvent;
  final void Function(DateTime day, String? event)? onDaySelected;
  final void Function(DateTime day, AvailabilityDay? details)? onDayDetailsSelected;

  const CommonCalendar({
    super.key,
    required this.focusedDay,
    required this.events,
    this.dayDetails,
    required this.onPageChanged,
    required this.selectedEvent,
    this.onDaySelected,
    this.onDayDetailsSelected,
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
                    onDaySelected: widget.onDaySelected == null && widget.onDayDetailsSelected == null
                        ? null
                        : (selected, focused) {
                            final key = DateTime(
                              selected.year,
                              selected.month,
                              selected.day,
                            );
                            if (widget.onDaySelected != null) {
                              widget.onDaySelected!(key, widget.events[key]);
                            }
                            if (widget.onDayDetailsSelected != null) {
                              widget.onDayDetailsSelected!(
                                key,
                                widget.dayDetails?[key],
                              );
                            }
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

  // 🔥 FIXED _buildCell WITH FILTER LOGIC AND TOOLTIP FOR UNAVAILABLE STATUS
  Widget _buildCell(double width, DateTime day, {required bool isOutside}) {
    final dateKey = DateTime(day.year, day.month, day.day);
    final eventText = widget.events[dateKey];
    final dayDetail = widget.dayDetails?[dateKey];
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
    } else if (widget.selectedEvent == "Not Available" &&
        (eventText == "Not Available" || eventText == "Unavailable")) {
      shouldShowEvent = true;
    }

    bool isStrikethrough =
        day.month == 1 && day.day >= 13 && day.day <= 17 && !isOutside;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final currentDetail = dayDetail ?? widget.dayDetails?[dateKey];
        if (currentDetail?.status == AvailabilityStatus.unavailable) {
          final tooltipMsg = _getUnavailableTooltipMessage(currentDetail!);
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                tooltipMsg,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
              ),
              duration: const Duration(seconds: 3),
              backgroundColor: AppColors.surfaceWarm,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }

        if (widget.onDaySelected != null) {
          widget.onDaySelected!(dateKey, eventText);
        }
        if (widget.onDayDetailsSelected != null) {
          widget.onDayDetailsSelected!(dateKey, currentDetail);
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
                  if (shouldShowEvent)
                    _buildEventTag(width, eventText!, dayDetail),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTag(
      double width, String text, AvailabilityDay? dayDetail) {
    final lower = text.toLowerCase();
    bool isAvailable = lower == "available";
    bool isNotAvailable = lower == "not available" || lower == "unavailable";
    final eventFontSize = (width * 0.021).clamp(11.0, 14.0);

    Color bg;
    Color fg;

    if (isAvailable) {
      bg = AppColors.softMint;
      fg = AppColors.greenForest;
    } else if (isNotAvailable) {
      bg = AppColors.meetingCancelledBg;
      fg = AppColors.meetingCancelledFg;
    } else {
      bg = AppColors.bluePale;
      fg = AppColors.indigoDeep;
    }

    final tagWidget = Container(
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
        color: bg,
        borderRadius: BorderRadius.circular(width * 0.008),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: AppTextStyles.inheritSemiBold.copyWith(
          color: fg,
          fontSize: eventFontSize,
        ),
      ),
    );

    if (isNotAvailable && dayDetail != null) {
      final tooltipMsg = _getUnavailableTooltipMessage(dayDetail);
      return Tooltip(
        message: tooltipMsg,
        triggerMode: TooltipTriggerMode.tap,
        preferBelow: false,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceWarm,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.meetingCancelledFg, width: 1),
        ),
        textStyle:
            AppTextStyles.bodySmallMedium.copyWith(color: AppColors.white),
        child: tagWidget,
      );
    }

    return tagWidget;
  }

  String _getUnavailableTooltipMessage(AvailabilityDay dayDetail) {
    if (dayDetail.isFullDay) {
      return "Not Available: Full Day";
    }
    final start = dayDetail.startTime;
    final end = dayDetail.endTime;

    if (start != null && start.isNotEmpty) {
      final formattedStart = DateTimeUtils.formatTime(start, fallback: start);
      if (end != null && end.isNotEmpty) {
        final formattedEnd = DateTimeUtils.formatTime(end, fallback: end);
        return "Not Available: $formattedStart - $formattedEnd";
      }
      return "Not Available: $formattedStart";
    }
    return "Not Available";
  }
}
