import 'telemetry_client.dart';

/// Centralized event-name registry for `AnalyticsService`.
///
/// All event names are `lowercase_snake_case` per the Firebase Analytics
/// convention. Custom event names live here so PR review can spot
/// duplicates / typos before they fan out across the app.
///
/// Prefer the typed helpers in [TelemetryEventHelpers] over reading these
/// constants directly. The constants exist for the helpers + the route
/// observer; feature code should call `ref.read(telemetryClientProvider).
/// shootAccepted(id)` instead of `logEvent(AnalyticsEvents.shootAccepted, ...)`.
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

/// Reason codes for [TelemetryEventHelpers.loginFailure]. Keep this set
/// closed — adding a new reason means a new dashboard segment, so it's a
/// reviewable change.
enum LoginFailureReason {
  invalidCredentials('invalid_credentials'),
  network('network'),
  server('server');

  const LoginFailureReason(this.wireName);

  /// Snake-case value emitted as the `reason` parameter.
  final String wireName;
}

/// Source for [TelemetryEventHelpers.profilePhotoUploaded].
enum ProfilePhotoSource {
  camera('camera'),
  gallery('gallery');

  const ProfilePhotoSource(this.wireName);

  final String wireName;
}

/// Typed event helpers on top of [TelemetryClient.logEvent].
///
/// Why an extension rather than methods on the interface: keeps
/// `TelemetryClient` minimal (one `logEvent` + identity surface) so test
/// fakes only need to implement four methods. Helpers compose from that
/// minimal surface, and tests can still verify by checking the name +
/// parameters captured through `logEvent`.
///
/// Parameter shapes are documented in
/// [docs/telemetry/README.md](../../../docs/telemetry/README.md). Stay
/// strict on shape — drift across notifiers is the whole reason this
/// extension exists.
extension TelemetryEventHelpers on TelemetryClient {
  // ━━━ Auth ━━━

  /// Emits `login_success`. Identity wiring lives in
  /// [TelemetryClient.setUserIdentity] which also fires Firebase-builtin
  /// `login`; this is the app-side registry event used for funnel reporting.
  Future<void> loginSuccess() => logEvent(AnalyticsEvents.loginSuccess);

  /// Emits `login_failure` with a closed-set reason.
  Future<void> loginFailure(LoginFailureReason reason) => logEvent(
        AnalyticsEvents.loginFailure,
        parameters: {'reason': reason.wireName},
      );

  /// Emits `signup_started` at step 1 of the signup wizard.
  Future<void> signupStarted() => logEvent(AnalyticsEvents.signupStarted);

  /// Emits `signup_completed` with optional-asset flags so we can see how
  /// many users land with a populated profile vs. an empty shell.
  Future<void> signupCompleted({
    required bool hasResume,
    required bool hasFeaturedWork,
    required int socialCount,
  }) =>
      logEvent(
        AnalyticsEvents.signupCompleted,
        parameters: {
          'has_resume': hasResume,
          'has_featured_work': hasFeaturedWork,
          'social_count': socialCount,
        },
      );

  /// Emits `password_reset_requested`. Fires on submit, not on success —
  /// the request reaching the server is the signal.
  Future<void> passwordResetRequested() =>
      logEvent(AnalyticsEvents.passwordResetRequested);

  /// Emits `logout`. Fires only on user-initiated logout — 401 / token
  /// expiry skips this (handled by
  /// [TelemetryClient.clearUserIdentity(emitLogoutEvent: false)]).
  Future<void> logout() => logEvent(AnalyticsEvents.logout);

  /// Emits `account_deletion_requested` on the explicit delete-account
  /// flow's confirm tap.
  Future<void> accountDeletionRequested() =>
      logEvent(AnalyticsEvents.accountDeletionRequested);

  // ━━━ Shoots / Bookings ━━━

  /// Emits `shoot_accepted` with the shoot's backend id.
  Future<void> shootAccepted(String shootId) => logEvent(
        AnalyticsEvents.shootAccepted,
        parameters: {'shoot_id': shootId},
      );

  /// Emits `shoot_declined`.
  Future<void> shootDeclined(String shootId) => logEvent(
        AnalyticsEvents.shootDeclined,
        parameters: {'shoot_id': shootId},
      );

  /// Emits `shoot_cancelled`.
  Future<void> shootCancelled(String shootId) => logEvent(
        AnalyticsEvents.shootCancelled,
        parameters: {'shoot_id': shootId},
      );

  // ━━━ Profile ━━━

  /// Emits `profile_photo_uploaded` with source = camera | gallery.
  Future<void> profilePhotoUploaded(ProfilePhotoSource source) => logEvent(
        AnalyticsEvents.profilePhotoUploaded,
        parameters: {'source': source.wireName},
      );

  /// Emits `featured_work_uploaded`. Pass the number of files committed in
  /// one upload action (singleton uploads use `fileCount: 1`).
  Future<void> featuredWorkUploaded({required int fileCount}) => logEvent(
        AnalyticsEvents.featuredWorkUploaded,
        parameters: {'file_count': fileCount},
      );

  /// Emits `resume_uploaded`. Singleton uploads use `fileCount: 1`.
  Future<void> resumeUploaded({required int fileCount}) => logEvent(
        AnalyticsEvents.resumeUploaded,
        parameters: {'file_count': fileCount},
      );

  /// Emits `certifications_uploaded`. Singleton uploads use `fileCount: 1`.
  Future<void> certificationsUploaded({required int fileCount}) => logEvent(
        AnalyticsEvents.certificationsUploaded,
        parameters: {'file_count': fileCount},
      );

  // ━━━ Availability ━━━

  /// Emits `availability_added` with the duration (in whole days) of the
  /// added window. Used to bucket short / long availability blocks in
  /// Firebase reports.
  Future<void> availabilityAdded({required int durationDays}) => logEvent(
        AnalyticsEvents.availabilityAdded,
        parameters: {'duration_days': durationDays},
      );
}
