/// Centralized event-name registry for `AnalyticsService`.
///
/// All event names are `lowercase_snake_case` per the Firebase Analytics
/// convention. Custom event names live here so PR review can spot
/// duplicates / typos before they fan out across the app.
class AnalyticsEvents {
  AnalyticsEvents._();

  // ━━━ Auth ━━━
  static const String loginSuccess = 'login_success';
  static const String loginFailure = 'login_failure';
  static const String signupStarted = 'signup_started';
  static const String signupCompleted = 'signup_completed';
  static const String passwordResetRequested = 'password_reset_requested';
  static const String logout = 'logout';
  static const String accountDeletionRequested = 'account_deletion_requested';

  // ━━━ Shoots / Bookings ━━━
  static const String shootAccepted = 'shoot_accepted';
  static const String shootDeclined = 'shoot_declined';
  static const String shootCancelled = 'shoot_cancelled';

  // ━━━ Profile ━━━
  static const String profilePhotoUploaded = 'profile_photo_uploaded';
  static const String featuredWorkUploaded = 'featured_work_uploaded';
  static const String resumeUploaded = 'resume_uploaded';
  static const String certificationsUploaded = 'certifications_uploaded';

  // ━━━ Availability ━━━
  static const String availabilityAdded = 'availability_added';

  // ━━━ Navigation ━━━
  static const String screenView = 'screen_view';
}
