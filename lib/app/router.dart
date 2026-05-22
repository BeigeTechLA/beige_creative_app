

import 'dart:io';

import 'package:go_router/go_router.dart';

import '../ManageAvailability/add_availability_screen.dart';
import '../Profile/ProfileDetils/edit_personal_details_screen.dart';
import '../Profile/ProfileDetils/enter_profile_details_screen.dart';
import '../Profile/ProfileDetils/profile_detils_1screen.dart';
import '../Profile/app_preferences.dart';
import '../Profile/certificates.dart';
import '../Profile/change_password_screen.dart';
import '../Profile/deleteaccount/delete_account.dart';
import '../Profile/deleteaccount/delete_account_lottieScreen.dart';
import '../Profile/deleteaccount/delete_account_otp_screen.dart';
import '../Profile/featured_work_list.dart';
import '../Profile/featuredwork_details_screen.dart';
import '../Profile/myprofile.dart';
import '../Profile/myprofile_youre_all_set_screen.dart';
import '../Profile/profile_new_passwrod_screen.dart';
import '../Profile/profile_otp_screen.dart';
import '../Profile/resume_screen.dart';
import '../Shoots/shoot_cancelled_lotties_screen.dart';
import '../Shoots/shoot_cancelled_screen.dart';
import '../UpcomingShootViewdetils/upcoming_shoot_view_detils.dart';
/// AUTH
import '../auth/login/login.dart';
import '../auth/sign_up/signup1_screen.dart';
import '../auth/sign_up/signup2_screen.dart';
import '../auth/sign_up/signup3_screen.dart';

import '../file_manager/post_production_screen.dart';
import '../file_manager/pre_production_screen.dart';
/// SPLASH + ONBOARDING
import '../splash/splash_screen.dart';
import '../onboding/onboding_screen.dart';

/// FORGOT PASSWORD
import '../auth/ForgotPassword/forgot_password_screen.dart';
import '../auth/ForgotPassword/forgot_password_otp_screen.dart';
import '../auth/resetpassword/reset_password_screen.dart';

/// MAIN
import '../main_screen.dart';

/// PROFILE
import '../auth/view_details_screen .dart';

/// ROUTES
import 'route_names.dart';

final GoRouter appRouter = GoRouter(

  initialLocation: '/splash',

  routes: [

    /// ───────────────── SPLASH ─────────────────
    GoRoute(
      path: '/splash',
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    /// ───────────────── ONBOARDING ─────────────────
    GoRoute(
      path: '/onboarding',
      name: RouteNames.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),

    /// ───────────────── LOGIN ─────────────────
    GoRoute(
      path: '/login',
      name: RouteNames.login,
      builder: (context, state) => const Login(),
    ),

    /// ───────────────── SIGNUP STEP 1 ─────────────────
    GoRoute(
      path: '/signup-step-1',
      name: RouteNames.signupStep1,
      builder: (context, state) => const SignUp1Screen(),
    ),

    /// ───────────────── SIGNUP STEP 2 ─────────────────
    GoRoute(
      path: '/signup-step-2',
      name: RouteNames.signupStep2,
      builder: (context, state) {

        final data = state.extra as Map<String, dynamic>? ?? {};

        return SignUp2Screen(
          crewMemberId: data['crewMemberId'],
          profileImage: data['profileImage'],
          email: data['email'],
          firstName: data['firstName'],
          lastName: data['lastName'],
          location: data['location'],
          workingDistance: data['workingDistance'],
          step1Progress: data['step1Progress'] ?? 0,
        );
      },
    ),

    /// ───────────────── SIGNUP STEP 3 ─────────────────
    GoRoute(
      path: '/signup-step-3',
      name: RouteNames.signupStep3,
      builder: (context, state) {

        final data = state.extra as Map<String, dynamic>? ?? {};

        return SignUp3Screen(
          crewMemberId: data['crewMemberId'],
          profileImage: data['profileImage'],
          email: data['email'],
          firstName: data['firstName'],
          lastName: data['lastName'],
          location: data['location'],
          workingDistance: data['workingDistance'],
          primaryRole: data['primaryRole'] ?? "",
          experience: data['experience'] ?? "",
          hourlyRate: data['hourlyRate'] ?? "",
          bio: data['bio'] ?? "",
          skills: data['skills'] ?? "",
          equipments: data['equipments'] ?? "",
          step2Progress: data['step2Progress'] ?? 0,
        );
      },
    ),

    /// ───────────────── FORGOT PASSWORD ─────────────────
    GoRoute(
      path: '/forgot-password',
      name: RouteNames.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    /// ───────────────── OTP ─────────────────
    GoRoute(
      path: '/forgot-otp',
      name: RouteNames.forgotOtp,
      builder: (context, state) {

        final data = state.extra as Map<String, dynamic>? ?? {};

        return ForgotPasswordOtpScreen(
          email: data['email'] ?? '',
        );
      },
    ),

    /// ───────────────── RESET PASSWORD ─────────────────
    GoRoute(
      path: '/reset-password',
      name: RouteNames.resetPassword,
      builder: (context, state) {

        final data = state.extra as Map<String, dynamic>? ?? {};

        return ResetPasswordScreen(
          email: data['email'] ?? '',
          otp: data['otp'] ?? '',
        );
      },
    ),

    /// ───────────────── HOME ─────────────────
    GoRoute(
      path: '/home',
      name: RouteNames.home,
      builder: (context, state) => const Mainscreen(),
    ),



    GoRoute(
      path: '/upcoming-shoot-details',
      name: RouteNames.upcomingShootDetails,
      builder: (context, state) {

        final data =
        state.extra as Map<String, dynamic>;

        return UpcomingShootViewDetils(
          projectid: data["projectId"],
        );
      },
    ),

    GoRoute(
      path: '/cancel-shoot',
      name: RouteNames.cancelShoot,
      builder: (context, state) {
        final data =
        state.extra as Map<String, dynamic>;
        return CancelScreen(
          projectId: data["projectId"],
        );
      },
    ),

    GoRoute(
      path: '/add-availability',
      name: RouteNames.addAvailability,
      builder: (context, state) {
        return AddAvailabilityScreen();
      },
    ),

    GoRoute(
      path: '/delete-account',
      name: RouteNames.deleteAccount,
      builder: (context, state) {

        return const DeleteAccount();
      },
    ),

    GoRoute(
      path: '/delete-account-otp',
      name: RouteNames.deleteAccountOtp,
      builder: (context, state) {
        return const DeleteAccountOtpScreen();
      },
    ),
    GoRoute(
      path: '/delete-account-success',
      name: RouteNames.deleteAccountSuccess,
      builder: (context, state) {

        return const DeleteAccountLottieScreen();
      },
    ),

    /// ───────────────── MY PROFILE ─────────────────
    GoRoute(
      path: '/view-details',
      name: RouteNames.viewDetails,
      builder: (context, state) {

        final data =
            state.extra as Map<String, dynamic>? ?? {};

        return ViewDetailsScreen(
          firstName: data['firstName'] ?? "",
          lastName: data['lastName'] ?? "",
          email: data['email'] ?? "",
          location: data['location'] ?? "",
          profileImage: data['profileImage'],
          workingDistance:
          data['workingDistance'] ?? "",
          primaryRole:
          data['primaryRole'] ?? "",
          experience:
          data['experience'] ?? "",
          hourlyRate:
          data['hourlyRate'] ?? "",
          bio: data['bio'] ?? "",
          skills: data['skills'] ?? "",
          equipments:
          data['equipments'] ?? "",
          featuredImages:
          (data['featuredImages'] as List<File>?) ?? <File>[],
        );
      },
    ),

    GoRoute(
      path: '/my-profile',
      name: RouteNames.myProfile,
      builder: (context, state) {

        return const Myprofile();
      },
    ),
    GoRoute(
      path: '/shoot-cancelotties',
      name: RouteNames.shootCancelotties,
      builder: (context, state) {

        return const ShootCancelledLottiesScreen();
      },
    ),
 /*   GoRoute(
      path: '/change-password',
      name: RouteNames.changePassword,
      builder: (context, state) {

        return const ();
      },
    ),*/

    GoRoute(
      path: '/edit-personal-details',
      name: RouteNames.editPersonalDetails,
      builder: (context, state) {

        return const EditPersonalDetailsScreen();
      },
    ),

    GoRoute(
      path: '/enter-professional-details',
      name: RouteNames.enterProfessionalDetails,
      builder: (context, state) {

        return const EnterProfileDetailsScreen();
      },
    ),

    GoRoute(
      path: "/profile-details",
      name: RouteNames.profileDetails,
      builder: (context, state) => const ProfileDetils1screen(),
    ),

    GoRoute(
      path: "/featured-works",
      name: RouteNames.featuredWorks,
      builder: (context, state) => const FeaturedWorkList(),
    ),

    GoRoute(
      path: '/featured-work-details',
      name: RouteNames.featuredWorkDetails,

      builder: (context, state) {

        final data =
        state.extra as Map<String, dynamic>;

        return FeaturedWorkDetailsScreen(
          title: data["title"],
          images: data["images"],
        );
      },
    ),

    GoRoute(
      path: "/certificates",
      name: RouteNames.certificates,
      builder: (context, state) => const Certificates(),
    ),

    GoRoute(
      path: "/resume",
      name: RouteNames.resume,
      builder: (context, state) => const Resume(),
    ),

    GoRoute(
      path: "/app-preferences",
      name: RouteNames.appPreferences,
      builder: (context, state) => const AppPreferences(),
    ),
    GoRoute(
      path: "/profile-password-success",
      name: RouteNames.profilePasswordSuccess,
      builder: (context, state) {

        return const MyprofileYoureAllSetScreen();
      },
    ),

    GoRoute(
      path: "/shoot-Cancel",
      name: RouteNames.shootCancel,
      builder: (context, state) => const CancelScreen(),
    ),

    GoRoute(
      path: '/post-production',
      name: RouteNames.postProduction,
      builder: (context, state) {

        return const PostProductionScreen();
      },
    ),
    GoRoute(
      path: '/pre-production',
      name: RouteNames.preProduction,
      builder: (context, state) {
        return const PreProductionScreen();
      },
    ),
    GoRoute(
      name: RouteNames.changePassword,
      path: '/change-password',
      builder: (context, state) {
        final email = state.extra as String;

        return ChangePasswordScreen(
          email: email,
        );
      },
    ),

    GoRoute(
      name: RouteNames.profileOtp,
      path: '/profile-otp',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};

        return ProfileOtpScreen(
          email: data['email'] ?? '',
        );
      },
    ),

    GoRoute(
      path: '/new-password',
      name: RouteNames.newPassword,
      builder: (context, state) {
        final data =
            state.extra as Map<String, dynamic>? ?? {};

        return MyprofileNewPasswrodScreen(
          email: data['email'] ?? '',
          otp: data['otp'] ?? '',
        );
      },
    ),
  ],
);