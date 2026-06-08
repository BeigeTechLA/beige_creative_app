import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/top_message.dart';
import '../providers/change_password_providers.dart';

class ProfileNewPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String otp;

  const ProfileNewPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  ConsumerState<ProfileNewPasswordScreen> createState() =>
      _ProfileNewPasswordScreenState();
}

class _ProfileNewPasswordScreenState
    extends ConsumerState<ProfileNewPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final ok =
        await ref.read(newPasswordNotifierProvider.notifier).submit(
              email: widget.email,
              otp: widget.otp,
              password: _passwordController.text,
              confirm: _confirmController.text,
            );
    if (ok && mounted) {
      context.pushNamed(Routes.profilePasswordSuccess.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<NewPasswordState>(newPasswordNotifierProvider, (prev, next) {
      if (next.validationMessage != null &&
          next.validationMessage != prev?.validationMessage) {
        TopMessage.show(context, next.validationMessage!);
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        TopMessage.show(context, next.errorMessage!);
      }
    });
    final state = ref.watch(newPasswordNotifierProvider);

    return AppScaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.28,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          AppAssets.rectangle,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Positioned(
                        top: AppSpacing.md,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => context.pop(),
                              child: SvgPicture.asset(
                                AppAssets.back,
                                height: 24,
                                // ignore: deprecated_member_use
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Set your new Password',
                              style: AppTextStyles.displayStrong16.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "You're almost done! Set a new password to secure \n your account. Make sure it's strong and unique.",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.white30,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          AppSpacing.huge,
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
                            CustomTextField(
                              label: 'New Password',
                              controller: _passwordController,
                              isPassword: true,
                              isVisible: _isPasswordVisible,
                              onToggle: () => setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              }),
                            ),
                            const SizedBox(height: 40),
                            CustomTextField(
                              label: 'Confirm Password',
                              controller: _confirmController,
                              isPassword: true,
                              isVisible: _isConfirmVisible,
                              onToggle: () => setState(() {
                                _isConfirmVisible = !_isConfirmVisible;
                              }),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed:
                                    state.isSubmitting ? null : _onSave,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.borderGold,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadii.xlAll,
                                  ),
                                ),
                                child: state.isSubmitting
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.black,
                                        ),
                                      )
                                    : Text(
                                        'Save New Password',
                                        style: AppTextStyles.displayLabel13
                                            .copyWith(
                                          color: AppColors.textHeading,
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
