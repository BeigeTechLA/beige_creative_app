import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart';
import '../../app/route_names.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../widgets/Topmessgae.dart';


class DeleteAccountOtpScreen extends StatefulWidget {
  const DeleteAccountOtpScreen({super.key});

  @override
  State<DeleteAccountOtpScreen> createState() => _DeleteAccountOtpScreenState();
}

class _DeleteAccountOtpScreenState extends State<DeleteAccountOtpScreen> {
  int seconds = 59;
  Timer? timer;
  bool isOtpFilled = false;
  bool isLoading = false;
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  String get enteredOtp {
    return controllers.map((c) => c.text).join();
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
      seconds = 59;      // timer reset
    });
    startTimer();        // start again
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
  @override
  void dispose() {

    timer?.cancel();

    for (var controller in controllers) {
      controller.dispose();
    }

    for (var node in focusNodes) {
      node.dispose();
    }

    super.dispose();
  }
  List<TextEditingController> controllers =
  List.generate(6, (index) => TextEditingController());

  Future<void> _deleteAccountOtp() async {

    setState(() {
      isLoading = true;
    });

    try {

      final response = await ApiService().postData(
        ApiEndpoints.account_deleted_otp,
        {
          "otp": enteredOtp,
        },
      );

      debugPrint("OTP RESPONSE => $response");

      if (response.error == false) {

        context.goNamed(
          RouteNames.deleteAccountSuccess,
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message ?? "Invalid OTP",
            ),
          ),
        );
      }

    } catch (e) {

      debugPrint("ERROR => $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );

    } finally {

      setState(() {
        isLoading = false;
      });

    }
  }
  Future<void> _resendOtp() async {
    if (seconds != 0) return; // safety check

    setState(() => isLoading = true);

    try {
      final response = await ApiService().postData(
        ApiEndpoints.restartpassword,
        {
          // 👇 jo required field ho (email / phone)
          // "email": widget.email,
        },
      );

      if (response != null && response['error'] == false) {
        TopMessage.show(context, "OTP sent successfully");

        timer?.cancel();  // old timer stop
        resetTimer();     // restart 59 sec

      } else {
        TopMessage.show(context, response['message'] ?? "Failed to resend OTP");
      }

    } catch (e) {
      TopMessage.show(context, "Something went wrong");
    } finally {
      setState(() => isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child:
      Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔙 BACK BUTTON
            InkWell(
              onTap: () => context.pop(),
              child:SvgPicture.asset(
                AppAssets.back, // make sure it's .svg file
                height: 24,

              ),
            ),

            SizedBox(height: 16),

            /// 🏷 TITLE
            Text(
              "Delete Account",
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
                          color: (focusNodes[index].hasFocus ||
                              controllers[index].text.isNotEmpty)
                              ? AppColors.primary
                              : AppColors.white60,
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: controllers[index],          // ⭐ added controller
                        focusNode: focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: AppTextStyles.system19Bold,
                        decoration: const InputDecoration(
                          counterText: "",
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            isOtpFilled = controllers.every((c) => c.text.trim().isNotEmpty);
                          }
                          ); // ⭐ refresh for color update

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
                  "00:${seconds.toString().padLeft(2, '0')}",
                  style: AppTextStyles.system16Strong.copyWith(
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
                  onTap: seconds == 0 ? _resendOtp : null,
                  child: Text(
                    "Resend OTP",
                    style: AppTextStyles.system15Bold.copyWith(
                      color: AppColors.white60,
                      decoration: TextDecoration.underline,
                      decorationThickness: 1.5,
                    ),
                  ),
                )

              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                  onPressed: isOtpFilled && !isLoading
                      ? () {
                    _deleteAccountOtp();
                  }

                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOtpFilled
                      ? AppColors.primary
                      : AppColors.goldOpacity40,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.xlAll,
                  ),
                ),
                child: Text(
                  "Continue",
                  style: AppTextStyles.system18Strong.copyWith(
                    color: isOtpFilled
                        ? AppColors.textHeading
                        : AppColors.black,
                  ),
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
