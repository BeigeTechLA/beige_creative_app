import 'package:flutter/foundation.dart';

/// Single source of truth for one route's `path`, `name`, and visibility.
///
/// Consumed by:
/// - `lib/app/router.dart` for the inline `GoRoute(path:, name:)` declarations.
/// - `lib/features/*/presentation/routes/*_routes.dart` for feature fragments.
/// - `routerProvider`'s `redirect:` callback (via [Routes.publicPaths]).
/// - The route-completeness test in `test/app/router_test.dart`.
///
/// Names are snake_case so they ship cleanly to Firebase Analytics as
/// `screen_name`. Paths stay kebab-case because dashboards / URLs may rely on
/// them (see NAVIGATER_MIGRATION.md §9 Q1/Q7).
@immutable
class RouteSpec {
  const RouteSpec({
    required this.name,
    required this.path,
    this.isPublic = false,
    this.trackScreenView = true,
    this.featureArea,
  });

  final String name;
  final String path;
  final bool isPublic;

  /// When `false`, `AppAnalyticsObserver` skips `screen_view` for this route
  /// (Crashlytics breadcrumb is still written). Use for transient surfaces
  /// like `/splash` and OTP / success screens whose presence skews funnels.
  final bool trackScreenView;

  final String? featureArea;
}

/// All `RouteSpec`s in the app. Add new routes here first; the per-feature
/// fragment files and the route-completeness test pick them up automatically.
abstract class Routes {
  Routes._();

  // Entry
  static const splash = RouteSpec(
    name: 'splash',
    path: '/splash',
    isPublic: true,
    trackScreenView: false, // transient — skews funnels (Phase F)
  );
  static const onboarding = RouteSpec(name: 'onboarding', path: '/onboarding', isPublic: true);

  // Auth
  static const login = RouteSpec(name: 'login', path: '/login', isPublic: true, featureArea: 'auth');
  static const signupStep1 = RouteSpec(name: 'signup_step_1', path: '/signup-step-1', isPublic: true);
  static const signupStep2 = RouteSpec(name: 'signup_step_2', path: '/signup-step-2', isPublic: true);
  static const signupStep3 = RouteSpec(name: 'signup_step_3', path: '/signup-step-3', isPublic: true);
  static const signupSuccess = RouteSpec(name: 'signup_success', path: '/signup-success', isPublic: true, trackScreenView: false);
  static const forgotPassword = RouteSpec(name: 'forgot_password', path: '/forgot-password', isPublic: true);
  static const forgotOtp = RouteSpec(name: 'forgot_otp', path: '/forgot-otp', isPublic: true);
  static const resetPassword = RouteSpec(name: 'reset_password', path: '/reset-password', isPublic: true);
  static const viewDetails = RouteSpec(name: 'view_details', path: '/view-details', isPublic: true);

  // Shell tabs
  static const home = RouteSpec(name: 'home', path: '/home', featureArea: 'home');
  static const shoots = RouteSpec(name: 'shoots', path: '/shoots', featureArea: 'shoots');
  static const files = RouteSpec(name: 'files', path: '/files', featureArea: 'files');
  static const messages = RouteSpec(name: 'messages', path: '/messages', featureArea: 'messages');
  static const manageAvailability = RouteSpec(name: 'manage_availability', path: '/manage-availability');
  static const meetings = RouteSpec(name: 'meetings', path: '/meetings', featureArea: 'meetings');
  static const affiliate = RouteSpec(name: 'affiliate', path: '/affiliate', featureArea: 'affiliate');
  static const payouts = RouteSpec(name: 'payouts', path: '/payouts', featureArea: 'payouts');

  // Profile
  static const myProfile = RouteSpec(name: 'my_profile', path: '/my-profile', featureArea: 'profile');
  static const editPersonalDetails = RouteSpec(name: 'edit_personal_details', path: '/edit-personal-details');
  static const enterProfessionalDetails = RouteSpec(name: 'enter_professional_details', path: '/enter-professional-details');
  static const profileDetails = RouteSpec(name: 'profile_details', path: '/profile-details');
  static const featuredWorks = RouteSpec(name: 'featured_works', path: '/featured-works');
  static const featuredWorkDetails = RouteSpec(name: 'featured_work_details', path: '/featured-work-details');
  static const certificates = RouteSpec(name: 'certificates', path: '/certificates');
  static const resume = RouteSpec(name: 'resume', path: '/resume');
  static const appPreferences = RouteSpec(name: 'app_preferences', path: '/app-preferences');
  static const changePassword = RouteSpec(name: 'change_password', path: '/change-password');
  static const profileOtp = RouteSpec(name: 'profile_otp', path: '/profile-otp');
  static const newPassword = RouteSpec(name: 'new_password', path: '/new-password');
  static const profilePasswordSuccess = RouteSpec(
    name: 'profile_password_success',
    path: '/profile-password-success',
    trackScreenView: false, // momentary success — funnel noise (Phase F)
  );
  static const deleteAccount = RouteSpec(name: 'delete_account', path: '/delete-account');
  static const deleteAccountOtp = RouteSpec(name: 'delete_account_otp', path: '/delete-account-otp');
  static const deleteAccountSuccess = RouteSpec(
    name: 'delete_account_success',
    path: '/delete-account-success',
    trackScreenView: false, // momentary success — funnel noise (Phase F)
  );

  // Shoots
  static const upcomingShootDetails = RouteSpec(name: 'upcoming_shoot_details', path: '/upcoming-shoot-details');
  static const cancelShoot = RouteSpec(name: 'cancel_shoot', path: '/cancel-shoot');
  static const shootCancelotties = RouteSpec(
    name: 'shoot_cancelotties',
    path: '/shoot-cancelotties',
    trackScreenView: false, // momentary lottie success — funnel noise (Phase F)
  );

  // Availability
  static const addAvailability = RouteSpec(name: 'add_availability', path: '/add-availability', featureArea: 'availability');

  // File manager — see docs/feature/FILE_MANAGER_UI_PLAN.md.
  // Root tab is `files` above. Folder details is nested; file open is
  // inline via CommonFileViewer (no in-app screen needed).
  static const filesFolder = RouteSpec(name: 'files_folder', path: '/files/folder/:id', featureArea: 'files');
  static const filesSuccess = RouteSpec(
    name: 'files_success',
    path: '/files/success',
    trackScreenView: false,
    featureArea: 'files',
  );

  // Messages
  static const chat = RouteSpec(name: 'chat', path: '/chat', featureArea: 'messages');
  static const chatDetails = RouteSpec(name: 'chat_details', path: '/chat-details', featureArea: 'messages');

  // Notifications
  static const notifications = RouteSpec(name: 'notifications', path: '/notifications', featureArea: 'notification');

  /// Flat list — drives [publicPaths], [byName], and the route-completeness test.
  static const all = <RouteSpec>[
    splash, onboarding,
    login, signupStep1, signupStep2, signupStep3, signupSuccess,
    forgotPassword, forgotOtp, resetPassword, viewDetails,
    home, shoots, files, messages, meetings, manageAvailability, affiliate,
    payouts,
    myProfile, editPersonalDetails, enterProfessionalDetails, profileDetails,
    featuredWorks, featuredWorkDetails, certificates, resume, appPreferences,
    changePassword, profileOtp, newPassword, profilePasswordSuccess,
    deleteAccount, deleteAccountOtp, deleteAccountSuccess,
    upcomingShootDetails, cancelShoot, shootCancelotties,
    addAvailability,
    filesFolder, filesSuccess,
    chat, chatDetails,
    notifications,
  ];

  static final Set<String> publicPaths = {
    for (final r in all)
      if (r.isPublic) r.path,
  };

  static final Map<String, RouteSpec> byName = {
    for (final r in all) r.name: r,
  };
}
