/// Centralized route name constants for GoRouter.
///
/// All route names are lowercase_snake_case per MIGRATION_RULES.md.
/// Every GoRoute must reference a name from this class.
abstract class RouteNames {
  // Auth
  static const splash = 'splash';
  static const onboarding = 'onboarding';
  static const login = 'login';
  static const signup = 'signup';
  static const forgotPassword = 'forgot_password';
  static const forgotOtp = 'forgot_otp';
  static const resetPassword = 'reset_password';
  static const passwordSuccess = 'password_success';

  // Main shell tabs
  static const home = 'home';
  static const bookShoot = 'book_shoot';
  static const myShoots = 'my_shoots';
  static const messages = 'messages';

  // home sub-screens
  static const viewProfile = 'view_profile';
  static const recommendedDetails = 'recommended_details';
  static const changeLocation = 'change_location';
  static const findingPerfect = 'finding_perfect';
  static const paymentMethod = 'payment_method';

  // New Booking Flow
  static const contentType = 'content_type';
  static const videoShootType = 'video_shoot_type';
  static const shootDateTime = 'shoot_date_time';
  static const moreDetails = 'more_details';
  static const crewSizeMatching = 'crew_size_matching';
  static const selectDreamTeam = 'select_dream_team';
  static const reviewConfirm = 'review_confirm';
  static const paymentSuccess = 'payment_success';

  // Booking Management
  static const bookingEventSummary = 'booking_event_summary';
  static const manageBooking = 'manage_booking';
  static const bookingReviewConfirm = 'booking_review_confirm';
  static const cancelBooking = 'cancel_booking';
  static const selectBookingType = 'select_booking_type';
  static const shootUpdated = 'shoot_updated';

  // Profile
  static const profile = 'profile';
  static const editProfile = 'edit_profile';
  static const changePassword = 'change_password';
  static const profileOtp = 'profile_otp';
  static const profileNewPassword = 'profile_new_password';
  static const bookingHistory = 'booking_history';
  static const favourites = 'favourites';
  static const appPreferences = 'app_preferences';
  static const deleteAccount = 'delete_account';
  static const deleteAccountOtp = 'delete_account_otp';
}
