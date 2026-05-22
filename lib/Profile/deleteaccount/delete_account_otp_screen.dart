import 'dart:async';

import 'package:beige_creative_app/auth/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../utility/colorcode.dart';
import '../../../utility/imges_icons.dart';
import '../../app/route_names.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../widgets/Topmessgae.dart';
import 'delete_account_lottieScreen.dart';


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
        padding:  EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔙 BACK BUTTON
            InkWell(
              onTap: () => context.pop(),
              child:SvgPicture.asset(
                AppImages.back, // make sure it's .svg file
                height: 24,

              ),
            ),

            SizedBox(height: 16),

            /// 🏷 TITLE
            Text(
              "Delete Account",
              style: TextStyle(
                fontFamily: "Unbounded",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorCode.white,
              ),
            ),

            const SizedBox(height: 20),


            Text(
              "Please note this is permanent and can't be undone. To confirm deleting your account, please enter your Email ID below.",

              style: TextStyle(
                  fontSize: 14,
                  color: ColorCode.kWhiteOpacity70,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Outfit"
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),

                        // ⭐ Border color logic
                        border: Border.all(
                          color: (focusNodes[index].hasFocus ||
                              controllers[index].text.isNotEmpty)
                              ? ColorCode.kButtonColor
                              : ColorCode.kWhiteOpacity60,
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: controllers[index],          // ⭐ added controller
                        focusNode: focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorCode.kWhiteOpacity60,
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
                    style: TextStyle(
                      color: ColorCode.kWhiteOpacity60,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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
                      ? ColorCode.kButtonColor
                      : ColorCode.kGold40,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child:Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isOtpFilled
                        ? ColorCode.kHeadingColor
                        : ColorCode.black,
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
