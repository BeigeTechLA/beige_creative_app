import 'package:flutter/material.dart';

/// Centralized color tokens for the Beige app.
///
/// All colors used throughout the app should reference this file.
/// Never use inline `Color(0xFF...)` or `Colors.xxx` in widgets.
///
/// Color palette: Dark Luxury Gold — matches the Beige brand identity.
class AppColors {
  AppColors._(); // Prevent instantiation

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BRAND COLORS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Primary gold accent — buttons, CTAs, highlights
  static const Color primary = Color(0xFFE8D1AB);

  /// Darker gold — pressed states, gradients
  static const Color primaryDark = Color(0xFFD4A14D);

  /// Text/icon color when placed ON primary gold surfaces
  static const Color onPrimary = Color(0xFF1D1D1B);

  /// Light cream — subtle accents, tinted backgrounds
  static const Color accent = Color(0xFFECE1CE);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BACKGROUND & SURFACE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Main app background — near-black charcoal
  static const Color background = Color(0xFF1D1D1B);

  /// Elevated surface — cards, sheets, dialogs
  static const Color surface = Color(0xFF262624);

  /// Secondary surface — slightly lighter for depth
  static const Color surfaceVariant = Color(0xFF2A2A2A);

  /// Card bottom area — deepest dark
  static const Color surfaceDark = Color(0xFF0D0D0D);

  /// Near-black for deep elements
  static const Color surfaceDeep = Color(0xFF0A0A0A);

  /// Mid surface - distinct from surfaceVariant
  static const Color surfaceMid = Color(0xFF282828);

  /// Icon/circle backgrounds
  static const Color iconBackground = Color(0xFF171717);

  /// Input/card dark background
  static const Color surfaceInput = Color(0xFF1A1A1A);

  /// Dark gradient stop — used in gradient backgrounds
  static const Color surfaceGradientDark = Color(0xFF121212);

  /// Warm dark surface — brownish dark containers
  static const Color surfaceWarm = Color(0xFF322F2A);

  /// Warm dark surface — slightly lighter variant
  static const Color surfaceWarmLight = Color(0xFF363131);

  /// Nested stats card dark surface
  static const Color surfaceStats = Color(0xFF1E1E1E);

  /// Profile crop sheet surface
  static const Color surfaceCropSheet = Color(0xFF1C1C1C);

  /// Background
  static const Color lightGoldenBg = Color(0xFFFEF5E5);
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TEXT COLORS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Primary text — off-white on dark background
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text — warm grey
  static const Color textSecondary = Color(0xFF9E9A92);

  /// Tertiary (hint) text — muted
  static const Color textTertiary = Color(0xFF777571);

  /// Dark text — for use on light/gold surfaces
  static const Color textDark = Color(0xFF4E4B44);

  /// Heading text on dark backgrounds
  static const Color textHeading = Color(0xFF1D1D1B);

  /// Subtext color — dark grey
  static const Color textSubtle = Color(0xFF474746);

  /// Muted text/icon — neutral grey
  static const Color textMuted = Color(0xFF939393);

  /// Light neutral text used in auth helper copy
  static const Color textLightNeutral = Color(0xFFD5D5D5);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SEMANTIC COLORS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const Color error = Color(0xFFFF0000);
  static const Color errorLight = Color(0xFFFFC9C9);
  static const Color errorAccent = Color(0xFFF66E6E);
  static const Color errorSurface = Color(0xFF100B03);
  static const Color success = Color(0xFF4CAF50);
  static const Color online = Color(0xFF2ED47A);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF0066FF);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BORDER & DIVIDER
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Standard border — light grey
  static const Color border = Color(0xFFDDDDDD);

  /// Gold border — 50% opacity
  static const Color borderGold = Color(0x80E8D1AB);

  /// Full gold border
  static const Color borderGoldSolid = Color(0xFFE8D1AB);

  /// Subtle light border — 50% opacity
  static const Color borderLight = Color(0x80DDDDDD);

  /// Divider on dark surfaces — white 12%
  static const Color dividerDark = Color(0x1FFFFFFF);

  /// Standard divider
  static const Color divider = Color(0xFFDDDDDD);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // OPACITY VARIANTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // — White opacities —
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB2FFFFFF);
  static const Color white60 = Color(0x99FFFFFF);
  static const Color white54 = Color(0x8AFFFFFF);
  static const Color white38 = Color(0x61FFFFFF);
  static const Color white36 = Color(0x5CFFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white24 = Color(0x3DFFFFFF);
  static const Color white15 = Color(0x26FFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);

  // — Black opacities —
  static const Color black = Color(0xFF000000);
  static const Color black87 = Color(0xDD000000);
  static const Color black54 = Color(0x8A000000);
  static const Color black38 = Color(0x61000000);
  static const Color black70 = Color(0xB2000000);
  static const Color black26 = Color(0x42000000);
  static const Color black16 = Color(0x29000000);
  static const Color black12 = Color(0x1F000000);
  static const Color black10 = Color(0x1A000000);
  static const Color black36 = Color(0x5C000000);

  // — Brand opacities —
  static const Color backgroundOpacity70 = Color(0xB21D1D1B);
  static const Color subtextOpacity60 = Color(0x991D1D1B);
  static const Color goldLight20 = Color(0x33E8D5B5);
  static const Color goldOpacity40 = Color(0x66E9BE78);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // GRADIENT COLORS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Light gold parchment — crew card selected highlight
  static const Color goldParchment = Color(0xFFD6C29C);

  /// Pale gold CTA surface
  static const Color goldCta = Color(0xFFE7C89E);

  /// Payment success CTA surface
  static const Color goldSuccessCta = Color(0xFFE6C79C);

  /// Light payment accent
  static const Color paymentAccent = Color(0xFFFFE6A5);

  /// Gold gradient — light end
  static const Color goldGradientLight = Color(0xFFE8D1AB);

  /// Gold gradient — dark end
  static const Color goldGradientDark = Color(0xFFD4A14D);

  /// Divider gradient — start/end (9% white)
  static const Color dividerGradientEdge = Color(0x17FFFFFF);

  /// Divider gradient — center
  static const Color dividerGradientCenter = Color(0xFFFFFFFF);

  /// Circle gradient — top
  static const Color circleGradientTop = Color(0xFF1D1D1B);

  /// Circle gradient — bottom
  static const Color circleGradientBottom = Color(0xFF434341);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // FUNCTIONAL
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const Color disabled = Color(0xFF5D5D5D);
  static const Color overlay = Color(0x80000000);
  static const Color shadow = Color(0x11000000);
  static const Color neutralGrey = Color(0xFF9E9E9E);
  static const Color borderFaint = Color(0x0FE8E8E8);
  static const Color shimmerBase = Color(0xFF2A2A2A);
  static const Color shimmerHighlight = Color(0xFF3A3A38);
  static const Color transparent = Color(0x00000000);

  // — Material-compatible —
  /// Amber — star ratings, warnings
  static const Color amber = Color(0xFFFFC107);

  /// Grey 200 — light platform UI (image picker, sheets)
  static const Color greyShade200 = Color(0xFFEEEEEE);

  /// Grey 400 — disabled foregrounds
  static const Color greyShade400 = Color(0xFFBDBDBD);

  /// Grey 700 — disabled controls
  static const Color greyShade700 = Color(0xFF616161);

  /// Grey 800 — dark platform UI (image picker, sheets)
  static const Color greyShade800 = Color(0xFF424242);

  /// Green - for discounts
  static const Color discountGreen = Color(0xFF7ED957);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // STATUS COLORS (booking flow)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const Color statusOnWay = Color(0xFFFFA000);
  static const Color statusArrived = Color(0xFF4CAF50);
  static const Color statusPending = Color(0xFFE53935);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // MAP COLORS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const Color mapBlue = Color(0xFF1A73E8);
  static const Color mapGrey = Color(0xFF757575);
}
