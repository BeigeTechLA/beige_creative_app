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

  /// 20% opacity of [primary] — used for tinted avatar/icon backgrounds.
  static const Color primary20 = Color(0x33E8D1AB);

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

  /// Muted dark surface — compact type chips
  static const Color surfaceChip = Color(0xFF323131);

  /// Nested stats card dark surface
  static const Color surfaceStats = Color(0xFF1E1E1E);

  /// Profile crop sheet surface
  static const Color surfaceCropSheet = Color(0xFF1C1C1C);

  /// Background
  static const Color lightGoldenBg = Color(0xFFFEF5E5);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SHOOT STATUS BADGE COLORS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Completed status background & foreground
  static const Color shootStatusCompletedBg = Color(0xFFD8ECFD);
  static const Color shootStatusCompletedFg = Color(0xFF0C487C);

  /// Confirmed status background & foreground
  static const Color shootStatusConfirmedBg = Color(0xFFD8FDE6);
  static const Color shootStatusConfirmedFg = Color(0xFF1DAA23);

  /// Pending status background & foreground
  static const Color shootStatusPendingBg = Color(0xFFFDF5DD);
  static const Color shootStatusPendingFg = Color(0xFFE5A100);

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

  /// Golden-tinted subdued text used for meta rows (conversation list count +
  /// stamp).
  static const Color textDarkGolden = Color(0xFF898181);

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
  static const Color white80 = Color(0xCCFFFFFF);
  static const Color white70 = Color(0xB2FFFFFF);
  static const Color white60 = Color(0x99FFFFFF);
  static const Color white54 = Color(0x8AFFFFFF);
  static const Color white50 = Color(0x80FFFFFF);
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
  static const Color black40 = Color(0x66000000);
  static const Color black38 = Color(0x61000000);
  static const Color black35 = Color(0x59000000);
  static const Color black70 = Color(0xB2000000);
  static const Color black26 = Color(0x42000000);
  static const Color black25 = Color(0x40000000);
  static const Color black20 = Color(0x33000000);
  static const Color black16 = Color(0x29000000);
  static const Color black15 = Color(0x26000000);
  static const Color black12 = Color(0x1F000000);
  static const Color black10 = Color(0x1A000000);
  static const Color black36 = Color(0x5C000000);
  static const Color black30 = Color(0x4D000000);

  /// Primary gold at 35% alpha — gold CTA glow
  static const Color primaryAlpha35 = Color(0x59E8D1AB);

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

  // Affiliate dashboard
  static const Color affiliateLedgerSurface = Color(0xFF171717);
  static const Color affiliateLedgerIconSurface = Color(0xFF141414);
  static const Color affiliateLedgerBorder = Color(0xFF3D3D3D);
  static const Color affiliateCompletedBackground = Color(0xFFD4FFE3);
  static const Color affiliateCompletedForeground = Color(0xFF16A34A);
  static const Color affiliateCancelRed = Color(0xFFDC2626);
  static const Color affiliateNoteBackground = Color(0xFFFBE8C9);
  static const Color affiliateDashedLine = Color(0xFF4A4A4A);
  static const Color affiliateChevronBgExpanded = Color(0xFF1F1C16);
  static const Color affiliateDetailText = Color(0xFFF5F5F5);
  static const Color affiliateDetailValue = Color(0xFFA0A0A0);

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
  // SHOOT ACTION COLORS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const Color shootAcceptButtonBackground = softMint;
  static const Color shootAcceptButtonText = greenBright;
  static const Color shootDeclineButtonBackground = softPeach;
  static const Color shootDeclineButtonText = Color(0xFFD33732);

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
  static const Color lightGrey = Color(0xFFCDC5C5);
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // EXTENDED — Phase 1 additions (harvested from widget literals)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // — Dark surface variants (greyscale near-black) —
  /// 0xFF0E0E0E — Deep card surface
  static const Color surfaceNearBlack = Color(0xFF0E0E0E);

  /// 0xFF111111 — Abyss dark
  static const Color surfaceAbyss = Color(0xFF111111);

  /// 0xFF1B1B1B — Charcoal surface
  static const Color surfaceCharcoal = Color(0xFF1B1B1B);

  /// 0xFF1F1F1F — Shadow surface
  static const Color surfaceShadow = Color(0xFF1F1F1F);

  /// 0xFF242424 — Coal surface
  static const Color surfaceCoal = Color(0xFF242424);

  /// 0xFF2C2C2E — Slate surface
  static const Color surfaceSlate = Color(0xFF2C2C2E);

  /// 0xFF2E2E2E — Dim surface
  static const Color surfaceDim = Color(0xFF2E2E2E);

  /// 0xFF303030 — Mute surface
  static const Color surfaceMute = Color(0xFF303030);

  /// 0xFF3A3A3C — Ash surface
  static const Color surfaceAsh = Color(0xFF3A3A3C);

  /// 0xFF4A4A4C — Fog surface
  static const Color surfaceFog = Color(0xFF4A4A4C);

  // — Mid grey —
  /// 0xFF626262 — Mid neutral grey
  static const Color greyMid = Color(0xFF626262);

  // — Extended greens —
  /// 0xFF1DAA23 — Bright signal green
  static const Color greenBright = Color(0xFF1DAA23);

  /// 0xFF2F855A — Forest green
  static const Color greenForest = Color(0xFF2F855A);

  /// 0xFFC8F5D3 — Light mint green
  static const Color greenMintLight = Color(0xFFC8F5D3);

  // — Extended blues —
  /// 0xFF2D66D2 — Royal blue
  static const Color blueRoyal = Color(0xFF2D66D2);

  /// 0xFF4338CA — Deep indigo
  static const Color indigoDeep = Color(0xFF4338CA);

  /// 0xFF3B82F6 — Accent blue
  static const Color blueAccent = Color(0xFF3B82F6);

  /// 0xFF78ABFF — Light sky blue for info labels
  static const Color blueLightSky = Color(0xFF78ABFF);

  /// 0xFFE0E7F8 — Ice blue
  static const Color blueIce = Color(0xFFE0E7F8);

  /// 0xFFE1E8F9 — Pale blue
  static const Color bluePale = Color(0xFFE1E8F9);

  /// 0xFFEFF6FF — Wash blue (lightest)
  static const Color blueWash = Color(0xFFEFF6FF);

  // — Extended purple —
  /// 0xFF540B94 — Deep purple
  static const Color purpleDeep = Color(0xFF540B94);

  // — Extended gold / cream variants —
  /// 0xFFD6B98C — Light gold sand
  static const Color goldSandLight = Color(0xFFD6B98C);

  /// 0xFFD6C19A — Gold sand
  static const Color goldSand = Color(0xFFD6C19A);

  /// 0xFFD6C3A3 — Pale gold sand
  static const Color goldSandPale = Color(0xFFD6C3A3);

  /// 0xFFE8D7B9 — Gold cream
  static const Color goldCream = Color(0xFFE8D7B9);

  /// 0xFFEAD3A1 — Soft gold
  static const Color goldSoft = Color(0xFFEAD3A1);

  /// 0xFFF4E1C1 — Pale cream gold
  static const Color goldPaleCream = Color(0xFFF4E1C1);

  /// 0xFFF5D6A5 — Honey gold
  static const Color goldHoney = Color(0xFFF5D6A5);

  // — Extended pink —
  /// 0xFFEAC5C5 — Soft pink
  static const Color pinkSoft = Color(0xFFEAC5C5);

  // — Extended orange —
  /// 0xFFFF9D25 — Bright orange
  static const Color orangeBright = Color(0xFFFF9D25);

  // — Material-default aliases (replace Colors.X usage) —
  /// 0xFFFF5252 — Material redAccent
  static const Color redAccent = Color(0xFFFF5252);

  /// 0xFF2196F3 — Material blue 500
  static const Color blue = Color(0xFF2196F3);

  /// 0xFF00E676 — Material greenAccent 400
  static const Color greenAccent = Color(0xFF00E676);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PALETTE EXTENSIONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 0xFFD6C3A1 — Soft gold-sand
  static const Color goldSoftSand = Color(0xFFD6C3A1);

  /// 0xFF333333 — Dark grey
  static const Color darkGrey333 = Color(0xFF333333);

  /// 0xFF737373 — Mid-dark grey
  static const Color greyShade737 = Color(0xFF737373);

  /// 0xFF9995B4 — Hint text lavender
  static const Color hintLavender = Color(0xFF9995B4);

  /// 0xFF9B97B5 — Lavender-tinted grey
  static const Color lavenderGrey = Color(0xFF9B97B5);

  /// 0xFFF1F2F5 — Grey wash (near-white)
  static const Color greyWash = Color(0xFFF1F2F5);

  /// 0xFF807E7E — Neutral toggle border grey
  static const Color toggleBorderGrey = Color(0xFF807E7E);

  /// 0xFF3D3D3D — Dark charcoal (also dashboardPanelBorder)
  static const Color darkCharcoal = Color(0xFF3D3D3D);

  /// 0x00FFFFFF — Fully transparent white (for gradients)
  static const Color whiteTransparent = Color(0x00FFFFFF);

  /// 0x33FFFFFF — White at 20%
  static const Color white20 = Color(0x33FFFFFF);

  /// 0xFFFF9800 — Material orange 500
  static const Color orange = Color(0xFFFF9800);

  /// 0xFFC026D3 — Magenta/purple accent
  static const Color magenta = Color(0xFFC026D3);

  /// 0xFF5A0760 — Wine deep purple
  static const Color wine = Color(0xFF5A0760);

  /// 0xFF008080 — Classic teal
  static const Color teal = Color(0xFF008080);

  /// 0xFF2DBB9A — Light teal accent
  static const Color tealLight = Color(0xFF2DBB9A);

  /// 0xFF1FAF8A — Dark teal accent
  static const Color tealDark = Color(0xFF1FAF8A);

  /// 0xFFEECCC9 — Soft peach
  static const Color softPeach = Color(0xFFEECCC9);

  /// 0xFFD8FDE6 — Soft mint
  static const Color softMint = Color(0xFFD8FDE6);

  /// 0xFFC8E1FF — Soft light blue
  static const Color softLightBlue = Color(0xFFC8E1FF);

  /// 0xFF2B2A28 — Shoot stats card top
  static const Color shootStatsCardTop = Color(0xFF2B2A28);

  /// 0xFF1E1D1B — Shoot stats card bottom
  static const Color shootStatsCardBottom = Color(0xFF1E1D1B);

  /// 0x1AE8D1AB — Shoot stats card border (gold at 10%)
  static const Color shootStatsCardBorder = Color(0x1AE8D1AB);

  /// 0xFF161616 — Dashboard panel dark
  static const Color dashboardPanelDark = Color(0xFF161616);

  /// 0xFF202020 — Calendar cell
  static const Color calendarCell = Color(0xFF202020);

  /// 0xFF3A3A3A — Calendar grid lines
  static const Color calendarGrid = Color(0xFF3A3A3A);

  /// 0xFFA678F1 — Arc chart purple
  static const Color arcPurple = Color(0xFFA678F1);

  /// 0xFF5CC4FF — Arc chart blue
  static const Color arcBlue = Color(0xFF5CC4FF);

  /// 0xFFFFC04F — Arc chart yellow
  static const Color arcYellow = Color(0xFFFFC04F);

  /// 0xFF2DC497 — Arc chart green
  static const Color arcGreen = Color(0xFF2DC497);

  /// 0xE8D1AB80 — Textfield border (legacy value, was 0xFFE8D1AB80 before
  /// strict 8-digit-hex lint promotion in Phase 5.05; high byte truncated.
  static const Color textfieldBorderLegacy = Color(0xE8D1AB80);

  /// Gold gradient — cream end (counter bg light stop)
  static const Color goldGradientCream = Color(0xFFFDEFD9);

  /// Gold horizontal gradient — CSS `linear-gradient(90deg, #E8D1AB 0%, #FDEFD9 100%)`
  static const LinearGradient goldHorizontalGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [goldGradientLight, goldGradientCream],
    stops: [0.0, 1.0],
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // MEETING STATUS + RSVP PALETTE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 0xFFFFF4C9 — Meeting status: pending / scheduled bg
  static const Color meetingPendingBg = Color(0xFFFFF4C9);

  /// 0xFFBA6605 — Meeting status: pending / scheduled fg
  static const Color meetingPendingFg = Color(0xFFBA6605);

  /// 0xFFC3E7FD — Meeting status: ongoing bg
  static const Color meetingOngoingBg = Color(0xFFC3E7FD);

  /// 0xFF0575BA — Meeting status: ongoing fg
  static const Color meetingOngoingFg = Color(0xFF0575BA);

  /// 0xFFD4FFE4 — Meeting status: completed bg
  static const Color meetingCompletedBg = Color(0xFFD4FFE4);

  /// 0xFF16A34A — Meeting status: completed fg
  static const Color meetingCompletedFg = Color(0xFF16A34A);

  /// 0xFFFFDDAD — Meeting status: rescheduled bg
  static const Color meetingRescheduledBg = Color(0xFFFFDDAD);

  /// 0xFF8A5C1F — Meeting status: rescheduled fg
  static const Color meetingRescheduledFg = Color(0xFF8A5C1F);

  /// 0xFFFFD3D3 — Meeting status: cancelled bg
  static const Color meetingCancelledBg = Color(0xFFFFD3D3);

  /// 0xFFD33732 — Meeting status: cancelled / reject fg
  static const Color meetingCancelledFg = Color(0xFFD33732);

  /// 0xFFD33732 — RSVP reject fg (alias of cancelled)
  static const Color meetingRejected = meetingCancelledFg;

  /// 0xFFEECCC9 — RSVP reject soft bg (alias of softPeach)
  static const Color meetingRejectSoftBg = softPeach;

  /// Participant box background — 8% white opacity
  static const Color participantBoxBg = Color(0x14FFFFFF);

  /// Participant box border — 8% white opacity
  static const Color participantBoxBorder = Color(0x14FFFFFF);
}
