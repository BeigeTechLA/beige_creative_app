import 'routes.dart';

/// Deprecated forwarder shim — kept for one PR cycle after Phase A's sweep.
/// All call sites should use `Routes.<x>.name` directly. Scheduled for
/// deletion in Phase D Task D4.
@Deprecated('Use Routes.<x>.name from lib/app/routes.dart instead.')
class RouteNames {
  RouteNames._();

  // Entry
  static String get splash => Routes.splash.name;
  static String get onboarding => Routes.onboarding.name;

  // Auth
  static String get login => Routes.login.name;
  static String get signupStep1 => Routes.signupStep1.name;
  static String get signupStep2 => Routes.signupStep2.name;
  static String get signupStep3 => Routes.signupStep3.name;
  static String get forgotPassword => Routes.forgotPassword.name;
  static String get forgotOtp => Routes.forgotOtp.name;
  static String get resetPassword => Routes.resetPassword.name;
  static String get viewDetails => Routes.viewDetails.name;

  // Shell tabs
  static String get home => Routes.home.name;
  static String get shoots => Routes.shoots.name;
  static String get files => Routes.files.name;
  static String get messages => Routes.messages.name;
  static String get manageAvailability => Routes.manageAvailability.name;

  // Profile
  static String get myProfile => Routes.myProfile.name;
  static String get editPersonalDetails => Routes.editPersonalDetails.name;
  static String get enterProfessionalDetails =>
      Routes.enterProfessionalDetails.name;
  static String get profileDetails => Routes.profileDetails.name;
  static String get featuredWorks => Routes.featuredWorks.name;
  static String get featuredWorkDetails => Routes.featuredWorkDetails.name;
  static String get certificates => Routes.certificates.name;
  static String get resume => Routes.resume.name;
  static String get appPreferences => Routes.appPreferences.name;
  static String get changePassword => Routes.changePassword.name;
  static String get profileOtp => Routes.profileOtp.name;
  static String get newPassword => Routes.newPassword.name;
  static String get profilePasswordSuccess =>
      Routes.profilePasswordSuccess.name;
  static String get deleteAccount => Routes.deleteAccount.name;
  static String get deleteAccountOtp => Routes.deleteAccountOtp.name;
  static String get deleteAccountSuccess => Routes.deleteAccountSuccess.name;

  // Shoots
  static String get upcomingShootDetails => Routes.upcomingShootDetails.name;
  static String get cancelShoot => Routes.cancelShoot.name;
  static String get shootCancelotties => Routes.shootCancelotties.name;

  // Availability
  static String get addAvailability => Routes.addAvailability.name;

  // File manager
  static String get postProduction => Routes.postProduction.name;
  static String get preProduction => Routes.preProduction.name;
}
