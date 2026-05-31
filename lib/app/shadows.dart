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
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: AppColors.black15,
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Medium shadow — elevated cards, dropdowns
  static const List<BoxShadow> md = [
    BoxShadow(
      color: AppColors.black20,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: AppColors.black10,
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Large shadow — modals, bottom sheets
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: AppColors.black25,
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: AppColors.black10,
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  /// Extra large shadow — floating elements
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: AppColors.black30,
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // EXTENDED — harvested from widget literals (strict-match)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Active bottom-nav indicator glow — white 0.2, blur 8, spread 1
  static const List<BoxShadow> activeNavGlow = [
    BoxShadow(
      color: AppColors.white20,
      blurRadius: 8,
      spreadRadius: 1,
    ),
  ];

  /// Dark CTA button shadow — black 0.35, blur 16, offset (0,8)
  static const List<BoxShadow> ctaDark = [
    BoxShadow(
      color: AppColors.black35,
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  /// Hero overlay drop shadow — black 0.4, blur 20, offset (0,15)
  static const List<BoxShadow> heroOverlay = [
    BoxShadow(
      color: AppColors.black40,
      blurRadius: 20,
      offset: Offset(0, 15),
    ),
  ];

  /// Gold CTA highlight — primary 0.35, blur 8, offset (0,4)
  static const List<BoxShadow> goldCta = [
    BoxShadow(
      color: AppColors.primaryAlpha35,
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// Card shadow (standard) — black 0.25, blur 12, offset (0,6)
  static const List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.black25,
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];

  /// Card shadow (subtle) — black 0.15, blur 12, offset (0,6)
  static const List<BoxShadow> cardSubtle = [
    BoxShadow(
      color: AppColors.black15,
      blurRadius: 12,
      offset: Offset(0, 6),
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
}
