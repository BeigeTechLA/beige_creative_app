import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';
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

    // ⭐ refresh UI on focus change
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
      seconds = 59;      // timer reset
    });
    startTimer();        // start again
  }

  Future<void>_verifyOtp()async{

if(!isOtpFilled){
  TopMessage.show(context,"Please enter complete OTP");
}
debugPrint("📢 Verify OTP Clicked");
setState(() => isLoading = true);


try{
  final response= await ApiService().postData(
      ApiEndpoints.forgotpasswordverifyotp,
      {
        "email":widget.email,
        "otp":enteredOtp,
      }
  );
  debugPrint("📩 API RESPONSE => $response");

  if(response==null){
    TopMessage.show(context, 'Server Error');
  }


  if(response["error"]==false){
    debugPrint("Calling The otp verification API");
    Navigator.push(context, MaterialPageRoute(builder:(context) => ResetPasswordScreen(email:widget.email,otp: enteredOtp,),));
  }else {
          print("❌ OTP Verification Failed => ${response['message']}");
          TopMessage.show(context,response['message'] ?? "Invalid OTP");
        }




}catch(e){
  debugPrint("error is:::::: $e");
  TopMessage.show(context,"Something went wrong");
}finally{
  setState((){
    isLoading=true;
  });
  debugPrint("🛑 VERIFY OTP API CALL END");

}



  }

  // Future<void> _verifyOtp() async {
  //   if (!isOtpFilled) {
  //     print("❌ OTP Not Filled Completely");
  //     _showSnack("Please enter complete OTP");
  //     return;
  //   }
  //
  //   print("📢 Verify OTP Clicked");
  //   print("📧 Email => ${widget.email}");
  //   print("🔢 Entered OTP => $enteredOtp");
  //
  //   setState(() => isLoading = true);
  //
  //   try {
  //     final apiService = ApiService();
  //
  //     print("🚀 VERIFY OTP API CALL START");
  //     print("📡 Endpoint => ${ApiEndpoints.forgotpassword_verify_otp}");
  //
  //     final response = await apiService.postData(
  //       ApiEndpoints.forgotpassword_verify_otp,
  //       {
  //         "email": widget.email,
  //         "otp": enteredOtp,
  //       },
  //     );
  //
  //     print("📩 API RESPONSE => $response");
  //
  //     if (response == null) {
  //       print("❌ Response NULL");
  //       _showSnack("Server error");
  //       return;
  //     }
  //
  //     if (response['error'] == false) {
  //       print("✅ OTP Verified Successfully");
  //
  //       if (!mounted) return;
  //
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (_) => NewNewPasswrodScreen(
  //             otp: enteredOtp ,
  //             email: widget.email,
  //           ),
  //         ),
  //       );
  //     } else {
  //       print("❌ OTP Verification Failed => ${response['message']}");
  //       _showSnack(response['message'] ?? "Invalid OTP");
  //     }
  //   } catch (e) {
  //     print("🔥 Exception => $e");
  //     _showSnack("Something went wrong");
  //   } finally {
  //     if (mounted) {
  //       setState(() => isLoading = false);
  //     }
  //     print("🛑 VERIFY OTP API CALL END");
  //   }
  // }



  Future<void> _resendOtp()async{
    if(seconds !=0) return;

    setState(() {//
      isLoading=true;
    });

    try{

      final response=await ApiService().postData(ApiEndpoints.forgotpassword,{
        "email":widget.email,
      });
      if(response["error"]==false){
        debugPrint("Resend OTP Is Sent Successfully");
        debugPrint("🛑Again Successfully Called The Resend OTP API");

      }else{
        TopMessage.show(context,response['message'] ?? "Failed to resend OTP");
      }


    }catch(e){
      TopMessage.show(context, "Something went wrong $e");

    }finally{
      setState(() {
        isLoading=false;
      });
            timer?.cancel();   // old timer stop
            resetTimer();

    }

  }





  // Future<void> _resendOtp() async {
  //
  //   if (seconds != 0) return;   // ⛔ 60 sec se pehle click disable
  //
  //   setState(() => isLoading = true);
  //
  //   try {
  //     final apiService = ApiService();
  //
  //     final response = await apiService.postData(
  //       ApiEndpoints.forgotpasswordverifyotp,
  //       {
  //         "email": widget.email,
  //       },
  //     );
  //
  //     if (response['error'] == false) {
  //
  //
  //       timer?.cancel();   // old timer stop
  //       resetTimer();      // start again
  //
  //     } else {
  //       _showSnack(response['message'] ?? "Failed to resend OTP");
  //     }
  //   } catch (e) {
  //     _showSnack("Something went wrong");
  //   } finally {
  //     setState(() => isLoading = false);
  //   }
  // }

  void _showSnack(String message) {
    TopMessage.show(context, message);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: ColorCode.white,
      body: Stack(
        children:[
          SingleChildScrollView(
            child: Column(
              children: [

                /// 🔝 TOP IMAGE + TITLE SECTION
                SizedBox(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.32,
                  child: Stack(
                    children: [

                      /// 🖼️ BACKGROUND IMAGE
                     /* Positioned.fill(
                        child: Image.asset(
                          "assets/images/Rectangle_574057023.png",
                          fit: BoxFit.fill,
                        ),
                      ),*/

                      /// 🌫️ DARK OVERLAY
                      /*    Positioned.fill(
                      child: Container(
                        color: ColorCode.black.withOpacity(0.55),
                      ),
                    )*/

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
                          children: const [

                            Text(
                              "Enter OTP code",
                              style: TextStyle(
                                fontFamily: "Unbounded",
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                ColorCode.white,
                              ),
                            ),

                            SizedBox(height: 8),

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

                /// 📦 FORM CONTAINER (NICHE)
                Transform.translate(
                  offset: const Offset(0, -70),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [


                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
                        // 👈 top extra
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

                                        // ⭐ Border color logic
                                        border: Border.all(
                                          color: (focusNodes[index].hasFocus ||
                                              controllers[index].text.isNotEmpty)
                                              ? ColorCode.kGoldBorder50
                                              : ColorCode.kWhiteOpacity60,
                                          width: 0.5,
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  seconds == 0
                                      ? "00:00"
                                      : "00:${seconds.toString().padLeft(2, '0')}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: ColorCode.kButtonColor,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                Text(
                                  "Didn’t received the code?",
                                  style: TextStyle(
                                    color: const Color(0xFFD5D5D5),
                                    fontSize: 14,
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w400,
                                    height: 1.60,
                                  ),
                                ),
                                InkWell(
                                  onTap: seconds == 0 ? _resendOtp : null,
                                  child: Text(
                                    " Resend the Code",
                                    style: TextStyle(
                                      color: seconds == 0
                                          ? ColorCode.kButtonColor
                                          : ColorCode.kButtonColor,
                                      fontSize: 15,
                                      fontFamily: "Outfit",
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
                                onPressed: isOtpFilled ? _verifyOtp : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isOtpFilled
                                      ? ColorCode.kButtonColor
                                      : ColorCode.kGoldGradientLight,

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  isOtpFilled ? "Submit" : "Continue",
                                  style: TextStyle(
                                    fontFamily: "Unbounded",
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
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

                      /// 🏷️ FLOATING CHIP (BORDER PE STUCK)
                      /*           Positioned(
                      top: -24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 50,
                          decoration: BoxDecoration(
                            color: ColorCode.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: ColorCode.white.withOpacity(0.12),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ColorCode.black.withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(
                                        "assets/images/chooese_your_role2.png"),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    "Name : John Smith",
                                    style: TextStyle(
                                      fontFamily: "Outfit",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: ColorCode.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Email ID: johnsmith4545@gmail.com",
                                    style: TextStyle(
                                      fontFamily: "Outfit",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: ColorCode.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],


                          ),
                        ),
                      ),
                    ),*/
                    ],
                  ),
                ),


                const SizedBox(height: 30),
              ],
            ),
          ),
          /* if (isLoading)
            Container(
              color: ColorCode.black.withOpacity(0.5),
              child: const Center(
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: ColorCode.kButtonColor,
                  ),
                ),
              ),
            ),*/

        ],

      ),

      /*   bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "I Remember my Password. ",
              style: TextStyle(
                color: ColorCode.kWhiteOpacity60,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NewLoginScreen(),
                  ),
                );
              },
              child: const Text(
                "Login",
                style: TextStyle(
                  color: ColorCode.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),*/
    );
  }

  Widget _buildField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      cursorColor: ColorCode.white,

      style: const TextStyle(
        color: ColorCode.white, // typed text color
      ),

      decoration: InputDecoration(
        labelText: "$title*",
        floatingLabelBehavior: FloatingLabelBehavior.always,

        labelStyle: const TextStyle(
          color: ColorCode.kWhiteOpacity70, // #1D1D1B 60% opacity
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),

        /// ⭐ 0.5px BORDER + OPACITY COLOR
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
            width: 0.5, // 🔥 exact 0.5px
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
            width: 0.5, // focus border thicker
          ),
        ),

        floatingLabelStyle: const TextStyle(
          color: ColorCode.kWhiteOpacity70,
        ),)
      ,);
  }

}