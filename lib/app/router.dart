import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/firebase/app_analytics_observer.dart';
import '../core/providers/auth_state_provider.dart';
import '../core/providers/onboarding_seen_provider.dart';
import '../manage_availability/add_availability_screen.dart';
import '../profile/profile_details/edit_personal_details_screen.dart';
import '../profile/profile_details/enter_profile_details_screen.dart';
import '../profile/profile_details/profile_details_1_screen.dart';
import '../profile/app_preferences.dart';
import '../profile/certificates.dart';
import '../profile/change_password_screen.dart';
import '../profile/deleteaccount/delete_account.dart';
import '../profile/deleteaccount/delete_account_lottie_screen.dart';
import '../profile/deleteaccount/delete_account_otp_screen.dart';
import '../profile/featured_work_list.dart';
import '../profile/featuredwork_details_screen.dart';
import '../profile/myprofile.dart';
import '../profile/myprofile_youre_all_set_screen.dart';
import '../profile/profile_new_password_screen.dart';
import '../profile/profile_otp_screen.dart';
import '../profile/resume_screen.dart';
import '../shoots/shoot_cancelled_lotties_screen.dart';
import '../shoots/shoot_cancelled_screen.dart';
import '../upcoming_shoot_view_details/upcoming_shoot_view_details.dart';

/// AUTH
import '../auth/login/login.dart';
import '../auth/sign_up/signup1_screen.dart';
import '../auth/sign_up/signup2_screen.dart';
import '../auth/sign_up/signup3_screen.dart';

import '../file_manager/post_production_screen.dart';
import '../file_manager/pre_production_screen.dart';

/// SPLASH + ONBOARDING
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';

/// FORGOT PASSWORD
import '../auth/forgotpassword/forgot_password_screen.dart';
import '../auth/forgotpassword/forgot_password_otp_screen.dart';
import '../auth/resetpassword/reset_password_screen.dart';

/// MAIN
import '../main_screen.dart';

/// PROFILE
import '../auth/view_details_screen.dart';

/// ROUTES
import 'route_names.dart';

/// Public routes — reachable while unauthenticated.
const Set<String> _publicRoutes = {
  '/splash',
  '/onboarding',
  '/login',
  '/signup-step-1',
  '/signup-step-2',
  '/signup-step-3',
  '/forgot-password',
  '/forgot-otp',
  '/reset-password',
};

/// Built once per [ProviderScope]. Reads `authStateProvider` for redirect
/// logic and listens to it via a `ChangeNotifier` adapter so the router
/// re-evaluates redirect on token writes/clears (login + logout + 401).
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    observers: [AppAnalyticsObserver()],
    redirect: (context, state) {
      final isAuth = ref.read(authStateProvider);
      final hasSeenOnboarding = ref.read(onboardingSeenProvider);
      final loc = state.matchedLocation;
      final isPublic = _publicRoutes.contains(loc);

      // Unauthed user touching a protected route → /login.
      if (!isAuth && !isPublic) return '/login';

      // Onboarding skipped once seen — bounce to /login.
      if (!isAuth && hasSeenOnboarding && loc == '/onboarding') {
        return '/login';
      }

      // Authed user on /login or sign-up flow → /home.
      if (isAuth &&
          (loc == '/login' ||
              loc == '/onboarding' ||
              loc.startsWith('/signup-step') ||
              loc == '/forgot-password' ||
              loc == '/forgot-otp' ||
              loc == '/reset-password')) {
        return '/home';
      }
      return null;
    },
    routes: _routes,
  );
});

/// Backwards-compatibility alias — older code paths that haven't been
/// migrated to `ref.watch(routerProvider)` reach for this constant. Built
/// without Riverpod overrides, so its redirect always sees `false` for
/// auth state. New consumers should use `routerProvider` directly.
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  observers: [AppAnalyticsObserver()],
  routes: _routes,
);

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(this._ref) {
    _sub = _ref.listen<bool>(
      authStateProvider,
      (previous, next) => notifyListeners(),
    );
  }
  final Ref _ref;
  late final ProviderSubscription<bool> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

final List<GoRoute> _routes = [
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
      return ForgotPasswordOtpScreen(email: data['email'] ?? '');
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
      final data = state.extra as Map<String, dynamic>;
      return UpcomingShootViewDetails(projectid: data["projectId"]);
    },
  ),

  GoRoute(
    path: '/cancel-shoot',
    name: RouteNames.cancelShoot,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>;
      return CancelScreen(projectId: data["projectId"]);
    },
  ),

  GoRoute(
    path: '/add-availability',
    name: RouteNames.addAvailability,
    builder: (context, state) => AddAvailabilityScreen(),
  ),

  GoRoute(
    path: '/delete-account',
    name: RouteNames.deleteAccount,
    builder: (context, state) => const DeleteAccount(),
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

  /// ───────────────── MY PROFILE ─────────────────
  GoRoute(
    path: '/view-details',
    name: RouteNames.viewDetails,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>? ?? {};
      return ViewDetailsScreen(
        firstName: data['firstName'] ?? "",
        lastName: data['lastName'] ?? "",
        email: data['email'] ?? "",
        location: data['location'] ?? "",
        profileImage: data['profileImage'],
        workingDistance: data['workingDistance'] ?? "",
        primaryRole: data['primaryRole'] ?? "",
        experience: data['experience'] ?? "",
        hourlyRate: data['hourlyRate'] ?? "",
        bio: data['bio'] ?? "",
        skills: data['skills'] ?? "",
        equipments: data['equipments'] ?? "",
        featuredImages: (data['featuredImages'] as List?)
                ?.map((e) => e as File)
                .toList() ??
            <File>[],
      );
    },
  ),

  GoRoute(
    path: '/my-profile',
    name: RouteNames.myProfile,
    builder: (context, state) => const Myprofile(),
  ),
  GoRoute(
    path: '/shoot-cancelotties',
    name: RouteNames.shootCancelotties,
    builder: (context, state) => const ShootCancelledLottiesScreen(),
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
    path: "/profile-details",
    name: RouteNames.profileDetails,
    builder: (context, state) => const ProfileDetails1Screen(),
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
      final data = state.extra as Map<String, dynamic>;
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
    builder: (context, state) => const MyprofileYoureAllSetScreen(),
  ),

  GoRoute(
    path: '/post-production',
    name: RouteNames.postProduction,
    builder: (context, state) => const PostProductionScreen(),
  ),
  GoRoute(
    path: '/pre-production',
    name: RouteNames.preProduction,
    builder: (context, state) => const PreProductionScreen(),
  ),
  GoRoute(
    name: RouteNames.changePassword,
    path: '/change-password',
    builder: (context, state) {
      final email = state.extra as String;
      return ChangePasswordScreen(email: email);
    },
  ),

  GoRoute(
    name: RouteNames.profileOtp,
    path: '/profile-otp',
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
      return MyprofileNewPasswordScreen(
        email: data['email'] ?? '',
        otp: data['otp'] ?? '',
      );
    },
  ),
];
