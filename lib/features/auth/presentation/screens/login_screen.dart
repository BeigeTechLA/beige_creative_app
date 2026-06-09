import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/new_text_field.dart';
import '../../../../shared/widgets/top_message.dart';
import '../providers/login_notifier.dart';
import '../providers/login_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool showPassword = false;
  bool _credentialsHydrated = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_rebuild);
    passwordController.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool get isFormValid =>
      emailController.text.trim().isNotEmpty &&
      passwordController.text.trim().isNotEmpty;

  void _hydrateSavedCredentials(LoginState state) {
    if (_credentialsHydrated) return;
    if (!state.savedCredentialsLoaded) return;
    _credentialsHydrated = true;
    if (state.savedEmail != null && state.savedPassword != null) {
      emailController.text = state.savedEmail!;
      passwordController.text = state.savedPassword!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginNotifierProvider);
    _hydrateSavedCredentials(state);

    ref.listen<LoginState>(loginNotifierProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        TopMessage.show(context, next.errorMessage!);
      }
      if (next.loginSuccess && !(prev?.loginSuccess ?? false)) {
        context.goNamed(Routes.home.name);
      }
    });

    return AppScaffold(
      safeTop: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height:
                  (MediaQuery.of(context).size.height * 0.35).clamp(220.0, 320.0),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(AppAssets.rectangle, fit: BoxFit.fill),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Welcome Back",
                          style: AppTextStyles.displayLabel16.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your details to access your account. Continue\nmanaging your bookings and profile.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body14.copyWith(
                            color: AppColors.white.withValues(alpha: 0.60),
                            height: 1.29,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -70),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: AppSpacing.authCardPadding,
                    margin: AppSpacing.authCardMargin,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadii.massiveAll,
                      border: Border.all(color: AppColors.white24, width: 1),
                    ),
                    child: AutofillGroup(
                      child: Column(
                        children: [
                          CustomInputField(
                            title: "Email ID*",
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [
                              AutofillHints.username,
                              AutofillHints.email,
                            ],
                          ),
                          const SizedBox(height: 20),
                          CustomInputField(
                            title: "Password*",
                            controller: passwordController,
                            isPassword: true,
                            isVisible: showPassword,
                            autofillHints: const [AutofillHints.password],
                            onToggle: () => setState(
                              () => showPassword = !showPassword,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => showPassword = !showPassword,
                              ),
                              icon: SvgPicture.asset(
                                showPassword
                                    ? AppAssets.eyeOpen
                                    : AppAssets.eyeClose,
                                height: 22,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  context.pushNamed(Routes.forgotPassword.name);
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: AppTextStyles.bodySmallBold.copyWith(
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 1.8,
                                    decorationColor: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: (!isFormValid || state.isLoggingIn)
                                  ? null
                                  : () {
                                      TextInput.finishAutofillContext();
                                      ref.read(loginNotifierProvider.notifier).login(
                                            email: emailController.text,
                                            password: passwordController.text,
                                          );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFormValid
                                    ? AppColors.primary
                                    : AppColors.borderGold,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadii.xlAll,
                                ),
                              ),
                              child: Text(
                                "Login",
                                style: AppTextStyles.displayLabel13.copyWith(
                                  color: isFormValid
                                      ? AppColors.textHeading
                                      : AppColors.surfaceMid,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don’t have an account? ",
              style: AppTextStyles.inherit15Medium.copyWith(
                color: AppColors.white60,
              ),
            ),
            InkWell(
              onTap: () => context.pushNamed(Routes.signupStep1.name),
              child: Text(
                "Sign Up",
                style: AppTextStyles.inherit15Strong.copyWith(
                  color: AppColors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
