import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
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
    path: Routes.myProfile.path,
    name: Routes.myProfile.name,
    builder: (context, state) => const Myprofile(),
  ),
  GoRoute(
    path: Routes.editPersonalDetails.path,
    name: Routes.editPersonalDetails.name,
    builder: (context, state) => const EditPersonalDetailsScreen(),
  ),
  GoRoute(
    path: Routes.enterProfessionalDetails.path,
    name: Routes.enterProfessionalDetails.name,
    builder: (context, state) => const EnterProfileDetailsScreen(),
  ),
  GoRoute(
    path: Routes.profileDetails.path,
    name: Routes.profileDetails.name,
    builder: (context, state) => const ProfileDetails1Screen(),
  ),
  GoRoute(
    path: Routes.featuredWorks.path,
    name: Routes.featuredWorks.name,
    builder: (context, state) => const FeaturedWorkList(),
  ),
  GoRoute(
    path: Routes.featuredWorkDetails.path,
    name: Routes.featuredWorkDetails.name,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>;
      return FeaturedWorkDetailsScreen(
        title: data["title"],
        images: data["images"],
      );
    },
  ),
  GoRoute(
    path: Routes.certificates.path,
    name: Routes.certificates.name,
    builder: (context, state) => const CertificatesScreen(),
  ),
  GoRoute(
    path: Routes.resume.path,
    name: Routes.resume.name,
    builder: (context, state) => const ResumeScreen(),
  ),
  GoRoute(
    path: Routes.appPreferences.path,
    name: Routes.appPreferences.name,
    builder: (context, state) => const AppPreferencesScreen(),
  ),
  GoRoute(
    path: Routes.changePassword.path,
    name: Routes.changePassword.name,
    builder: (context, state) {
      final email = state.extra as String;
      return ChangePasswordScreen(email: email);
    },
  ),
  GoRoute(
    path: Routes.profileOtp.path,
    name: Routes.profileOtp.name,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>? ?? {};
      return ProfileOtpScreen(email: data['email'] ?? '');
    },
  ),
  GoRoute(
    path: Routes.newPassword.path,
    name: Routes.newPassword.name,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>? ?? {};
      return ProfileNewPasswordScreen(
        email: data['email'] ?? '',
        otp: data['otp'] ?? '',
      );
    },
  ),
  GoRoute(
    path: Routes.profilePasswordSuccess.path,
    name: Routes.profilePasswordSuccess.name,
    builder: (context, state) => const ProfileYoureAllSetScreen(),
  ),
  GoRoute(
    path: Routes.deleteAccount.path,
    name: Routes.deleteAccount.name,
    builder: (context, state) => const DeleteAccountScreen(),
  ),
  GoRoute(
    path: Routes.deleteAccountOtp.path,
    name: Routes.deleteAccountOtp.name,
    builder: (context, state) => const DeleteAccountOtpScreen(),
  ),
  GoRoute(
    path: Routes.deleteAccountSuccess.path,
    name: Routes.deleteAccountSuccess.name,
    builder: (context, state) => const DeleteAccountLottieScreen(),
  ),
];
