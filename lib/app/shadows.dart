import 'package:flutter/material.dart';
import 'colors.dart';

/// Centralized shadow tokens for the Beige app.
///
/// Since the app uses a dark theme, shadows are subtle and primarily
/// used on elevated surfaces and gold-accented elements.
///
/// Never use inline BoxShadow in widgets — always use AppShadows.
class AppShadows {
  AppShadows._(); // Prevent instantiation

  /// No shadow
  static const List<BoxShadow> none = [];

  /// Subtle shadow — cards on dark surfaces
  static List<BoxShadow> get sm => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.15),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  /// Medium shadow — elevated cards, dropdowns
  static List<BoxShadow> get md => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.2),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.1),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  /// Large shadow — modals, bottom sheets
  static List<BoxShadow> get lg => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.25),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.1),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  /// Extra large shadow — floating elements
  static List<BoxShadow> get xl => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.3),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // EXTENDED — harvested from widget literals (strict-match)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Active bottom-nav indicator glow — white 0.2, blur 8, spread 1
  static List<BoxShadow> get activeNavGlow => [
    BoxShadow(
      color: AppColors.white.withValues(alpha: 0.2),
      blurRadius: 8,
      spreadRadius: 1,
    ),
  ];

  /// Dark CTA button shadow — black 0.35, blur 16, offset (0,8)
  static List<BoxShadow> get ctaDark => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  /// Hero overlay drop shadow — black 0.4, blur 20, offset (0,15)
  static List<BoxShadow> get heroOverlay => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.4),
      blurRadius: 20,
      offset: const Offset(0, 15),
    ),
  ];

  /// Gold CTA highlight — primary 0.35, blur 8, offset (0,4)
  static List<BoxShadow> get goldCta => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.35),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  /// Card shadow (standard) — black 0.25, blur 12, offset (0,6)
  static List<BoxShadow> get card => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.25),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  /// Card shadow (subtle) — black 0.15, blur 12, offset (0,6)
  static List<BoxShadow> get cardSubtle => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.15),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  /// Card shadow (black12 tint) — blur 12, offset (0,6)
  static const List<BoxShadow> cardBlack12 = [
    BoxShadow(
      color: AppColors.black12,
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];

  /// Card shadow (heavy) — solid black, blur 12, offset (0,6)
  static const List<BoxShadow> cardHeavy = [
    BoxShadow(
      color: AppColors.black,
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];

  /// Viewer sheet drop — black10, blur 20, spread 2
  static const List<BoxShadow> viewerSheet = [
    BoxShadow(
      color: AppColors.black10,
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

/*  /// Gold glow — for highlighted/accent containers
  static List<BoxShadow> get goldGlow => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.2),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  /// Soft drop shadow
  static List<BoxShadow> get soft => [
    const BoxShadow(
      color: AppColors.shadow,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];*/
}
