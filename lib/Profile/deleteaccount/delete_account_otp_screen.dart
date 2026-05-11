import 'dart:async';

import 'package:beige_creative_app/auth/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../utility/ColorCode.dart';
import '../../../utility/imges_icons.dart';
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

  bool isLoading =false;
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
  List<TextEditingController> controllers =
  List.generate(6, (index) => TextEditingController());




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
              onTap: () => Navigator.pop(context),
              child:SvgPicture.asset(
                AppImages.back, // make sure it's .svg file
                height: 24,
                colorFilter: ColorFilter.mode(
                  ColorCode.white,
                  BlendMode.srcIn,
                ),
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
                  onTap: () {
                    timer?.cancel();  // stop old timer
                    resetTimer();     // restart new timer
                  },
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
                onPressed:() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DeleteAccountLottieScreen()),
                  );
                },
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
