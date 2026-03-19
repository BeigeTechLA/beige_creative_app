import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../MainScreen.dart';
import '../../utility/ColorCode.dart';
import '../../widgets/custom_text_field.dart';
import '../ForgotPassword/forgot_password_screen.dart';
import '../New_Creative_sing_up_follow/new_build_your_creative_profile.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  bool isLoggingIn =false;
  bool showConfirmPassword = false;
  bool savePassword = false;
  bool showPassword = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool get isFormValid {
    return emailController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty;
  }
  _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.28,
                  child: Stack(
                    children: [

                      /// 🖼️ BACKGROUND IMAGE
                      Positioned.fill(
                        child: Image.asset(
                          "assets/images/Rectangle_574057023.png",
                          fit: BoxFit.fill,
                        ),
                      ),

                      /// 🔙 BACK BUTTON
              /*        Positioned(
                        top: 50,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            /// 🔙 BACK BUTTON
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Image.asset(
                                "assets/icons/Reply.png",
                                height: 24,
                                color: Colors.white,
                              ),
                            ),

                            /// 📄 STEP COUNT
                            const Text(
                              "1/3",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
*/
                      /// 🏷️ TITLE + SUBTITLE (CENTER)
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Text(
                              "Welcome Back",
                              style: TextStyle(
                                fontFamily: "Unbounded",
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColorCode.white,
                              ),
                            ),

                            SizedBox(height: 10),

                            Text(
                              "Enter your details to access your account. Continue\n managing your bookings and profile.",

                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Outfit",
                                fontSize: 14,
                                color: ColorCode.kWhiteOpacity70,
                              ),
                            ),
                            SizedBox(height: 10),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),

                /// 📦 FORM CONTAINER (NICHE)
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [

                      /// 🧱 MAIN FORM CONTAINER
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 36, 20, 20),
                        // 👈 top extra
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: ColorCode.bcakgroundcolor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [

                            const SizedBox(height: 12),


                            CustomTextField(
                              label: "Email ID",
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 20),






                            CustomTextField(
                              label: "Password",
                              controller: passwordController,
                              isPassword: true,
                              isVisible: showPassword,

                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                                icon: SvgPicture.asset(
                                  showPassword
                                      ? "assets/svg/eyes1.svg"
                                      : "assets/svg/eyes2.svg",
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      savePassword = !savePassword;
                                    });
                                  },
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      color: savePassword
                                          ? ColorCode.black
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: ColorCode.kWhiteOpacity70,
                                      ),
                                    ),
                                    child: savePassword
                                        ? const Icon(Icons.check,
                                        size: 14, color: ColorCode.kButtonColor)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Saved Password",
                                  style: TextStyle(
                                    fontFamily: "Outfit",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: ColorCode.kWhiteOpacity60,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                        fontFamily: "Outfit",
                                        color: ColorCode.kButtonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                        decorationThickness: 1.8,
                                        decorationColor: ColorCode.kButtonColor
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
                                 onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Mainscreen(),
                                    ),
                                  );
                                },

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorCode.kGoldGradientLight,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: isLoggingIn
                                    ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                                    : const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontFamily: "Unbounded",
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: ColorCode.kHeadingColor,
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
                const SizedBox(height: 20),

                /// 🏷️ FLOATING CHIP (BORDER PE STUCK)


              ],
            ),
          ),

   
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: const BoxDecoration(
          color: ColorCode.bcakgroundcolor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don’t have an account? ",
              style: TextStyle(
                color: ColorCode.kWhiteOpacity60,
                fontSize: 14,
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => New_build_your_creativeScreen(),
                  ),
                );
              },
              child: const Text(
                "Sign Up",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
