import 'dart:async';

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
import '../../../../shared/widgets/top_message.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../providers/delete_account_providers.dart';

class DeleteAccountOtpScreen extends ConsumerStatefulWidget {
  const DeleteAccountOtpScreen({super.key});

  @override
  ConsumerState<DeleteAccountOtpScreen> createState() =>
      _DeleteAccountOtpScreenState();
}

class _DeleteAccountOtpScreenState
    extends ConsumerState<DeleteAccountOtpScreen> {
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

  Future<void> _onContinue() async {
    final ok = await ref
        .read(deleteAccountNotifierProvider.notifier)
        .confirmDelete(_enteredOtp);
    if (ok && mounted) {
      context.goNamed(Routes.deleteAccountSuccess.name);
    }
  }

  Future<void> _onResend() async {
    if (_seconds != 0) return;
    await ref.read(deleteAccountNotifierProvider.notifier).resendOtp();
    if (!mounted) return;
    TopMessage.show(context, 'OTP sent');
    _resetTimer();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<DeleteAccountState>(deleteAccountNotifierProvider,
        (prev, next) {
      if (next.validationMessage != null &&
          next.validationMessage != prev?.validationMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.validationMessage!)),
        );
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });
    final state = ref.watch(deleteAccountNotifierProvider);

    return AppScaffold(
      body: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => context.pop(),
                child: SvgPicture.asset(AppAssets.back, height: 24),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete Account',
                style: AppTextStyles.displayStrong16w600.copyWith(
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Please note this is permanent and can't be undone. To confirm deleting your account, please enter your Email ID below.",
                style: AppTextStyles.body14LineRelaxed.copyWith(
                  color: AppColors.white30,
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
                                    _controllers[index].text.isNotEmpty)
                                ? AppColors.primary
                                : AppColors.white60,
                            width: 1.5,
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
                            if (value.isNotEmpty && index < _otpLength - 1) {
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
                    '00:${_seconds.toString().padLeft(2, '0')}',
                    style: AppTextStyles.inherit16Strong.copyWith(
                      color: AppColors.white60,
                    ),
                  ),
                ],
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
                        color: AppColors.white60,
                        decoration: TextDecoration.underline,
                        decorationThickness: 1.5,
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
                      ? _onContinue
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
                          'Continue',
                          style: AppTextStyles.inherit18Strong.copyWith(
                            color: _isOtpFilled
                                ? AppColors.textHeading
                                : AppColors.black,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
