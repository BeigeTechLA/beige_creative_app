import 'package:beige_creative_app/service/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../Profile/myprofile_youre_all_set_screen.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';
import '../../widgets/Topmessgae.dart';
import '../../widgets/new_Textfield.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  const NewPasswordScreen({super.key, required this.email, required this.otp,});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  bool showNewPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();


  bool isPasswordFilled = false;
  void _checkPassword() { setState(() { isPasswordFilled = newPasswordController.text.isNotEmpty && confirmPasswordController.text.isNotEmpty; }); }

  Future<void> _newpasswrod() async {
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

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MyprofileYoureAllSetScreen(),
          ),
        );
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
  }


  void _showSnack(String message) {
    TopMessage.show(context, message);

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: ColorCode.white,
      body: SingleChildScrollView(
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
                  Positioned.fill(
                    child: Image.asset(
                      "assets/images/Rectangle_574057023.png",
                      fit: BoxFit.fill,
                    ),
                  ),
                  /// 🖼️ BACKGROUND IMAGE


                  /// 🌫️ DARK OVERLAY
                  /*    Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.55),
                    ),
                  )*/

                  /// 🔙 BACK BUTTON
                  Positioned(
                    top: 50, // 🔥 yaha value adjust kar sakte ho (30–50)
                    left: 16,
                    child: InkWell(//
                      onTap: () {
                        Navigator.pop(context); // 🔥 screen pop karega
                      },
                      child: SvgPicture.asset(
                        "assets/svg/back.svg",
                        height: 24,
                        color: Colors.white, // agar white chahiye ho
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
                          'Secure your Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Unbounded',
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          'You\'re almost done! Set a new password\nto secure your account.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.60),
                            fontSize: 14,
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w400,
                            height: 1.29,
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
                    padding: const EdgeInsets.fromLTRB(20, 25 , 20, 20),
                    // 👈 top extra
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: ColorCode.backgroundColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                        width: 0.50,
                      ),
                    ),
                    child: Column(
                      children: [

                        //   const SizedBox(height: 12),


                        /*  _buildField(
                          "New Password*",
                          newPasswordController,
                          true,
                          showNewPassword,
                              () {
                            setState(() {
                              showNewPassword = !showNewPassword;
                            });
                          },
                        ),

                        _buildField(
                          "Confirm Password*",
                          confirmPasswordController,
                          true,
                          showConfirmPassword,
                              () {
                            setState(() {
                              showConfirmPassword = !showConfirmPassword;
                            });
                          },
                        ),*/

                        CustomInputField(
                          title: "New Password*",
                          controller: newPasswordController,
                          isPassword: true,
                          isVisible: showNewPassword,
                          onChanged: (value) {
                            _checkPassword();
                          },
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                showNewPassword = !showNewPassword;
                              });
                            },
                            icon: SvgPicture.asset(
                              showNewPassword
                                  ? "assets/svg/eyes1.svg"
                                  : "assets/svg/eyes2.svg",
                              height: 22,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        CustomInputField(
                          title: "Confirm Password*",
                          controller: confirmPasswordController,
                          isPassword: true,
                          isVisible: showConfirmPassword,
                          onChanged: (value) {
                            _checkPassword();
                          },
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                showConfirmPassword = !showConfirmPassword;
                              });
                            },
                            icon: SvgPicture.asset(
                              showConfirmPassword
                                  ? "assets/svg/eyes1.svg"
                                  : "assets/svg/eyes2.svg",
                              height: 22,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),



                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isPasswordFilled && !isLoading ? _newpasswrod : null,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPasswordFilled
                                  ? ColorCode.kButtonColor
                                  : ColorCode.kGoldGradientLight,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child:  Text(
                              "Save New Password",
                              style: TextStyle(
                                fontFamily: "Unbounded",
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isPasswordFilled
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
                  /*          Positioned(
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
                            color: Colors.white.withOpacity(0.12),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.35),
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
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Email ID: johnsmith4545@gmail.com",
                                  style: TextStyle(
                                    fontFamily: "Outfit",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black54,
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


    );
  }


}//