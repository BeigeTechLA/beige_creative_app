/// Centralized custom-key registry for `CrashlyticsService.setCustomKey`.
///
/// Keys are short, `lowercase_snake_case`. Flavor and user-id are the
/// non-negotiables set during `FirebaseService.initialize`; feature keys are
/// set near the call site that produces them.
class CrashlyticsKeys {
  CrashlyticsKeys._();

  static const String flavor = 'flavor';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
  static const String route = 'last_route';
  static const String featureArea = 'feature_area';
}
