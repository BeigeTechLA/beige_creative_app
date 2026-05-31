import 'dart:io';

import 'package:go_router/go_router.dart';

import '../../../../app/route_names.dart';
import '../screens/forgot_password_otp_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/login_screen.dart';
import '../screens/reset_password_screen.dart';
import '../screens/signup1_screen.dart';
import '../screens/signup2_screen.dart';
import '../screens/signup3_screen.dart';
import '../screens/view_details_screen.dart';

/// Auth + signup-flow routes. Composed into the root `GoRouter` route list
/// in `lib/app/router.dart`.
final List<RouteBase> authRoutes = [
  GoRoute(
    path: '/login',
    name: RouteNames.login,
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: '/signup-step-1',
    name: RouteNames.signupStep1,
    builder: (context, state) => const SignUp1Screen(),
  ),
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
  GoRoute(
    path: '/forgot-password',
    name: RouteNames.forgotPassword,
    builder: (context, state) => const ForgotPasswordScreen(),
  ),
  GoRoute(
    path: '/forgot-otp',
    name: RouteNames.forgotOtp,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>? ?? {};
      return ForgotPasswordOtpScreen(email: data['email'] ?? '');
    },
  ),
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
];
