import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/new_text_field.dart';
import '../../../../shared/widgets/top_message.dart';
import '../providers/change_password_providers.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  final String email;
  const ChangePasswordScreen({super.key, required this.email});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  late final TextEditingController _emailController =
      TextEditingController(text: widget.email);
  bool _isEmailFilled = true;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSendOtp() async {
    final ok = await ref
        .read(requestOtpNotifierProvider.notifier)
        .requestOtp(_emailController.text);
    if (ok && mounted) {
      context.pushNamed(
        Routes.profileOtp.name,
        extra: {'email': _emailController.text.trim()},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RequestOtpState>(requestOtpNotifierProvider, (prev, next) {
      if (next.validationMessage != null &&
          next.validationMessage != prev?.validationMessage) {
        TopMessage.show(context, next.validationMessage!);
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        TopMessage.show(context, next.errorMessage!);
      }
    });

    final state = ref.watch(requestOtpNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.cardCompactInset,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => context.pop(true),
                        child: SvgPicture.asset(AppAssets.back, height: 24),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Change your Password',
                        style: AppTextStyles.displayLabel16.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Enter your email ID to receive an OTP code to change your password.',
                        textAlign: TextAlign.left,
                        softWrap: true,
                        maxLines: 3,
                        style: AppTextStyles.body13.copyWith(
                          color: AppColors.white60,
                        ),
                      ),
                      const SizedBox(height: 25),
                      CustomInputField(
                        readOnly: true,
                        title: 'Email ID*',
                        controller: _emailController,
                        onChanged: (value) {
                          setState(() {
                            _isEmailFilled = value.trim().isNotEmpty;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: state.isSubmitting ? null : _onSendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEmailFilled
                        ? AppColors.primary
                        : AppColors.borderGold,
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
                            valueColor:
                                AlwaysStoppedAnimation(AppColors.black),
                          ),
                        )
                      : Text(
                          'Send OTP',
                          style: AppTextStyles.displayLabel14.copyWith(
                            color: _isEmailFilled
                                ? AppColors.textHeading
                                : AppColors.surfaceMid,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
