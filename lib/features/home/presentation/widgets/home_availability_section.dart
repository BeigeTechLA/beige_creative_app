import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../utility/date_time_utils.dart';
import '../../../../shared/widgets/common_calendar.dart';

/// "Availability" section — Add button, month-arrow header, event-type
/// dropdown, and embedded [CommonCalendar].
///
/// All state (focused day, selected event, events map) stays in the
/// orchestrator.
///
/// Note (Task 4.15 decompose): the legacy `home_screen.dart` contained two
/// large commented-out earlier versions of this section (`TableCalendar` and
/// a sibling `CommonCalendar` block). They were unreachable code; not carried
/// over — Task 4.16 will formally close that out.
class HomeAvailabilitySection extends StatelessWidget {
  final DateTime focusedDay;
  final String selectedEvent;
  final List<String> eventList;
  final Map<DateTime, String> events;
  final VoidCallback onAddPressed;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<String> onSelectedEventChanged;
  final ValueChanged<DateTime> onPageChanged;

  const HomeAvailabilitySection({
    super.key,
    required this.focusedDay,
    required this.selectedEvent,
    required this.eventList,
    required this.events,
    required this.onAddPressed,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onSelectedEventChanged,
    required this.onPageChanged,
  });

  String _getMonthYear(DateTime date) {
    return DateTimeUtils.formatFullMonthYear(date);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Availability",
              style: AppTextStyles.displayLabel15.copyWith(
                color: AppColors.white,
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.dropdownIconInset,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.roundAll,
                ),
              ),
              onPressed: () {
                context.pushNamed(Routes.addAvailability.name).then((value) {
                  if (value == true) {
                    onAddPressed();
                  }
                });
              },
              icon: const Icon(
                Icons.add,
                size: 18,
                color: AppColors.black,
              ),
              label: Text(
                "Add",
                style: AppTextStyles.bodySmallBold.copyWith(
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.verticalSmd,
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceMid,
            borderRadius: AppRadii.xxxlAll,
            border: Border.all(
              width: 0.6,
              color: AppColors.darkCharcoal,
            ),
          ),
          child: ClipRRect(
            borderRadius: AppRadii.xxxlAll,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // LEFT SIDE (month + arrows)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_left,
                              color: AppColors.white,
                              size: 24,
                            ),
                            onPressed: onPrevMonth,
                          ),

                          // ✅ CENTER FEEL TEXT
                          Expanded(
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _getMonthYear(focusedDay),
                                  style: AppTextStyles.bodyLargeMedium
                                      .copyWith(color: AppColors.white),
                                ),
                              ),
                            ),
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons.chevron_right,
                              color: AppColors.white,
                              size: 24,
                            ),
                            onPressed: onNextMonth,
                          ),
                        ],
                      ),
                    ),

                    // RIGHT SIDE (dropdown)
                    Container(
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.dropdownPadV,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppRadii.lgAll,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedEvent,
                          isDense: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.black,
                            size: 18,
                          ),
                          dropdownColor: AppColors.white,
                          style: AppTextStyles.bodySmallMedium.copyWith(
                            color: AppColors.black,
                          ),
                          items: eventList.map((String value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              onSelectedEventChanged(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CommonCalendar(
                  focusedDay: focusedDay,
                  events: events,
                  selectedEvent: selectedEvent,
                  onPageChanged: onPageChanged,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
