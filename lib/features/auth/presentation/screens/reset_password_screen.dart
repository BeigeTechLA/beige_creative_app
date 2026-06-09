import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/new_text_field.dart';
import '../../../../shared/widgets/top_message.dart';
import '../providers/forgot_password_notifier.dart';
import '../providers/forgot_password_state.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    newPasswordController.addListener(() => setState(() {}));
    confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool get isPasswordFilled =>
      newPasswordController.text.isNotEmpty &&
      confirmPasswordController.text.isNotEmpty;

  Future<void> _submit() async {
    final ok = await ref
        .read(forgotPasswordNotifierProvider.notifier)
        .resetPassword(
          email: widget.email,
          otp: widget.otp,
          newPassword: newPasswordController.text.trim(),
          confirmPassword: confirmPasswordController.text.trim(),
        );
    if (!ok || !mounted) return;
    context.goNamed(Routes.login.name);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordNotifierProvider);

    ref.listen<ForgotPasswordState>(forgotPasswordNotifierProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        TopMessage.show(context, next.errorMessage!);
      }
      if (next.toastMessage != null &&
          next.toastMessage != prev?.toastMessage &&
          next.step == ForgotPasswordStep.resetSucceeded) {
        TopMessage.show(context, next.toastMessage!);
      }
    });

    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height:
                  (MediaQuery.of(context).size.height * 0.32).clamp(200.0, 280.0),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(AppAssets.rectangle, fit: BoxFit.fill),
                  ),
                  Positioned(
                    top: AppSpacing.md,
                    left: 16,
                    child: InkWell(
                      onTap: () => context.pop(),
                      child: SvgPicture.asset(AppAssets.back, height: 24),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Secure your Account',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displayLabel16.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You\'re almost done! Set a new password\nto secure your account.',
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
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.authCardTop,
                      AppSpacing.xl,
                      AppSpacing.xl,
                    ),
                    margin: AppSpacing.authCardMargin,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadii.portfolioCompactAll,
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.10),
                        width: 0.50,
                      ),
                    ),
                    child: Column(
                      children: [
                        CustomInputField(
                          title: "New Password*",
                          controller: newPasswordController,
                          isPassword: true,
                          isVisible: showNewPassword,
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => showNewPassword = !showNewPassword,
                            ),
                            icon: SvgPicture.asset(
                              showNewPassword
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
                        const SizedBox(height: 25),
                        CustomInputField(
                          title: "Confirm Password*",
                          controller: confirmPasswordController,
                          isPassword: true,
                          isVisible: showConfirmPassword,
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => showConfirmPassword = !showConfirmPassword,
                            ),
                            icon: SvgPicture.asset(
                              showConfirmPassword
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
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (isPasswordFilled && !state.isSubmitting)
                                ? _submit
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPasswordFilled
                                  ? AppColors.primary
                                  : AppColors.borderGold,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadii.xlAll,
                              ),
                            ),
                            child: Text(
                              "Save New Password",
                              style: AppTextStyles.displayLabel13.copyWith(
                                color: isPasswordFilled
                                    ? AppColors.textHeading
                                    : AppColors.surfaceMid,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
