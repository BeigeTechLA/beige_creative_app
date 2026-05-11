import 'package:flutter/material.dart';

/// Centralized border radius tokens for the Beige app.
///
/// Values extracted from actual BorderRadius.circular() usage across codebase.
/// Most common values: 12, 14, 20 (cards/containers), 8 (buttons), 4 (badges).
///
/// Never use magic number border radius in widgets — always use AppRadii.
class AppRadii {
  AppRadii._(); // Prevent instantiation

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // RAW VALUES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 0 — No rounding
  static const double none = 0;

  /// 4 — Subtle rounding (badges, progress bars)
  static const double xs = 4;

  /// 6 — Small elements (checkboxes, tags)
  static const double sm = 6;

  /// 8 — Buttons, small cards
  static const double md = 8;

  /// 10 — Medium containers
  static const double mld = 10;

  /// 12 — Cards, inputs, standard containers (most common)
  static const double lg = 12;

  /// 11.5 — Nested stats card interior
  static const double statsInner = 11.5;

  /// 14 — Larger cards, buttons, dialogs
  static const double xl = 14;

  /// 16 — Large modals
  static const double xxl = 16;

  /// 18 — Image containers, profile sections
  static const double xxxl = 18;

  /// 20 — Floating cards, bottom sheets
  static const double huge = 20;

  /// 22 — Compact portfolio cards
  static const double portfolioCompact = 22;

  /// 22 — Auth card containers
  static const double authCard = 22;

  /// 24 — Extra large floating elements
  static const double massive = 24;

  /// 25 — Portfolio cards
  static const double portfolio = 25;

  /// 28 — Profile header image bottom corners
  static const double header = 28;

  /// 30 — Rounded containers
  static const double round = 30;

  /// 32 — Bottom sheet top rounding
  static const double sheet = 32;

  /// 38 — Large rounded (avatar-adjacent)
  static const double roundLg = 38;

  /// 40 — Large pill / circular containers
  static const double pillSm = 40;

  /// 50 — Pill / circular elements
  static const double pill = 50;

  /// 64 — Very large circular elements
  static const double enormous = 64;

  /// 999 — Pill / capsule shape
  static const double full = 999;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // CONVENIENCE BORDER RADIUS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static final BorderRadius xsAll = BorderRadius.circular(xs);
  static final BorderRadius smAll = BorderRadius.circular(sm);
  static final BorderRadius mdAll = BorderRadius.circular(md);
  static final BorderRadius lgAll = BorderRadius.circular(lg);
  static final BorderRadius statsInnerAll = BorderRadius.circular(statsInner);
  static final BorderRadius xlAll = BorderRadius.circular(xl);
  static final BorderRadius xxlAll = BorderRadius.circular(xxl);
  static final BorderRadius xxxlAll = BorderRadius.circular(xxxl);
  static final BorderRadius hugeAll = BorderRadius.circular(huge);
  static final BorderRadius portfolioCompactAll = BorderRadius.circular(
    portfolioCompact,
  );
  static final BorderRadius authCardAll = BorderRadius.circular(authCard);
  static final BorderRadius portfolioAll = BorderRadius.circular(portfolio);
  static final BorderRadius massiveAll = BorderRadius.circular(massive);
  static final BorderRadius roundAll = BorderRadius.circular(round);
  static final BorderRadius pillSmAll = BorderRadius.circular(pillSm);
  static final BorderRadius pillAll = BorderRadius.circular(pill);
  static final BorderRadius enormousAll = BorderRadius.circular(enormous);
  static final BorderRadius fullAll = BorderRadius.circular(full);

  /// Top-only rounding for bottom sheets — 20px
  static const BorderRadius topHuge = BorderRadius.only(
    topLeft: Radius.circular(AppRadii.huge),
    topRight: Radius.circular(AppRadii.huge),
  );

  /// Top-only rounding — 32px
  static const BorderRadius topSheet = BorderRadius.only(
    topLeft: Radius.circular(AppRadii.sheet),
    topRight: Radius.circular(AppRadii.sheet),
  );

  /// Top-only rounding — 14px
  static const BorderRadius topXl = BorderRadius.only(
    topLeft: Radius.circular(AppRadii.xl),
    topRight: Radius.circular(AppRadii.xl),
  );

  /// Bottom-only rounding — 28px
  static const BorderRadius bottomHeader = BorderRadius.only(
    bottomLeft: Radius.circular(AppRadii.header),
    bottomRight: Radius.circular(AppRadii.header),
  );

  /// Bottom-only rounding — 40px
  static const BorderRadius bottomPillSm = BorderRadius.only(
    bottomLeft: Radius.circular(AppRadii.pillSm),
    bottomRight: Radius.circular(AppRadii.pillSm),
  );
}
