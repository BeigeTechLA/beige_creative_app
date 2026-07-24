import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';

/// Displays an iOS Cupertino-style time picker inside a dark modal sheet.
///
/// Returns the selected [TimeOfDay] when user taps "Done", or `null` if cancelled.
Future<TimeOfDay?> showAppCupertinoTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  required String title,
}) async {
  int minute = initialTime.minute;
  int remainder = minute % 5;
  int roundedMinute = minute;
  int hour = initialTime.hour;

  if (remainder != 0) {
    if (remainder >= 3) {
      roundedMinute = minute + (5 - remainder);
      if (roundedMinute == 60) {
        roundedMinute = 0;
        hour = (hour + 1) % 24;
      }
    } else {
      roundedMinute = minute - remainder;
    }
  }

  final TimeOfDay selectedTimeInitial = TimeOfDay(hour: hour, minute: roundedMinute);
  TimeOfDay selectedTime = selectedTimeInitial;

  final DateTime now = DateTime.now();
  final DateTime initialDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    hour,
    roundedMinute,
  );

  final result = await showCupertinoModalPopup<TimeOfDay>(
    context: context,
    builder: (BuildContext ctx) {
      return Material(
        type: MaterialType.transparency,
        child: Container(
          height: 320,
          decoration: const BoxDecoration(
            color: AppColors.surfaceGradientDark,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadii.xl),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.dividerDark,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(ctx).pop(null),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white60,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      Text(
                        title,
                        style: AppTextStyles.inheritSemiBold.copyWith(
                          color: AppColors.white,
                          fontSize: 16,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(ctx).pop(selectedTime),
                        child: Text(
                          'Done',
                          style: AppTextStyles.inheritSemiBold.copyWith(
                            color: AppColors.goldSand,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(
                      brightness: Brightness.dark,
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          color: AppColors.white,
                          fontSize: 21,
                        ),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: initialDateTime,
                      use24hFormat: false,
                      minuteInterval: 5,
                      onDateTimeChanged: (DateTime newDateTime) {
                        selectedTime = TimeOfDay(
                          hour: newDateTime.hour,
                          minute: newDateTime.minute,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  return result;
}
