import 'package:flutter/material.dart';
import '../../utility/ColorCode.dart';
import '../NewPassword/new_password_screen.dart';
import 'otp_controller.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final OtpController otp = OtpController();

  @override
  void initState() {
    super.initState();
    otp.startTimer(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    otp.dispose();
    super.dispose();
  }

  void verifyOtp() async {
    setState(() {
      otp.isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      otp.isLoading = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewPasswordScreen(),
      ),
    );
    print("OTP: ${otp.getOtp()}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.bcakgroundcolor,
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// 🔝 TOP IMAGE SECTION
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.28,
              child: Stack(
                children: [

                  Positioned.fill(
                    child: Image.asset(
                      "assets/images/Rectangle_574057023.png",
                      fit: BoxFit.cover,
                    ),
                  ),

                  Positioned(
                    top: 50,
                    left: 16,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        "assets/icons/Reply.png",
                        height: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "Enter OTP code",
                          style: TextStyle(
                            fontFamily: "Unbounded",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Enter 6 digit OTP sent to your\nregistered email ID.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Outfit",
                            fontSize: 14,
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
              offset: const Offset(0, -40),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.fromLTRB(20, 36, 20, 24),
                decoration: BoxDecoration(
                  color: ColorCode.bcakgroundcolor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
                child: Column(
                  children: [

                    /// OTP BOXES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 45,
                          child: TextField(
                            controller: otp.controllers[index],
                            focusNode: otp.focusNodes[index],
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: "",
                              filled: true,
                              fillColor: Colors.black12,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: otp.controllers[index].text.isNotEmpty
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
                              otp.checkOtpFilled(() {
                                setState(() {});
                              });

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


                    Text(
                      otp.seconds > 0
                          ? "00:${otp.seconds.toString().padLeft(2, '0')}"
                          : "00:00",
                      style: const TextStyle(
                        color: ColorCode.kWhiteOpacity60,
                      ),
                    ),

                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Didn’t receive the code? ",
                          style: TextStyle(
                            color: ColorCode.white,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Unbounded",
                          ),
                        ),
                        GestureDetector(
                          onTap: otp.seconds == 0
                              ? () {
                            otp.resendOtp(() {
                              setState(() {});
                            });

                            print("OTP Resent Successfully");
                          }
                              : null,
                          child: Text(
                            "Resend OTP",
                            style: TextStyle(
                              color: otp.seconds == 0
                                  ? ColorCode.kGoldGradientLight
                                  : ColorCode.kWhiteOpacity60,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    /// VERIFY BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                        otp.isOtpFilled ? verifyOtp : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          ColorCode.kGoldGradientLight,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                        ),
                        child: otp.isLoading
                            ? const SizedBox(
                          height: 22,
                          width: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                            : const Text(
                          "Submit",
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

            const SizedBox(height: 20),
          ],
        ),
      ),

      /// BOTTOM TEXT
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        color: ColorCode.bcakgroundcolor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Don’t have an account? ",
              style: TextStyle(
                color: ColorCode.kWhiteOpacity60,
                fontSize: 14,
              ),
            ),
            Text(
              "Sign Up",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}