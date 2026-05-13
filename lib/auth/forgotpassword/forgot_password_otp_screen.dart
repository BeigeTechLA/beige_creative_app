import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../app/text_styles.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/colorcode.dart';
import '../../utility/imges_icons.dart';
import '../../widgets/Topmessgae.dart';
import '../resetpassword/reset_password_screen.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  final String email;
  const ForgotPasswordOtpScreen({super.key, required this.email});

  @override
  State<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
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

  List<TextEditingController> controllers =
  List.generate(6, (index) => TextEditingController());

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
    if (!isOtpFilled) {
      TopMessage.show(context, "Please enter complete OTP");
    }
    debugPrint("📢 Verify OTP Clicked");
    setState(() => isLoading = true);

    try {
      final response = await ApiService().postData(
        ApiEndpoints.forgotpasswordverifyotp,
        {
          "email": widget.email,
          "otp": enteredOtp,
        },
      );
      debugPrint("📩 API RESPONSE => $response");

      if (response == null) {
        TopMessage.show(context, 'Server Error');
      }

      if (response["error"] == false) {
        debugPrint("Calling The otp verification API");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              email: widget.email,
              otp: enteredOtp,
            ),
          ),
        );
      } else {
        print("❌ OTP Verification Failed => ${response['message']}");
        TopMessage.show(context, response['message'] ?? "Invalid OTP");
      }
    } catch (e) {
      debugPrint("error is:::::: $e");
      TopMessage.show(context, "Something went wrong");
    } finally {
      setState(() {
        isLoading = true;
      });
      debugPrint("🛑 VERIFY OTP API CALL END");
    }
  }

  Future<void> _resendOtp() async {
    if (seconds != 0) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService().postData(ApiEndpoints.forgotpassword, {
        "email": widget.email,
      });
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
                            AppImages.back,
                            height: 24,
                            color: ColorCode.white,
                          ),
                        ),
                      ),

                      /// 🏷️ TITLE + SUBTITLE (CENTER)
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            // ✅ WAS: TextStyle(fontFamily: "Unbounded", fontSize: 16, fontWeight: FontWeight.bold)
                            Text(
                              "Enter OTP code",
                              style: AppTextStyles.titleSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: ColorCode.white,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ✅ WAS: TextStyle(fontFamily: "Outfit", fontSize: 14)
                            Text(
                              "Enter 6 digit OTP sent to your\nregistered email ID.",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: ColorCode.kWhiteOpacity70,
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
                        padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: ColorCode.backgroundColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: ColorCode.white.withOpacity(0.06),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: (focusNodes[index].hasFocus ||
                                              controllers[index].text.isNotEmpty)
                                              ? ColorCode.kGoldBorder50
                                              : ColorCode.kWhiteOpacity60,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: TextField(
                                        controller: controllers[index],
                                        focusNode: focusNodes[index],
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        maxLength: 1,
                                        // ✅ WAS: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)
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
                                                    (c) => c.text.trim().isNotEmpty);
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

                            /// Timer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // ✅ WAS: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
                                Text(
                                  seconds == 0
                                      ? "00:00"
                                      : "00:${seconds.toString().padLeft(2, '0')}",
                                  style: AppTextStyles.labelLarge.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: ColorCode.kButtonColor,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            /// Resend
                            Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                // ✅ WAS: TextStyle(fontFamily: "Outfit", fontSize: 14, fontWeight: FontWeight.w400)
                                Text(
                                  "Didn't received the code?",
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: const Color(0xFFD5D5D5),
                                    height: 1.60,
                                  ),
                                ),
                                InkWell(
                                  onTap: seconds == 0 ? _resendOtp : null,
                                  // ✅ WAS: TextStyle(fontFamily: "Outfit", fontSize: 15, fontWeight: FontWeight.bold)
                                  child: Text(
                                    " Resend the Code",
                                    style: AppTextStyles.linkMedium.copyWith(
                                      color: ColorCode.kButtonColor,
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
                                      ? ColorCode.kButtonColor
                                      : ColorCode.kGoldGradientLight,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                // ✅ WAS: TextStyle(fontFamily: "Unbounded", fontSize: 13, fontWeight: FontWeight.w600)
                                child: Text(
                                  isOtpFilled ? "Submit" : "Continue",
                                  style: AppTextStyles.buttonSmall.copyWith(
                                    fontSize: 13,
                                    fontFamily: AppTextStyles.fontFamilyDisplay,
                                    color: isOtpFilled
                                        ? ColorCode.kHeadingColor
                                        : ColorCode.k282828,
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

  Widget _buildField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      cursorColor: ColorCode.white,
      // ✅ WAS: TextStyle(color: ColorCode.white)
      style: AppTextStyles.bodyMedium.copyWith(
        color: ColorCode.white,
      ),
      decoration: InputDecoration(
        labelText: "$title*",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        // ✅ WAS: TextStyle(color: ColorCode.kWhiteOpacity70)
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: ColorCode.kWhiteOpacity70,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kWhiteOpacity70,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kWhiteOpacity70,
            width: 0.5,
          ),
        ),
        // ✅ WAS: TextStyle(color: ColorCode.kWhiteOpacity70)
        floatingLabelStyle: AppTextStyles.bodyMedium.copyWith(
          color: ColorCode.kWhiteOpacity70,
        ),
      ),
    );
  }
}