import 'dart:async';

import 'package:beige_creative_app/Profile/ChangePassword/resent_passwrod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../utility/ColorCode.dart';
import '../../service/api_service.dart';
import '../../service/api_endpoints.dart';
import '../../utility/imges_icons.dart';
import '../../widgets/Topmessgae.dart';
import '../NewPasswrod/myprofile_new_passwrod_screen.dart';

class EnterOtpScreen extends StatefulWidget {
  final String? email;
  const EnterOtpScreen({super.key, this.email});

  @override
  State<EnterOtpScreen> createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {


  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {

    timer?.cancel();

    for (var c in controllers) {
      c.dispose();
    }

    for (var f in focusNodes) {
      f.dispose();
    }

    super.dispose();
  }
  final List<TextEditingController> controllers =
  List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
  List.generate(6, (_) => FocusNode());

  bool isOtpFilled = false;
  bool isLoading = false;

  int seconds = 60;
  Timer? timer;
  /// ✅ VERIFY OTP (API CONNECTED)
  Future<void> verifyOtp() async {

    if (!isOtpFilled) return;

    setState(() {
      isLoading = true;
    });

    try {

      final enteredOtp = getOtp();

      final response = await ApiService().postData(
        ApiEndpoints.forgotpasswordverifyotp,
        {
          "email": widget.email,
          "otp": enteredOtp,
        },
      );

      if (response == null) {

        TopMessage.show(
          context,
          "Server Error",
        );

        return;
      }

      if (response["error"] == false) {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => resentpasswrod(
              email: widget.email,
              otp: enteredOtp,
            ),
          ),
        );

      } else {

        TopMessage.show(
          context,
          response["message"] ?? "Invalid OTP",
        );

      }

    } catch (e) {

      TopMessage.show(
        context,
        "Something went wrong",
      );

    } finally {

      setState(() {
        isLoading = false;
      });

    }
  }

  /// ✅ RESEND OTP (API CONNECTED)
  Future<void> resendOtp() async {

    if (seconds != 0) return;

    setState(() {
      isLoading = true;
    });

    try {

      final response = await ApiService().postData(
        ApiEndpoints.forgotpassword,
        {
          "email": widget.email,
        },
      );

      if (response["error"] == false) {

        TopMessage.show(
          context,
          "OTP Resent Successfully",
        );

        startTimer();

        for (var c in controllers) {
          c.clear();
        }

        setState(() {
          isOtpFilled = false;
        });

      } else {

        TopMessage.show(
          context,
          response["message"] ?? "Failed to resend OTP",
        );

      }

    } catch (e) {

      TopMessage.show(context, "Something went wrong");

    } finally {

      setState(() {
        isLoading = false;
      });

    }
  }
  void startTimer() {
    timer?.cancel();

    seconds = 60;

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (t) {
        if (seconds > 0) {
          setState(() {
            seconds--;
          });
        } else {
          t.cancel();
        }
      },
    );
  }

  void checkOtpFilled() {
    setState(() {
      isOtpFilled =
          controllers.every((c) => c.text.trim().isNotEmpty);
    });
  }

  String getOtp() {
    return controllers.map((c) => c.text).join();
  }
  /// ✅ RESEND OTP (API CONNECTED)
  /*Future<void> resendOtp() async {
    if (otseconds != 0) return;

    setState(() {
      otp.isLoading = true;
    });

    try {
      final response = await ApiService().postData(
        ApiEndpoints.forgotpassword,
        {
          "email": widget.email,
        },
      );

      if (response["error"] == false) {
        TopMessage.show(context, "OTP Resent Successfully");

        otp.startTimer(() {
          setState(() {});
        });
      } else {
        TopMessage.show(
            context, response["message"] ?? "Failed to resend OTP");
      }
    } catch (e) {
      TopMessage.show(context, "Something went wrong");
    } finally {
      setState(() {
        otp.isLoading = false;
      });
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40,),
          InkWell(
                    onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              AppImages.back,
              height: 25,
              colorFilter: const ColorFilter.mode(
                ColorCode.white,
                BlendMode.srcIn,
              ),
            ),
                  ),
              SizedBox(height: 20,),

                          Text(
                            "Enter OTP code",
                            style: TextStyle(
                              fontFamily: "Unbounded",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,//
                              color: ColorCode.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Enter 6 digit OTP sent to your registered email ID",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 14,
                              color: ColorCode.kWhiteOpacity70,
                            ),
                          ),
              Text(
                "Change your Password.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Outfit",
                  fontSize: 14,
                  color: ColorCode.kWhiteOpacity70,
                ),
              ),

              SizedBox(height: 50,),


              /// 🔝 TOP
              // SizedBox(
              //   height: MediaQuery.of(context).size.height * 0.28,
              //   child: Stack(
              //     children: [
              //
              //       Positioned(
              //         top: 50,
              //         left: 16,
              //         child: InkWell(
              //           onTap: () => Navigator.pop(context),
              //           child: Image.asset(
              //             "assets/icons/Reply.png",
              //             height: 24,
              //             color: ColorCode.white,
              //           ),
              //         ),
              //       ),
              //
              //       Padding(
              //         padding: const EdgeInsets.all(18.0),
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //         //  mainAxisSize: MainAxisSize.min,
              //           children: const [
              //             SizedBox(height: 70,),
              //             Text(
              //               "Enter OTP code",
              //               style: TextStyle(
              //                 fontFamily: "Unbounded",
              //                 fontSize: 16,
              //                 fontWeight: FontWeight.bold,//
              //                 color: ColorCode.white,
              //               ),
              //             ),
              //             SizedBox(height: 10),
              //             Text(
              //               "Enter 6 digit OTP sent to your registered email ID Change your Password.",
              //               textAlign: TextAlign.center,
              //               style: TextStyle(
              //                 fontFamily: "Outfit",
              //                 fontSize: 14,
              //                 color: ColorCode.kWhiteOpacity70,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              /// 📦 FORM
              Transform.translate(
                offset: const Offset(0, -40),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [

                      /// OTP BOXES
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 45,
                            child: TextField(
                              controller: controllers[index],
                              focusNode: focusNodes[index],
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                color: ColorCode.white,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                counterText: "",
                                filled: true,
                                fillColor: ColorCode.black,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: controllers[index].text.isNotEmpty
                                        ? ColorCode.kButtonColor
                                        : ColorCode.kWhiteOpacity60,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: ColorCode.kButtonColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) {

                                checkOtpFilled();

                                if (value.isNotEmpty && index < 5) {
                                  FocusScope.of(context).nextFocus();
                                }

                                if (value.isEmpty && index > 0) {
                                  FocusScope.of(context).previousFocus();
                                }
                              },
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 25),

                      /// TIMER
                      Row(
                        children: [
                          Text(
                            seconds > 0
                                ? "00:${seconds.toString().padLeft(2, '0')}"
                                : "00:00",
                            style: const TextStyle(
                              color: ColorCode.kWhiteOpacity60,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      /// RESEND
                      GestureDetector(
                        onTap: seconds == 0 ? resendOtp : null,
                        child: Text(
                          "Resend OTP",
                          style: TextStyle(
                            color: seconds == 0
                                ? ColorCode.kGoldGradientLight
                                : ColorCode.kWhiteOpacity60,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                          isOtpFilled ? verifyOtp : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            ColorCode.kGoldGradientLight,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                          ),
                          child:const Text(
                            "Continue",
                            style: TextStyle(
                              fontFamily: "Unbounded",
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color:
                              ColorCode.kHeadingColor,
                            ),
                          ),
                        ),
                      ),
                    ],
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