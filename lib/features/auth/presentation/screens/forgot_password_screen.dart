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
import '../../../../shared/widgets/new_text_field.dart';
import '../../../../shared/widgets/top_message.dart';
import '../providers/forgot_password_notifier.dart';
import '../providers/forgot_password_state.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  bool get isFormValid => emailController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    final email = emailController.text.trim();
    final ok = await ref
        .read(forgotPasswordNotifierProvider.notifier)
        .requestOtp(email);
    if (!ok || !mounted) return;
    context.pushNamed(Routes.forgotOtp.name, extra: {'email': email});
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordNotifierProvider);

    ref.listen<ForgotPasswordState>(forgotPasswordNotifierProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        TopMessage.show(context, next.errorMessage!);
      }
    });

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.32,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(AppAssets.rectangle, fit: BoxFit.fill),
                  ),
                  Positioned(
                    top: 50,
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
                          'Forgot Password',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displayLabel16.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your registered email to receive a reset link.\nWe’ll help you get back into your account quickly.',
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
                      AppSpacing.inlineNudge,
                      AppSpacing.xl,
                      AppSpacing.xl,
                    ),
                    margin: AppSpacing.authCardMargin,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadii.massiveAll,
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.06),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        CustomInputField(
                          title: "Email ID*",
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                        ),
                        const SizedBox(height: 23),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: (!isFormValid || state.isSubmitting)
                                ? null
                                : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFormValid
                                  ? AppColors.primary
                                  : AppColors.borderGold,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadii.xlAll,
                              ),
                            ),
                            child: Text(
                              "Send OTP",
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
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "I Remember my Password. ",
                style: AppTextStyles.inherit15Medium.copyWith(
                  color: AppColors.white60,
                ),
              ),
              InkWell(
                onTap: () => context.goNamed(Routes.login.name),
                child: Text(
                  "Login",
                  style: AppTextStyles.inherit15Strong.copyWith(
                    color: AppColors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
