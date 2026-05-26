import 'dart:async';

import 'package:beige_creative_app/app/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../app/route_names.dart';
import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../app/colors.dart';
import '../app/radii.dart';
import '../app/spacing.dart';
import '../app/text_styles.dart';
import '../widgets/Topmessgae.dart';

class ProfileOtpScreen extends StatefulWidget {
  final String email;

  const ProfileOtpScreen({super.key, required this.email});

  @override
  State<ProfileOtpScreen> createState() => _ProfileOtpScreenState();
}

class _ProfileOtpScreenState extends State<ProfileOtpScreen> {
  int seconds = 59;
  Timer? timer;
  bool isOtpFilled = false;

  // ⭐ 6 FocusNodes for 6 OTP boxes
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  String get enteredOtp {
    return controllers.map((c) => c.text).join();
  }

  bool isLoading = false;

  Future<void> _verifyOtp() async {
    if (!isOtpFilled) {
      print("❌ OTP Not Filled Completely");
      _showSnack("Please enter complete OTP");
      return;
    }

    print("📢 Verify OTP Clicked");

    print("🔢 Entered OTP => $enteredOtp");

    setState(() => isLoading = true);

    try {
      final apiService = ApiService();

      print("🚀 VERIFY OTP API CALL START");
      print("📡 Endpoint => ${ApiEndpoints.forgotpasswordverifyotp}");

      final response = await apiService.postData(
        ApiEndpoints.forgotpasswordverifyotp,
        {"email": widget.email, "otp": enteredOtp},
      );

      print("📩 API RESPONSE => $response");

      if (response == null) {
        print("❌ Response NULL");
        _showSnack("Server error");
        return;
      }

      if (response['error'] == false) {
        print("✅ OTP Verified Successfully");

        if (!mounted) return;
        context.pushNamed(
          RouteNames.newPassword,
          extra: {"email": widget.email, "otp": enteredOtp},
        );
        /*  Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MyprofileNewPasswordScreen(
                otp: enteredOtp ,
                email: widget.email,
              ),
            ),
          );*/
      } else {
        print("❌ OTP Verification Failed => ${response['message']}");
        _showSnack(response['message'] ?? "Invalid OTP");
      }
    } catch (e) {
      print("🔥 Exception => $e");
      _showSnack("Invalid or expired OTP");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
      print("🛑 VERIFY OTP API CALL END");
    }
  }

  Future<void> _resendOtp() async {
    if (seconds != 0) {
      print("⛔ Wait for timer to finish");
      return;
    }

    setState(() => isLoading = true);

    try {
      final apiService = ApiService();

      final response = await apiService.postData(ApiEndpoints.restartpassword, {
        "email": widget.email,
      });

      print("RESEND OTP RESPONSE => $response");

      if (response['error'] == false) {
        timer?.cancel();
        resetTimer();
      } else {
        _showSnack(response['message'] ?? "Failed to resend OTP");
      }
    } catch (e) {
      print("ERROR => $e");
      _showSnack("Something went wrong");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnack(String message) {
    TopMessage.show(context, message);
  }

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
      seconds = 59; // timer reset
    });
    startTimer(); // start again
  }

  @override
  void initState() {
    super.initState();
    startTimer();

    // ⭐ refresh UI on focus change
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

  @override
  Widget build(BuildContext context) {
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
                        onTap: () => Navigator.pop(context),
                        child: SvgPicture.asset(AppAssets.back),
                      ),
                      SizedBox(height: 10),

                      Text(
                        "Enter OTP code",
                        style: AppTextStyles.inherit20Bold.copyWith(
                          color: AppColors.white,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Enter 6 digit OTP sent to your registered email ID\nreset your password.",
                        style: AppTextStyles.inherit.copyWith(
                          fontSize: 12,
                          color: AppColors.white60,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ⭐ OTP BOXES WITH FOCUS COLOR CHANGE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xxs,
                              ),
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: AppRadii.lgAll,

                                  // ⭐ Border color logic
                                  border: Border.all(
                                    color:
                                        (focusNodes[index].hasFocus ||
                                            controllers[index].text.isNotEmpty)
                                        ? AppColors.borderGold
                                        : AppColors.white60,
                                    width: 0.5,
                                  ),
                                ),
                                child: TextField(
                                  controller:
                                      controllers[index], // ⭐ added controller
                                  focusNode: focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  style: AppTextStyles.inherit19Bold,
                                  decoration: const InputDecoration(
                                    counterText: "",
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      isOtpFilled = controllers.every(
                                        (c) => c.text.trim().isNotEmpty,
                                      );
                                    }); // ⭐ refresh for color update

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
                        children: [
                          Text(
                            seconds == 0
                                ? "00:00"
                                : "00:${seconds.toString().padLeft(2, '0')}",
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
                    onTap: seconds == 0 ? _resendOtp : null,
                    child: Text(
                      "Resend OTP",
                      style: AppTextStyles.inherit15Bold.copyWith(
                        color: seconds == 0 ? AppColors.white : AppColors.white,
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
                  onPressed: isOtpFilled ? _verifyOtp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOtpFilled
                        ? AppColors.primary
                        : AppColors.goldOpacity40,
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.xlAll),
                  ),
                  child: Text(
                    "Continue",
                    style: AppTextStyles.inherit18Strong.copyWith(
                      color: isOtpFilled
                          ? AppColors.textHeading
                          : AppColors.black38,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
