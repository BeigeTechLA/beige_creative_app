import 'dart:io';

import 'package:go_router/go_router.dart';

import '../../../../app/route_page_builder.dart';
import '../../../../app/routes.dart';
import '../screens/app_preferences_screen.dart';
import 'profile_args.dart';
import '../screens/certificates_screen.dart';
import '../screens/change_password_screen.dart';
import '../screens/crop_image_screen.dart';
import '../screens/delete_account_success_screen.dart';
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
    pageBuilder: appPageBuilder((context, state) => const Myprofile()),
  ),
  GoRoute(
    path: Routes.cropImage.path,
    name: Routes.cropImage.name,
    pageBuilder: appPageBuilder((context, state) {
      final file = state.extra as File;
      return CropImageScreen(imageFile: file);
    }),
  ),
  GoRoute(
    path: Routes.editPersonalDetails.path,
    name: Routes.editPersonalDetails.name,
    pageBuilder: appPageBuilder(
      (context, state) => const EditPersonalDetailsScreen(),
    ),
  ),
  GoRoute(
    path: Routes.enterProfessionalDetails.path,
    name: Routes.enterProfessionalDetails.name,
    pageBuilder: appPageBuilder(
      (context, state) => const EnterProfileDetailsScreen(),
    ),
  ),
  GoRoute(
    path: Routes.profileDetails.path,
    name: Routes.profileDetails.name,
    pageBuilder: appPageBuilder(
      (context, state) => const ProfileDetails1Screen(),
    ),
  ),
  GoRoute(
    path: Routes.featuredWorks.path,
    name: Routes.featuredWorks.name,
    pageBuilder: appPageBuilder((context, state) => const FeaturedWorkList()),
  ),
  GoRoute(
    path: Routes.featuredWorkDetails.path,
    name: Routes.featuredWorkDetails.name,
    pageBuilder: appPageBuilder((context, state) {
      final args = FeaturedWorkDetailsArgs.fromExtra(state.extra);
      return FeaturedWorkDetailsScreen(title: args.title, images: args.images);
    }),
  ),
  GoRoute(
    path: Routes.certificates.path,
    name: Routes.certificates.name,
    pageBuilder: appPageBuilder((context, state) => const CertificatesScreen()),
  ),
  GoRoute(
    path: Routes.resume.path,
    name: Routes.resume.name,
    pageBuilder: appPageBuilder((context, state) => const ResumeScreen()),
  ),
  GoRoute(
    path: Routes.appPreferences.path,
    name: Routes.appPreferences.name,
    pageBuilder: appPageBuilder(
      (context, state) => const AppPreferencesScreen(),
    ),
  ),
  GoRoute(
    path: Routes.changePassword.path,
    name: Routes.changePassword.name,
    pageBuilder: appPageBuilder((context, state) {
      final args = ChangePasswordArgs.fromExtra(state.extra);
      return ChangePasswordScreen(email: args.email);
    }),
  ),
  GoRoute(
    path: Routes.profileOtp.path,
    name: Routes.profileOtp.name,
    pageBuilder: appPageBuilder((context, state) {
      final args = ProfileOtpArgs.fromExtra(state.extra);
      return ProfileOtpScreen(email: args.email);
    }),
  ),
  GoRoute(
    path: Routes.newPassword.path,
    name: Routes.newPassword.name,
    pageBuilder: appPageBuilder((context, state) {
      final args = ProfileNewPasswordArgs.fromExtra(state.extra);
      return ProfileNewPasswordScreen(email: args.email, otp: args.otp);
    }),
  ),
  GoRoute(
    path: Routes.profilePasswordSuccess.path,
    name: Routes.profilePasswordSuccess.name,
    pageBuilder: appPageBuilder(
      (context, state) => const ProfileYoureAllSetScreen(),
    ),
  ),
  GoRoute(
    path: Routes.deleteAccount.path,
    name: Routes.deleteAccount.name,
    pageBuilder: appPageBuilder(
      (context, state) => const DeleteAccountScreen(),
    ),
  ),
  GoRoute(
    path: Routes.deleteAccountOtp.path,
    name: Routes.deleteAccountOtp.name,
    pageBuilder: appPageBuilder(
      (context, state) => const DeleteAccountOtpScreen(),
    ),
  ),
  GoRoute(
    path: Routes.deleteAccountSuccess.path,
    name: Routes.deleteAccountSuccess.name,
    pageBuilder: appPageBuilder(
      (context, state) => const DeleteAccountSuccessScreen(),
    ),
  ),
];
