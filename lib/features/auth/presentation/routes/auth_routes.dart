import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/restoration/draft_store.dart';
import '../../../../core/restoration/restoration_keys.dart';
import '../../../../core/restoration/restoration_providers.dart';
import '../screens/forgot_password_otp_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/login_screen.dart';
import '../screens/reset_password_screen.dart';
import '../screens/signup1_screen.dart';
import '../screens/signup2_screen.dart';
import '../screens/signup3_screen.dart';
import '../screens/signup_success_screen.dart';
import '../screens/view_details_screen.dart';
import 'signup_args.dart';

/// Auth + signup-flow routes. Composed into the root `GoRouter` route list
/// in `lib/app/router.dart`.
final List<RouteBase> authRoutes = [
  GoRoute(
    path: Routes.login.path,
    name: Routes.login.name,
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: Routes.signupStep1.path,
    name: Routes.signupStep1.name,
    builder: (context, state) => const SignUp1Screen(),
  ),
  GoRoute(
    path: Routes.signupStep2.path,
    name: Routes.signupStep2.name,
    builder: (context, state) {
      final args =
          SignUpStep2Args.fromExtra(_signupExtraOrDraft(context, state.extra));
      return SignUp2Screen(
        crewMemberId: args.crewMemberId,
        profileImage: args.profileImage,
        email: args.email,
        firstName: args.firstName,
        lastName: args.lastName,
        location: args.location,
        workingDistance: args.workingDistance,
        step1Progress: args.step1Progress,
      );
    },
  ),
  GoRoute(
    path: Routes.signupStep3.path,
    name: Routes.signupStep3.name,
    builder: (context, state) {
      final args =
          SignUpStep3Args.fromExtra(_signupExtraOrDraft(context, state.extra));
      return SignUp3Screen(
        crewMemberId: args.crewMemberId,
        profileImage: args.profileImage,
        email: args.email,
        firstName: args.firstName,
        lastName: args.lastName,
        location: args.location,
        workingDistance: args.workingDistance,
        primaryRole: args.primaryRole,
        experience: args.experience,
        hourlyRate: args.hourlyRate,
        bio: args.bio,
        skills: args.skills,
        equipments: args.equipments,
        step2Progress: args.step2Progress,
      );
    },
  ),
  GoRoute(
    path: Routes.signupSuccess.path,
    name: Routes.signupSuccess.name,
    builder: (context, state) => const SignUpSuccessScreen(),
  ),
  GoRoute(
    path: Routes.forgotPassword.path,
    name: Routes.forgotPassword.name,
    builder: (context, state) => const ForgotPasswordScreen(),
  ),
  GoRoute(
    path: Routes.forgotOtp.path,
    name: Routes.forgotOtp.name,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>? ?? {};
      return ForgotPasswordOtpScreen(email: data['email'] ?? '');
    },
  ),
  GoRoute(
    path: Routes.resetPassword.path,
    name: Routes.resetPassword.name,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>? ?? {};
      return ResetPasswordScreen(
        email: data['email'] ?? '',
        otp: data['otp'] ?? '',
      );
    },
  ),
  GoRoute(
    path: Routes.viewDetails.path,
    name: Routes.viewDetails.name,
    builder: (context, state) {
      final args = ViewDetailsArgs.fromExtra(state.extra);
      return ViewDetailsScreen(
        firstName: args.firstName,
        lastName: args.lastName,
        email: args.email,
        location: args.location,
        profileImage: args.profileImage,
        workingDistance: args.workingDistance,
        primaryRole: args.primaryRole,
        experience: args.experience,
        hourlyRate: args.hourlyRate,
        bio: args.bio,
        skills: args.skills,
        equipments: args.equipments,
        featuredImages: args.featuredImages,
      );
    },
  ),
];

/// Returns `state.extra` as a map, falling back to the persisted [SignUpDraft]
/// when restoration is enabled and `extra` is null. Used by step-2 / step-3
/// builders so a cold start can hydrate the form on restore.
Map<String, dynamic> _signupExtraOrDraft(BuildContext context, Object? extra) {
  final data = (extra as Map<String, dynamic>?) ?? const <String, dynamic>{};
  if (data.isNotEmpty || !kRestorationEnabled) return data;
  final container = ProviderScope.containerOf(context, listen: false);
  final draft = container.read(draftStoreProvider).readSignUpDraft();
  if (draft == null) return data;
  return {
    if (draft.crewMemberId != null) 'crewMemberId': draft.crewMemberId,
    if (draft.email != null) 'email': draft.email,
    if (draft.firstName != null) 'firstName': draft.firstName,
    if (draft.lastName != null) 'lastName': draft.lastName,
    if (draft.location != null) 'location': draft.location,
    if (draft.workingDistance != null) 'workingDistance': draft.workingDistance,
    if (draft.primaryRole != null) 'primaryRole': draft.primaryRole,
    if (draft.experience != null) 'experience': draft.experience,
    if (draft.hourlyRate != null) 'hourlyRate': draft.hourlyRate,
    if (draft.bio != null) 'bio': draft.bio,
    if (draft.skills != null) 'skills': draft.skills,
    if (draft.equipments != null) 'equipments': draft.equipments,
    if (draft.step1Progress != null) 'step1Progress': draft.step1Progress,
    if (draft.step2Progress != null) 'step2Progress': draft.step2Progress,
  };
}
