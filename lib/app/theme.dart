import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'text_styles.dart';
import 'spacing.dart';
import 'radii.dart';

/// Centralized ThemeData configuration for the Beige app.
///
/// `AppTheme.dark()` replicates the EXACT current theme from main.dart
/// using design tokens instead of hardcoded values.
///
/// `AppTheme.light()` is a placeholder for future use.
///
/// The current app is dark-mode only. The light theme is provided
/// for completeness and future expansion.
class AppTheme {
  AppTheme._(); // Prevent instantiation

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // DARK THEME (Current app theme — exact match)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // ━━━ SCAFFOLD ━━━
      scaffoldBackgroundColor: AppColors.background,

      // ━━━ APP BAR ━━━
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: AppColors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.transparent,
        shadowColor: AppColors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // ━━━ COLOR SCHEME ━━━
      colorScheme: const ColorScheme.dark(
        surface: AppColors.background,
        primary: AppColors.white,
        secondary: AppColors.primary,
        onPrimary: AppColors.background,
        onSecondary: AppColors.onPrimary,
        error: AppColors.error,
        onError: AppColors.white,
        onSurface: AppColors.white,
      ),

      // ━━━ NO SPLASH EFFECTS (preserve current behavior) ━━━
      splashFactory: NoSplash.splashFactory,
      splashColor: AppColors.transparent,
      highlightColor: AppColors.transparent,
      hoverColor: AppColors.transparent,

      // ━━━ BUTTON THEMES (no ripple) ━━━
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: AppSpacing.buttonPadding,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.lgAll,
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          foregroundColor: AppColors.primary,
          padding: AppSpacing.buttonPadding,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.lgAll,
          ),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // ━━━ INPUT DECORATION ━━━
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.inputVertical,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.lgAll,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgAll,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgAll,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgAll,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgAll,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),

      // ━━━ CARD ━━━
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lgAll,
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ━━━ BOTTOM NAV ━━━
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
      ),

      // ━━━ DIALOG ━━━
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.hugeAll),
        titleTextStyle: AppTextStyles.titleMedium.copyWith(color: AppColors.white),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),

      // ━━━ BOTTOM SHEET ━━━
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.topHuge,
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.textTertiary,
      ),

      // ━━━ DIVIDER ━━━
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 0,
      ),

      // ━━━ SNACKBAR ━━━
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(AppSpacing.base),
      ),

      // ━━━ CHIP ━━━
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        disabledColor: AppColors.disabled,
        labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary),
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.onPrimary),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.chipPaddingH,
          vertical: AppSpacing.chipPaddingV,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.fullAll),
        side: const BorderSide(color: AppColors.border),
        elevation: 0,
        pressElevation: 0,
      ),

      // ━━━ SWITCH ━━━
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.3);
          }
          return AppColors.surfaceVariant;
        }),
        trackOutlineColor: WidgetStateProperty.all(AppColors.transparent),
      ),

      // ━━━ CHECKBOX ━━━
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.onPrimary),
        side: const BorderSide(color: AppColors.border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.xsAll),
      ),

      // ━━━ RADIO ━━━
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.textTertiary;
        }),
      ),

      // ━━━ TEXT THEME ━━━
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.white),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.white),
        displaySmall: AppTextStyles.displaySmall.copyWith(color: AppColors.white),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.white),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.white),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.white),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.white),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // LIGHT THEME (Placeholder — for future expansion)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static ThemeData light() {
    // TODO: Implement light theme when ready for dual-mode support.
    // For now, return dark theme to avoid breaking anything.
    return dark();
  }
}
