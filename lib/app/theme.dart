import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

/// Centralized [ThemeData] configuration for the Beige app.
///
/// `AppTheme.dark()` mirrors the inline theme defined in `lib/main.dart`
/// using design tokens from [AppColors]. **Pixel-match guarantee:**
/// only fields currently set by the live inline theme are enabled here.
///
/// Phase 2 will progressively enable the deferred fields (inputDecoration,
/// cardTheme, bottomNavigationBarTheme, dialog, bottom sheet, snackbar,
/// chip, switch, checkbox, radio, textTheme) — kept commented below as a
/// reference for incremental rollout.
///
/// The app is currently dark-mode only. `light()` returns `dark()` until
/// a dedicated light palette is built.
class AppTheme {
  AppTheme._(); // Prevent instantiation

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // DARK THEME — Phase 1 (matches lib/main.dart inline ThemeData)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static ThemeData dark() {
    return ThemeData(
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
      ),

      // ━━━ COLOR SCHEME ━━━
      // Note: `background` parameter retained to match current inline theme,
      // even though Flutter has deprecated it in favor of `surface`.
      // ignore: deprecated_member_use
      colorScheme: const ColorScheme.dark(
        // ignore: deprecated_member_use
        background: AppColors.background,
        primary: AppColors.white,
      ),

      // ━━━ NO SPLASH / RIPPLE ━━━
      splashFactory: NoSplash.splashFactory,
      splashColor: AppColors.transparent,
      highlightColor: AppColors.transparent,
      hoverColor: AppColors.transparent,

      // ━━━ BUTTON SPLASH OVERRIDES ━━━
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
        ),
      ),

      // ━━━ TEXT THEME ━━━
      // Maps AppTextStyles onto the Material TextTheme slots so widgets
      // that inherit (AppBar title, ListTile, SnackBar, Tooltip,
      // PopupMenuItem, etc.) pick up our typography without an explicit
      // `style:`. Widgets that pass an explicit style override these
      // anyway, so this is additive.
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.displayMedium,
        headlineMedium: AppTextStyles.displaySmall,
        headlineSmall: AppTextStyles.titleLarge,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // ━━━ DIVIDER THEME ━━━
      // Sets the default colour so bare Divider() / VerticalDivider()
      // inherit the dark-mode divider tint. Existing call sites that
      // pass a `color:` argument are unaffected.
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
      ),

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // PHASE E (remaining) — Deferred fields (enable individually with
      // screenshot diff)
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      //
      // useMaterial3: true,
      // brightness: Brightness.dark,
      // fontFamily: AppTextStyles.fontFamilyBody,
      // inputDecorationTheme: ...,
      // cardTheme: ...,
      // bottomNavigationBarTheme: ...,
      // dialogTheme: ...,
      // bottomSheetTheme: ...,
      // snackBarTheme: ...,
      // chipTheme: ...,
      // switchTheme: ...,
      // checkboxTheme: ...,
      // radioTheme: ...,
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // LIGHT THEME — placeholder until dual-mode work begins
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static ThemeData light() => dark();
}
