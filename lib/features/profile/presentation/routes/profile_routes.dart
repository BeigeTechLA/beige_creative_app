import 'package:go_router/go_router.dart';

import '../../../../app/route_names.dart';
import '../screens/app_preferences_screen.dart';
import '../screens/certificates_screen.dart';
import '../screens/change_password_screen.dart';
import '../screens/delete_account_lottie_screen.dart';
import '../screens/delete_account_otp_screen.dart';
import '../screens/delete_account_screen.dart';
import '../screens/edit_personal_details_screen.dart';
import '../screens/enter_profile_details_screen.dart';
import '../screens/featured_work_list_screen.dart';
import '../screens/featuredwork_details_screen.dart';
import '../screens/my_profile_screen.dart';
import '../screens/profile_details_1_screen.dart';
import '../screens/profile_new_password_screen.dart';
import '../screens/profile_otp_screen.dart';
import '../screens/profile_youre_all_set_screen.dart';
import '../screens/resume_screen.dart';

/// Profile-feature routes. Composed into the root `GoRouter` route list in
/// `lib/app/router.dart`.
final List<RouteBase> profileRoutes = [
  GoRoute(
    path: '/my-profile',
    name: RouteNames.myProfile,
    builder: (context, state) => const Myprofile(),
  ),
  GoRoute(
    path: '/edit-personal-details',
    name: RouteNames.editPersonalDetails,
    builder: (context, state) => const EditPersonalDetailsScreen(),
  ),
  GoRoute(
    path: '/enter-professional-details',
    name: RouteNames.enterProfessionalDetails,
    builder: (context, state) => const EnterProfileDetailsScreen(),
  ),
  GoRoute(
    path: '/profile-details',
    name: RouteNames.profileDetails,
    builder: (context, state) => const ProfileDetails1Screen(),
  ),
  GoRoute(
    path: '/featured-works',
    name: RouteNames.featuredWorks,
    builder: (context, state) => const FeaturedWorkList(),
  ),
  GoRoute(
    path: '/featured-work-details',
    name: RouteNames.featuredWorkDetails,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>;
      return FeaturedWorkDetailsScreen(
        title: data["title"],
        images: data["images"],
      );
    },
  ),
  GoRoute(
    path: '/certificates',
    name: RouteNames.certificates,
    builder: (context, state) => const CertificatesScreen(),
  ),
  GoRoute(
    path: '/resume',
    name: RouteNames.resume,
    builder: (context, state) => const ResumeScreen(),
  ),
  GoRoute(
    path: '/app-preferences',
    name: RouteNames.appPreferences,
    builder: (context, state) => const AppPreferencesScreen(),
  ),
  GoRoute(
    path: '/change-password',
    name: RouteNames.changePassword,
    builder: (context, state) {
      final email = state.extra as String;
      return ChangePasswordScreen(email: email);
    },
  ),
  GoRoute(
    path: '/profile-otp',
    name: RouteNames.profileOtp,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>? ?? {};
      return ProfileOtpScreen(email: data['email'] ?? '');
    },
  ),
  GoRoute(
    path: '/new-password',
    name: RouteNames.newPassword,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>? ?? {};
      return ProfileNewPasswordScreen(
        email: data['email'] ?? '',
        otp: data['otp'] ?? '',
      );
    },
  ),
  GoRoute(
    path: '/profile-password-success',
    name: RouteNames.profilePasswordSuccess,
    builder: (context, state) => const ProfileYoureAllSetScreen(),
  ),
  GoRoute(
    path: '/delete-account',
    name: RouteNames.deleteAccount,
    builder: (context, state) => const DeleteAccountScreen(),
  ),
  GoRoute(
    path: '/delete-account-otp',
    name: RouteNames.deleteAccountOtp,
    builder: (context, state) => const DeleteAccountOtpScreen(),
  ),
  GoRoute(
    path: '/delete-account-success',
    name: RouteNames.deleteAccountSuccess,
    builder: (context, state) => const DeleteAccountLottieScreen(),
  ),
];
