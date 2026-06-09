import 'dart:async';

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
import '../../../../shared/widgets/top_message.dart';
import '../providers/forgot_password_notifier.dart';
import '../providers/forgot_password_state.dart';

class ForgotPasswordOtpScreen extends ConsumerStatefulWidget {
  final String email;
  const ForgotPasswordOtpScreen({super.key, required this.email});

  @override
  ConsumerState<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState
    extends ConsumerState<ForgotPasswordOtpScreen> {
  static const int _timerStart = 59;

  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  int seconds = _timerStart;
  Timer? timer;
  bool isOtpFilled = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    for (final node in focusNodes) {
      node.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    for (final c in controllers) {
      c.dispose();
    }
    for (final n in focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get enteredOtp => controllers.map((c) => c.text).join();

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds > 0) {
        setState(() => seconds--);
      } else {
        t.cancel();
      }
    });
  }

  void _resetTimer() {
    setState(() => seconds = _timerStart);
    _startTimer();
  }

  Future<void> _verify() async {
    final ok = await ref
        .read(forgotPasswordNotifierProvider.notifier)
        .verifyOtp(email: widget.email, otp: enteredOtp);
    if (!ok || !mounted) return;
    context.pushNamed(
      Routes.resetPassword.name,
      extra: {'email': widget.email, 'otp': enteredOtp},
    );
  }

  Future<void> _resend() async {
    if (seconds != 0) return;
    await ref
        .read(forgotPasswordNotifierProvider.notifier)
        .resendOtp(widget.email);
    if (!mounted) return;
    _resetTimer();
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
          next.toastMessage != prev?.toastMessage) {
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
                  Positioned(
                    top: AppSpacing.md,
                    left: 16,
                    child: InkWell(
                      onTap: () => context.pop(),
                      child: SvgPicture.asset(
                        AppAssets.back,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Enter OTP code",
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Enter 6 digit OTP sent to your\nregistered email ID.",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white30,
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
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.06),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xxs,
                                ),
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadii.lgAll,
                                    border: Border.all(
                                      color: (focusNodes[index].hasFocus ||
                                              controllers[index]
                                                  .text
                                                  .isNotEmpty)
                                          ? AppColors.borderGold
                                          : AppColors.white60,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: controllers[index],
                                    focusNode: focusNodes[index],
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    style: AppTextStyles.otpDigit.copyWith(
                                      fontSize: 19,
                                    ),
                                    decoration: const InputDecoration(
                                      counterText: "",
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        isOtpFilled = controllers.every(
                                          (c) => c.text.trim().isNotEmpty,
                                        );
                                      });
                                      if (value.isNotEmpty && index < 5) {
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              seconds == 0
                                  ? "00:00"
                                  : "00:${seconds.toString().padLeft(2, '0')}",
                              style: AppTextStyles.labelLarge.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              "Didn't received the code?",
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textLightNeutral,
                                height: 1.60,
                              ),
                            ),
                            InkWell(
                              onTap: (seconds == 0 && !state.isResending)
                                  ? _resend
                                  : null,
                              child: Text(
                                " Resend the Code",
                                style: AppTextStyles.linkMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: (isOtpFilled && !state.isSubmitting)
                                ? _verify
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isOtpFilled
                                  ? AppColors.primary
                                  : AppColors.borderGold,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadii.xlAll,
                              ),
                            ),
                            child: Text(
                              isOtpFilled ? "Submit" : "Continue",
                              style: AppTextStyles.buttonSmall.copyWith(
                                fontSize: 13,
                                fontFamily: AppTextStyles.fontFamilyDisplay,
                                color: isOtpFilled
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
