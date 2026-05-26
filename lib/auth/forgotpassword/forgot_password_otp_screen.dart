import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app/spacing.dart';
import '../../app/text_styles.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../app/colors.dart';
import '../../app/radii.dart';
import 'package:beige_creative_app/app/assets.dart';
import '../../widgets/Topmessgae.dart';
import '../resetpassword/reset_password_screen.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  final String email;
  const ForgotPasswordOtpScreen({super.key, required this.email});

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  int seconds = 59;
  Timer? timer;
  bool isOtpFilled = false;

  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  String get enteredOtp {
    return controllers.map((c) => c.text).join();
  }

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    startTimer();

    for (var node in focusNodes) {
      node.addListener(() {
        setState(() {});
      });
    }
  }

  List<TextEditingController> controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      } else {
        timer!.cancel();
      }
    });
  }

  void resetTimer() {
    setState(() {
      seconds = 59;
    });
    startTimer();
  }

  Future<void> _verifyOtp() async {
    // ━━━ Validation ━━━
    if (!isOtpFilled) {
      TopMessage.show(context, "Please enter complete OTP");
      return; // ✅ return missing tha — bina return ke API call hoti thi
    }

    setState(() => isLoading = true);

    try {
      final response = await ApiService().postData(
        ApiEndpoints.forgotpasswordverifyotp,
        {"email": widget.email, "otp": enteredOtp},
      );

      debugPrint("📩 API RESPONSE => $response");

      // ━━━ Null check ━━━
      if (response == null) {
        TopMessage.show(context, "No response from server. Please try again.");
        return; // ✅ return missing tha — null pe bhi neeche chalta tha
      }

      // ━━━ Success ━━━
      if (response["error"] == false) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ResetPasswordScreen(email: widget.email, otp: enteredOtp),
          ),
        );
      }
      // ━━━ API Error ━━━
      else {
        final message = response['message'];

        if (message == null || message.toString().trim().isEmpty) {
          TopMessage.show(context, "Invalid OTP. Please try again.");
        } else {
          TopMessage.show(context, message.toString());
        }
      }
    } on SocketException {
      // No internet
      TopMessage.show(
        context,
        "No internet connection. Please check your network.",
      );
    } on TimeoutException {
      // Server timeout
      TopMessage.show(context, "Request timed out. Please try again.");
    } on FormatException {
      // JSON parse fail
      TopMessage.show(context, "Unexpected server response. Please try again.");
    } catch (e) {
      debugPrint("❌ OTP Error: $e");
      TopMessage.show(context, "OTP verification failed. Please try again.");
    } finally {
      setState(() => isLoading = false); //
    }
  }

  Future<void> _resendOtp() async {
    if (seconds != 0) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService().postData(
        ApiEndpoints.forgotpassword,
        {"email": widget.email},
      );
      if (response["error"] == false) {
        debugPrint("Resend OTP Is Sent Successfully");
        debugPrint("🛑Again Successfully Called The Resend OTP API");
      } else {
        TopMessage.show(context, response['message'] ?? "Failed to resend OTP");
      }
    } catch (e) {
      TopMessage.show(context, "Something went wrong $e");
    } finally {
      setState(() {
        isLoading = false;
      });
      timer?.cancel();
      resetTimer();
    }
  }

  void _showSnack(String message) {
    TopMessage.show(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                /// 🔝 TOP IMAGE + TITLE SECTION
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.32,
                  child: Stack(
                    children: [
                      /// 🔙 BACK BUTTON
                      Positioned(
                        top: 50,
                        left: 16,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: SvgPicture.asset(
                            AppAssets.back,
                            height: 24,
                            color: AppColors.white,
                          ),
                        ),
                      ),

                      /// 🏷️ TITLE + SUBTITLE (CENTER)
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

                /// 📦 FORM CONTAINER
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

                            /// OTP Fields
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
                                          color:
                                              (focusNodes[index].hasFocus ||
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
                                            FocusScope.of(
                                              context,
                                            ).previousFocus();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 10),

                            /// Timer
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

                            /// Resend
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
                                  onTap: seconds == 0 ? _resendOtp : null,
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

                            /// Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isOtpFilled ? _verifyOtp : null,
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
        ],
      ),
    );
  }
}
