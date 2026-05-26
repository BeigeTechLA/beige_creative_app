import 'package:flutter/material.dart';

/// Centralized spacing tokens for the Beige app.
///
/// Based on a 4px grid system. Values extracted from actual EdgeInsets
/// usage across the codebase to ensure zero visual changes.
///
/// Never use magic number padding/margin in widgets — always use AppSpacing.
class AppSpacing {
  AppSpacing._(); // Prevent instantiation

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BASE SPACING SCALE (4px grid)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 1.5px — Hair-thin borders/separators
  static const double hairline = 1.5;

  /// 0.6px — Fine inset for gradient borders
  static const double fine = 0.6;

  /// 2px — Micro spacing (icon-label align)
  static const double xxxs = 2;

  /// 3px — Off-grid micro outlier (badge inset)
  static const double s3 = 3;

  /// 4px — Tiny spacing (inline gaps)
  static const double xxs = 4;

  /// 6px — Chip padding, tight gaps
  static const double xs = 6;

  /// 8px — Small spacing (icon–text gap)
  static const double sm = 8;

  /// 9px — Off-grid dropdown icon inset
  static const double dropdownIconInset = 9;

  /// 7px — Off-grid dropdown padding
  static const double s7 = 7;

  /// 11px — Off-grid status item vertical
  static const double s11 = 11;

  /// 9px — Off-grid button vertical (Availability "Add" button)
  static const double s9 = 9;

  /// 17px — Off-grid spacer (home dashboard divider)
  static const double s17 = 17;

  /// 10px — Compact padding (list items, chips)
  static const double smd = 10;

  /// 12px — Medium compact
  static const double md = 12;

  /// 13px — Compact auth card top inset
  static const double authCardCompactTop = 13;

  /// 14px — Input/button vertical padding
  static const double mld = 14;

  /// 15px — Off-grid outlier (list padding)
  static const double s15 = 15;

  /// 16px — Standard / default spacing (most common)
  static const double base = 16;

  /// 18px — Medium-large padding
  static const double lg = 18;

  /// 20px — Comfortable spacing
  static const double xl = 20;

  /// 24px — Section spacing
  static const double xxl = 24;

  /// 32px — Large section gaps
  static const double xxxl = 32;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // COMPONENT OFF-GRID (exact matches, non-standard values)
  // — Used only where no standard token matches exactly.
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 5px — Tab-container internal padding (profile details tab bar)
  static const double s5 = 5;

  /// 25px — Edit-profile button horizontal padding
  static const double s25 = 25;

  /// 28px — Status-item vertical gap (home dashboard)
  static const double huge28 = 28;

  /// 30px — Spacer outlier (home dashboard section gap)
  static const double s30 = 30;

  /// 22px — Folder card interior padding
  static const double s22 = 22;

  /// 70px — Profile card top inset (avatar overlap offset)
  static const double profileCardTop = 70;

  /// 50px — Profile card margin top (avatar half-overlap)
  static const double s50 = 50;

  /// 36px — Extra large
  static const double huge = 36;

  /// 40px — Hero spacing
  static const double massive = 40;

  /// 48px — Major section dividers
  static const double jumbo = 48;

  /// 64px — Maximum spacing
  static const double max = 64;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SCREEN PADDING
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Standard horizontal screen padding — 16px
  static const double screenH = 16;

  /// Wider horizontal padding — 20px
  static const double screenHWide = 20;

  /// Horizontal margin for auth cards — 16px
  static const double screenHAuth = 16;

  /// Vertical screen padding — 20px
  static const double screenV = 20;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // COMPONENT-SPECIFIC
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const double cardPadding = 16;
  static const double cardGap = 12;
  static const double authCardTop = 25;
  static const double listItemVertical = 12;
  static const double inputVertical = 14;
  static const double inputHorizontal = 18;
  static const double buttonVertical = 14;
  static const double buttonHorizontal = 24;
  static const double chipPaddingH = 12;
  static const double chipPaddingV = 6;
  static const double iconTextGap = 8;
  static const double sectionGap = 24;
  static const double bottomNavHeight = 60;

  // Calendar width-relative factors (strict-match for responsive literals)
  static const double calendarEventMarginHFactor = 0.01;
  static const double calendarEventMarginVFactor = 0.005;
  static const double calendarEventPaddingHFactor = 0.006;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // CONVENIENCE EDGE INSETS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Default screen padding — 16px horizontal, 20px vertical
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenH,
    vertical: screenV,
  );

  /// Card interior padding — 16px all sides
  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);

  /// Button interior padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: buttonHorizontal,
    vertical: buttonVertical,
  );

  /// Auth card content — fromLTRB(20, 32, 20, 20)
  static const EdgeInsets authCardPadding = EdgeInsets.fromLTRB(20, 32, 20, 20);

  /// Auth card margin — horizontal 16px
  static const EdgeInsets authCardMargin = EdgeInsets.symmetric(horizontal: 16);

  /// Horizontal-only 16px
  static const EdgeInsets insetsHBase = EdgeInsets.symmetric(horizontal: base);

  /// Horizontal-only 20px
  static const EdgeInsets insetsHXl = EdgeInsets.symmetric(horizontal: xl);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SIZED BOX GAPS (for Column/Row spacing)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const SizedBox verticalXxs = SizedBox(height: xxs);
  static const SizedBox verticalXxxs = SizedBox(height: xxxs);
  static const SizedBox verticalXs = SizedBox(height: xs);
  static const SizedBox verticalSm = SizedBox(height: sm);
  static const SizedBox verticalSmd = SizedBox(height: smd);
  static const SizedBox verticalMd = SizedBox(height: md);
  static const SizedBox verticalBase = SizedBox(height: base);
  static const SizedBox verticalMld = SizedBox(height: mld);
  static const SizedBox verticalS15 = SizedBox(height: s15);
  static const SizedBox verticalLg = SizedBox(height: lg);
  static const SizedBox verticalXl = SizedBox(height: xl);
  static const SizedBox verticalXxl = SizedBox(height: xxl);
  static const SizedBox verticalXxxl = SizedBox(height: xxxl);

  static const SizedBox gapHXxs = SizedBox(width: xxs);
  static const SizedBox gapHXs = SizedBox(width: xs);
  static const SizedBox gapHSm = SizedBox(width: sm);
  static const SizedBox gapHSmd = SizedBox(width: smd);
  static const SizedBox gapHMd = SizedBox(width: md);
  static const SizedBox gapHBase = SizedBox(width: base);
  static const SizedBox gapHXl = SizedBox(width: xl);
}
