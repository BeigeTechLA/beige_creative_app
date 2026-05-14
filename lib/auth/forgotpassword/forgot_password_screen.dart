
import 'package:beige_creative_app/auth/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/colorcode.dart';
import '../../utility/imges_icons.dart';
import '../../widgets/Topmessgae.dart';
import '../../widgets/new_Textfield.dart';
import 'forgot_password_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool showConfirmPassword = false;
  bool savePassword = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isLoading = false;
  }

  bool isLoading = false;

  Future<void> _fetchForgotPassword()async{
    if(emailController.text.trim().isEmpty){
      TopMessage.show(context, "Please enter email");
    }
      if (!isValidEmail(emailController.text.trim())) {
        print("❌ Invalid Email Format");
        TopMessage.show(context, "Please enter a valid email address");
        return;
      }

      setState(() {
        isLoading=true;
      });



      try{
        final response= await ApiService().postData(
            ApiEndpoints.forgotpassword,
             {
               "email":emailController.text,
             });

        debugPrint("📩 Api response:: $response");

            if (response == null) {
              print("❌ Response NULL");
              TopMessage.show(context, "Server error, please try again");
              return;
            }
            if(response["error"]==false){
              debugPrint("Otp send ::::::");

              Navigator.push(context, MaterialPageRoute(builder:(context) {
                return ForgotPasswordOtpScreen(email: emailController.text,);

              },));
            }else {
                    print("❌ Backend Error => ${response['message']}");

                    /// backend ka message show karega
                    TopMessage.show(
                      context,
                      response['message'] ?? "Email not registered",
                    );
                  }

      }catch(e){
        debugPrint("error is::::::::::: $e");
        TopMessage.show(context, "Something went wrong");
      }finally{
        setState(() => isLoading = false);
      }

  }




  // Future<void> _fetchForgotPassword() async {
  //
  //   if (emailController.text.trim().isEmpty) {
  //     print("❌ Email Empty");
  //     TopMessage.show(context, "Please enter email");
  //     return;
  //   }
  //
  //   if (!isValidEmail(emailController.text.trim())) {
  //     print("❌ Invalid Email Format");
  //     TopMessage.show(context, "Please enter a valid email address");
  //     return;
  //   }
  //
  //   setState(() => isLoading = true);
  //
  //   try {
  //     print("🚀 API CALL START");
  //     print("📡 Endpoint => ${ApiEndpoints.forgotpassword}");
  //
  //     final response = await ApiService().postData(
  //       ApiEndpoints.forgotpassword,
  //       {
  //         "email": emailController.text.trim(),
  //       },
  //     );
  //
  //     print("📩 API RESPONSE => $response");
  //
  //     if (response == null) {
  //       print("❌ Response NULL");
  //       TopMessage.show(context, "Server error, please try again");
  //       return;
  //     }
  //
  //     if (response['error'] == false) {
  //       print("✅ OTP Sent Successfully");
  //
  //       if (!mounted) return;
  //
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (_) => OtpScreen(
  //           ),
  //         ),
  //       );
  //
  //     } else {
  //       print("❌ Backend Error => ${response['message']}");
  //
  //       /// backend ka message show karega
  //       TopMessage.show(
  //         context,
  //         response['message'] ?? "Email not registered",
  //       );
  //     }
  //
  //   } catch (e) {
  //     print("🔥 Exception => $e");
  //     TopMessage.show(context, "Something went wrong");
  //   } finally {
  //     if (mounted) {
  //       setState(() => isLoading = false);
  //     }
  //     print("🛑 API CALL END");
  //   }
  // }


  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }


  bool get isFormValid {
    return emailController.text.trim().isNotEmpty;
  }


  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: ColorCode.white,
      body: Stack(
        children: [
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
                      Positioned.fill(
                        child: Image.asset(
                          AppImages.rectangle,
                          fit: BoxFit.fill,
                        ),
                      ),

                      /// 🌫️ DARK OVERLAY
                      /*    Positioned.fill(
                      child: Container(
                        color: ColorCode.black.withOpacity(0.55),
                      ),
                    )*/


                      /// 🔙 BACK BUTTON
                      Positioned(
                        top: 50, // 🔥 yaha value adjust kar sakte ho (30–50)
                        left: 16,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context); // 🔥 screen pop karega
                          },
                          child: SvgPicture.asset(
                            AppImages.back,
                            height: 24,
                          ),
                        ),
                      ),

                      /// 🏷️ TITLE + SUBTITLE (CENTER)
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children:  [

                            Text(
                              'Forgot Password',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ColorCode.white,
                                fontSize: 16,
                                fontFamily: 'Unbounded',
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            SizedBox(height: 8),

                            Text(
                              'Enter your registered email to receive a reset link.\nWe’ll help you get back into your account quickly.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ColorCode.white.withValues(alpha: 0.60),
                                fontSize: 14,
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w400,
                                height: 1.29,
                              ),
                            )
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
                        padding: const EdgeInsets.fromLTRB(20, 13,20, 20),
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


                            CustomInputField(
                              title: "Email ID*",
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),

                            const SizedBox(height: 23),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                // onPressed: isLoading ? null : _fetchForgotPassword,

                                onPressed: (!isFormValid || isLoading)
                                    ? null
                                    : () {

                                  _fetchForgotPassword();
                                },

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFormValid
                                      ? ColorCode.kButtonColor
                                      : ColorCode.kGoldGradientLight,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child:  Text(
                                  "Send OTP",
                                  style: TextStyle(
                                    fontFamily: "Unbounded",
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isFormValid
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

      bottomNavigationBar: SafeArea(
        child: Padding(
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
                      builder: (_) => const Login(),
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
        ),
      ),
    );
  }

}