import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../routes/profile_args.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/loading.dart';
import '../providers/change_password_providers.dart';

class ProfileOtpScreen extends ConsumerStatefulWidget {
  final String email;
  const ProfileOtpScreen({super.key, required this.email});

  @override
  ConsumerState<ProfileOtpScreen> createState() => _ProfileOtpScreenState();
}

class _ProfileOtpScreenState extends ConsumerState<ProfileOtpScreen> {
  static const _otpLength = 6;
  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  int _seconds = 59;
  Timer? _timer;
  bool _isOtpFilled = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    for (final node in _focusNodes) {
      node.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        t.cancel();
      }
    });
  }

  void _resetTimer() {
    setState(() => _seconds = 59);
    _startTimer();
  }

  String get _enteredOtp => _controllers.map((c) => c.text).join();

  Future<void> _onVerify() async {
    final ok =
        await ref.read(verifyOtpNotifierProvider.notifier).verifyOtp(
              email: widget.email,
              otp: _enteredOtp,
            );
    if (ok && mounted) {
      context.pushNamed(
        Routes.newPassword.name,
        extra: ProfileNewPasswordArgs(
          email: widget.email,
          otp: _enteredOtp,
        ).toExtra(),
      );
    }
  }

  Future<void> _onResend() async {
    if (_seconds != 0) return;
    await ref
        .read(verifyOtpNotifierProvider.notifier)
        .resendOtp(widget.email);
    if (mounted) _resetTimer();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<VerifyOtpState>(verifyOtpNotifierProvider, (prev, next) {
      if (next.validationMessage != null &&
          next.validationMessage != prev?.validationMessage) {
        TopMessage.show(context, next.validationMessage!);
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        TopMessage.show(context, next.errorMessage!);
      }
    });
    final state = ref.watch(verifyOtpNotifierProvider);

    return AppScaffold(
      body: Padding(
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
                        onTap: () => context.pop(),
                        child: SvgPicture.asset(AppAssets.back),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Enter OTP code',
                        style: AppTextStyles.inherit20Bold.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Enter 6 digit OTP sent to your registered email ID\nreset your password.',
                        style: AppTextStyles.inherit.copyWith(
                          fontSize: 12,
                          color: AppColors.white60,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(_otpLength, (index) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xxs,
                              ),
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: AppRadii.lgAll,
                                  border: Border.all(
                                    color: (_focusNodes[index].hasFocus ||
                                            _controllers[index]
                                                .text
                                                .isNotEmpty)
                                        ? AppColors.borderGold
                                        : AppColors.white60,
                                    width: 0.5,
                                  ),
                                ),
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  style: AppTextStyles.inherit19Bold,
                                  decoration: const InputDecoration(
                                    counterText: '',
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _isOtpFilled = _controllers.every(
                                        (c) => c.text.trim().isNotEmpty,
                                      );
                                    });
                                    if (value.isNotEmpty &&
                                        index < _otpLength - 1) {
                                      FocusScope.of(context).nextFocus();
                                    }
                                    if (value.isEmpty && index > 0) {
                                      FocusScope.of(context).previousFocus();
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            _seconds == 0
                                ? '00:00'
                                : '00:${_seconds.toString().padLeft(2, '0')}',
                            style: AppTextStyles.bodyLargeStrong.copyWith(
                              color: AppColors.white60,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: _seconds == 0 ? _onResend : null,
                    child: Text(
                      'Resend OTP',
                      style: AppTextStyles.inherit15Bold.copyWith(
                        color: AppColors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (_isOtpFilled && !state.isSubmitting)
                      ? _onVerify
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isOtpFilled
                        ? AppColors.primary
                        : AppColors.goldOpacity40,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.xlAll,
                    ),
                  ),
                  child: state.isSubmitting
                      ? const AppCircularLoader(
                          size: 22,
                          strokeWidth: 2,
                          color: AppColors.black,
                        )
                      : Text(
                          'Continue',
                          style: AppTextStyles.inherit18Strong.copyWith(
                            color: _isOtpFilled
                                ? AppColors.textHeading
                                : AppColors.black38,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
    );
  }
}
