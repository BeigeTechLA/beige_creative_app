import 'package:flutter/material.dart';

import '../utility/ColorCode.dart';
import '../utility/imges_icons.dart' show AppImages;
import '../widgets/custom_text_field.dart';
import 'myprofile_youre_all_set_screen.dart';

class MyprofileNewPasswrodScreen extends StatefulWidget {
  const MyprofileNewPasswrodScreen({super.key});

  @override
  State<MyprofileNewPasswrodScreen> createState() => _MyprofileNewPasswrodScreenState();
}

class _MyprofileNewPasswrodScreenState extends State<MyprofileNewPasswrodScreen> {

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;


  String? validatePassword() {
    if (passwordController.text.isEmpty) {
      return "Password cannot be empty";
    }
    if (passwordController.text.length < 6) {
      return "Password must be at least 6 characters";
    }
    if (passwordController.text != confirmPasswordController.text) {
      return "Passwords do not match";
    }
    return null;
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
                          AppImages.rectangle,
                          fit: BoxFit.fill,
                        ),
                      ),

                      /// 🔙 BACK BUTTON
                      ///
                      Positioned(
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
                                AppImages.back,
                                height: 24,
                                color: ColorCode.white,
                              ),
                            ),

                            /// 📄 STEP COUNT

                          ],
                        ),
                      ),

                      /// 🏷️ TITLE + SUBTITLE (CENTER)
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Text(
                              "Secure your Account",
                              style: TextStyle(
                                fontFamily: "Unbounded",
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColorCode.white,
                              ),
                            ),

                            SizedBox(height: 10),

                            Text(
                              "You're almost done! Set a new password\n to secure your account.",

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



                            CustomTextField(
                              label: "New Password",
                              controller: passwordController,
                              isPassword: true,
                              isVisible: isPasswordVisible,
                              onToggle: () {
                                setState(() {
                                 isPasswordVisible = isPasswordVisible;

                                });
                              },
                            ),

                            const SizedBox(height: 20),
                            const SizedBox(height: 20),

                            CustomTextField(
                              label: "Confirm Password",
                              controller: confirmPasswordController,
                              isPassword: true,
                              isVisible: isConfirmPasswordVisible,
                              onToggle: () {
                                setState(() {
                                  isConfirmPasswordVisible =
                                  isConfirmPasswordVisible;
                                });
                              },
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
                                      builder: (context) => MyprofileYoureAllSetScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorCode.kGoldGradientLight,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child:  isLoading
                                    ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: ColorCode.black,
                                  ),
                                )
                                    : const Text(
                                  "Save New Password",
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
    );
  }
}
