import 'package:flutter/material.dart';

import '../../app/colors.dart';

/// Shared themed wrapper for Material `showDatePicker` / `showDateRangePicker`
/// calls. Aligns dialog surfaces + `colorScheme` w/ the dark Beige brand so
/// callers don't reimplement the same nested `Theme(...)` builder.
///
/// Usage:
/// ```dart
/// showDatePicker(... builder: appDatePickerTheme);
/// ```
Widget appDatePickerTheme(BuildContext ctx, Widget? child) {
  return Theme(
    data: ThemeData.dark(useMaterial3: true).copyWith(
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surfaceGradientDark,
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.surfaceGradientDark,
        onSurface: AppColors.white,
      ),
    ),
    child: child ?? const SizedBox.shrink(),
  );
}

/// Shared themed wrapper for `showTimePicker`. Adds an explicit
/// [TimePickerThemeData] so AM/PM segment, dial, and hour/minute boxes pick
/// up the brand cream (`AppColors.primary`) instead of Material 3's teal
/// `tertiaryContainer` default — which was leaking through wherever a
/// caller forgot to set `timePickerTheme`.
Widget appTimePickerTheme(BuildContext ctx, Widget? child) {
  return Theme(
    data: ThemeData.dark(useMaterial3: true).copyWith(
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surfaceGradientDark,
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.surfaceGradientDark,
        onSurface: AppColors.white,
      ),
      timePickerTheme: const TimePickerThemeData(
        backgroundColor: AppColors.surfaceGradientDark,
        dialBackgroundColor: AppColors.surfaceGradientDark,
        dialHandColor: AppColors.primary,
        dialTextColor: AppColors.white,
        hourMinuteColor: AppColors.primary,
        hourMinuteTextColor: AppColors.onPrimary,
        dayPeriodColor: AppColors.primary,
        dayPeriodTextColor: AppColors.onPrimary,
        entryModeIconColor: AppColors.primary,
      ),
    ),
    child: child ?? const SizedBox.shrink(),
  );
}
