import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../app/route_names.dart';
import '../app/colors.dart';
import '../app/radii.dart';
import '../app/spacing.dart';
import '../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart' show AppAssets;
import '../widgets/top_message.dart';
import '../widgets/custom_text_field.dart';

class MyprofileNewPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  const MyprofileNewPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<MyprofileNewPasswordScreen> createState() => _MyprofileNewPasswordScreenState();
}

class _MyprofileNewPasswordScreenState extends State<MyprofileNewPasswordScreen> {

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

/*  Future<void> _newpasswrod() async {
    print("📢 Reset Password Clicked");
    print("📧 Email => ${widget.email}");

    if (newPasswordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      _showSnack("Please enter password");
      return;
    }

    if (newPasswordController.text.trim().length < 6) {
      _showSnack("Password must be at least 6 characters");
      return;
    }

    if (newPasswordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      _showSnack("Passwords do not match");
      return;
    }

    setState(() => isLoading = true);

    try {
      final apiService = ApiService();

      print("🚀 RESET PASSWORD API CALL START");
      print("📡 Endpoint => ${ApiEndpoints.restartpassword}");

      final response = await apiService.postData(
        ApiEndpoints.restartpassword,
        {
          "otp": widget.otp, // 🔥 replace with actual OTP if needed
          "email": widget.email,
          "new_password": newPasswordController.text.trim(),
          "confirm_password": confirmPasswordController.text.trim(),
        },
      );

      print("📩 API RESPONSE => $response");

      if (response == null) {
        _showSnack("Server error");
        return;
      }

      if (response['error'] == false) {
        print("✅ Password Reset Success");

        if (!mounted) return;

       *//* Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MyprofileYoureAllSetScreen(),
          ),
        );*//*
        context.pushNamed(RouteNames.);
      } else {
        print("❌ Reset Failed => ${response['message']}");
        _showSnack(response['message'] ?? "Failed to reset password");
      }
    } catch (e) {
      print("🔥 Exception => $e");
      _showSnack("Something went wrong");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
      print("🛑 RESET PASSWORD API CALL END");
    }
  }*/


  void _showSnack(String message) {
    TopMessage.show(context, message);

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
                          AppAssets.rectangle,
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
                                context.pop();
                              },
                              child: SvgPicture.asset(
                                AppAssets.back,
                                height: 24,
                                color: AppColors.white,
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
                              "Set your new Password",
                              style: AppTextStyles.displayStrong16.copyWith(color: AppColors.white),
                            ),

                            SizedBox(height: 10),

                            Text(
                              "You're almost done! Set a new password to secure \n your account. Make sure it's strong and unique.",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white30),
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
                        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.huge, AppSpacing.xl, AppSpacing.xl),
                        // 👈 top extra
                        margin: AppSpacing.authCardMargin,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: AppRadii.massiveAll,
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.06),
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
                                  isPasswordVisible =
                                  !isPasswordVisible;

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

                                  context.pushNamed(
                                    RouteNames.profilePasswordSuccess,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.borderGold,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadii.xlAll,
                                  ),
                                ),
                                child:  isLoading
                                    ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.black,
                                  ),
                                )
                                    : Text(
                                  "Save New Password",
                                  style: AppTextStyles.displayLabel13.copyWith(color: AppColors.textHeading),
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
