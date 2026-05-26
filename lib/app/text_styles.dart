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

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // EXTENDED — Tuples harvested from widget literals (Phase 2 sweep)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Outfit 18 w600 — Section heading in body context (app bar title)
  static const TextStyle headingOutfitLg = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  /// Outfit 16 w500 — Emphasised body
  static const TextStyle bodyLargeMedium = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  /// Outfit 16 w600 — Strong body
  static const TextStyle bodyLargeStrong = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  /// Outfit 15 w400 — Body 15
  static const TextStyle body15 = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  /// Outfit 15 w500 — Body 15 medium
  static const TextStyle body15Medium = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  /// Outfit 15 w600 — Body 15 bold
  static const TextStyle body15Strong = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  /// Outfit 13 w500 — Compact body medium
  static const TextStyle bodyCompactMedium = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  /// Outfit 13 w600 — Compact body bold
  static const TextStyle bodyCompactStrong = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  /// Outfit 14 w400 — Regular body without explicit line height
  static const TextStyle body14 = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  /// Outfit 12 w500 — Small label
  static const TextStyle bodySmallMedium = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  /// Outfit 12 w600 — Small label bold
  static const TextStyle bodySmallStrong = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  /// Outfit 12 bold — Small bold link
  static const TextStyle bodySmallBold = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  /// Outfit 11 w400 — Tiny body
  static const TextStyle body11 = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  /// Outfit 10 w400 — Micro caption
  static const TextStyle body10 = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );

  /// Outfit 14 w600 — Body emphasised
  static const TextStyle bodyMediumStrong = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  /// Unbounded 14 w500 — Compact display label
  static const TextStyle displayLabel14 = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  /// Unbounded 14 w400 — Compact display label (default weight)
  static const TextStyle display14 = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 14,
  );

  /// Unbounded 13 w600 — Tiny display label
  static const TextStyle displayLabel13 = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  /// Unbounded 15 w500 — Mid display label
  static const TextStyle displayLabel15 = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  /// Unbounded 16 w500 — Compact auth/screen title
  static const TextStyle displayLabel16 = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  /// Unbounded 16 bold — Strong display
  static const TextStyle displayStrong16 = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  /// Outfit 18 w500 — Medium body 18
  static const TextStyle body18Medium = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  /// Outfit 20 w500 — Large display body
  static const TextStyle body20Medium = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // INHERIT — Styles with no explicit fontFamily.
  // Render whatever font the surrounding DefaultTextStyle / theme
  // supplies. Use these only where the original widget code
  // intentionally omitted a fontFamily; everywhere else prefer
  // body* / display* tokens.
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// No size, no family, no weight — pure inherit.
  static const TextStyle inherit = TextStyle();

  /// Inherited family, size 13.
  static const TextStyle inherit13 = TextStyle(fontSize: 13);

  /// Inherited family, size 14.
  static const TextStyle inherit14 = TextStyle(fontSize: 14);

  /// Inherited family, size 14 w600.
  static const TextStyle inherit14Strong = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  /// Inherited family, size 15 w500.
  static const TextStyle inherit15Medium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  /// Inherited family, size 15 w600.
  static const TextStyle inherit15Strong = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  /// Inherited family, size 16 w500.
  static const TextStyle inherit16Medium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  /// Inherited family + size, weight w600.
  static const TextStyle inheritSemiBold = TextStyle(
    fontWeight: FontWeight.w600,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // EXTENDED — Signup-flow outliers (Phase 2 — Batch 4)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Outfit 13 w400 — Compact body without explicit line height
  static const TextStyle body13 = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  /// Outfit 13 bold — Compact emphasis (terms accept label)
  static const TextStyle body13Bold = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );

  /// Outfit 12 w400 — Small body without explicit line height
  static const TextStyle body12 = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  /// Outfit 14 w500 — Medium body without letter spacing
  static const TextStyle body14Medium = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  /// Outfit 11 w500 — Tiny label with 0.2 letter spacing (signup3 helper)
  static const TextStyle body11MediumLetter02 = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );

  /// Unbounded 16 w600 — Strong display label
  static const TextStyle displayStrong16w600 = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  /// Inherited family, size 13, line-height 1.4 — terms paragraph body.
  static const TextStyle inherit13Tight = TextStyle(
    fontSize: 13,
    height: 1.4,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // EXTENDED — Profile-account outliers (Phase 2 — Batch 5)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Inherited family, size 15 bold — Underlined CTA (resend OTP).
  static const TextStyle inherit15Bold = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  /// Inherited family, size 16 w600 — Strong body (OTP placeholder).
  static const TextStyle inherit16Strong = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  /// Inherited family, size 18 w600 — OTP digit (filled state).
  static const TextStyle inherit18Strong = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  /// Inherited family, size 19 bold — Big OTP digit.
  static const TextStyle inherit19Bold = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.bold,
  );

  /// Inherited family, size 20 bold — Hero OTP heading.
  static const TextStyle inherit20Bold = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  /// Outfit 14 w400 height 1.5 — Relaxed body (delete-account copy)
  static const TextStyle body14LineRelaxed = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // EXTENDED — Profile-details outliers (Phase 2 — Batch 6)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Unbounded 20 bold — Profile card name heading
  static const TextStyle displayBold20 = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // EXTENDED — Profile-portfolio outliers (Phase 2 — Batch 7)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Unbounded 14 w600 — Section header bold (logout sheet, profile menu)
  static const TextStyle displayLabel14Strong = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  /// Unbounded 15 w600 — Modal title (logout bottom sheet heading)
  static const TextStyle displayLabel15Strong = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  /// Unbounded w500 — Button label without explicit size (inherited)
  static const TextStyle displayLabelW500 = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontWeight: FontWeight.w500,
  );

  /// Unbounded 18 bold — Onboarding hero title
  static const TextStyle heading18Unbounded = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  /// Unbounded 14 w400 — Onboarding "Login" button label
  static const TextStyle bodyMediumStrongUnbounded = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 14,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // EXTENDED — Home dashboard outliers (Phase B — Batch 11 re-run)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Outfit 26 bold — Arc chart center total
  static const TextStyle body26Bold = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 26,
    fontWeight: FontWeight.bold,
  );

  /// Unbounded 18 w600 — Filter sheet heading
  static const TextStyle displayHeading18 = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  /// Outfit 22 w700 — Dashboard card large count
  static const TextStyle body22w700 = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  /// Outfit 7.79 w400 — Micro event label inside calendar cell
  static const TextStyle eventLabelMicro = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 7.79,
    fontWeight: FontWeight.w400,
  );
}
