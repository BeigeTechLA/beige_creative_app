import 'package:flutter/material.dart';
import 'colors.dart';

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

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // PHASE 2 — Deferred fields (enable individually with screenshot diff)
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      //
      // useMaterial3: true,
      // brightness: Brightness.dark,
      // fontFamily: AppTextStyles.fontFamilyBody,
      // textTheme: ...,
      // inputDecorationTheme: ...,
      // cardTheme: ...,
      // bottomNavigationBarTheme: ...,
      // dialogTheme: ...,
      // bottomSheetTheme: ...,
      // snackBarTheme: ...,
      // chipTheme: ...,
      // dividerTheme: ...,
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
