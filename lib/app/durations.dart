/// Centralized animation duration tokens for the Beige app.
///
/// Use these for all animated transitions and implicit animations.
/// Never use inline Duration() in widgets — always use AppDurations.
class AppDurations {
  AppDurations._(); // Prevent instantiation

  /// 100ms — Micro interactions (opacity, color changes)
  static const Duration instant = Duration(milliseconds: 100);

  /// 200ms — Fast transitions (icon swaps, button state changes)
  static const Duration fast = Duration(milliseconds: 200);

  /// 300ms — Standard transitions (page fades, card reveals)
  static const Duration normal = Duration(milliseconds: 300);

  /// 350ms — Page transitions
  static const Duration pageTransition = Duration(milliseconds: 350);

  /// 500ms — Slow transitions (complex animations, onboarding)
  static const Duration slow = Duration(milliseconds: 500);

  /// 800ms — Splash screen / loading animations
  static const Duration splash = Duration(milliseconds: 800);

  /// 1000ms — Long animations (success, celebration)
  static const Duration long = Duration(milliseconds: 1000);

  /// 2000ms — Auto-dismiss (toasts, snackbars)
  static const Duration autoDismiss = Duration(milliseconds: 2000);
}
