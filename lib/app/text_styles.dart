import 'package:flutter/material.dart';
import '../app/assets.dart';

/// Centralized text style tokens for the Beige app.
///
/// Font families:
///   - **Unbounded** — Display/heading text (hero, titles, splash)
///   - **Outfit** — Body text, labels, buttons, inputs
///
/// All text styles should reference this file.
/// Never use inline `TextStyle()` in widgets.
class AppTextStyles {
  AppTextStyles._(); // Prevent instantiation

  // ━━━ Font Family Constants ━━━
  static const String fontFamilyDisplay = AppAssets.fontUnbounded;
  static const String fontFamilyBody = AppAssets.fontOutfit;
  static const String fontFamilyHelvetica = AppAssets.fontHelveticaNeue;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // DISPLAY — Unbounded (Hero sections, splash, onboarding)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.29,
    letterSpacing: -0.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.33,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TITLE — Unbounded (Screen titles, section headers)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.33,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BODY — Outfit (Primary content, descriptions, list items)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
  );

  static const TextStyle bodyCompact = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.38,
  );

  static const TextStyle linkMedium = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.33,
  );

  static const TextStyle otpDigit = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // LABEL — Outfit (Buttons, tabs, chips, input labels)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.5,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // CAPTION — Outfit (Timestamps, hints, badges)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.4,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BUTTON — Outfit (Specific button text styles used in app)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  static const TextStyle detailingText = TextStyle(
    fontFamily: fontFamilyHelvetica,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
  );
}
