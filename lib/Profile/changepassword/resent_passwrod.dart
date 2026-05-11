import 'package:beige_creative_app/utility/imges_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../utility/ColorCode.dart';
import '../../service/api_service.dart';
import '../../service/api_endpoints.dart';
import '../../widgets/Topmessgae.dart';
import '../../widgets/new_Textfield.dart';
import '../myprofile_youre_all_set_screen.dart';

class resentpasswrod extends StatefulWidget {
  final String? email;
  final String? otp;

  const resentpasswrod({
    super.key,
     this.email,
     this.otp,
  });

  @override
  State<resentpasswrod> createState() =>
      _resentpasswrodState();
}

class _resentpasswrodState
    extends State<resentpasswrod> {
  bool showNewPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;

  final TextEditingController newPasswordController =
  TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool isFilled = false;

  void checkFields() {
    setState(() {
      isFilled = newPasswordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty;
    });
  }

  /// 🔥 API CALL (RESET PASSWORD)
  Future<void> savePassword() async {
    if (newPasswordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      TopMessage.show(context, "Please enter password");
      return;
    }

    if (newPasswordController.text.length < 6) {
      TopMessage.show(context, "Password must be at least 6 characters");
      return;
    }

    if (newPasswordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      TopMessage.show(context, "Passwords do not match");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await ApiService().postData(
        ApiEndpoints.restartpassword,
        {
          "email": widget.email,
          "otp": widget.otp,
          "new_password": newPasswordController.text.trim(),
          "confirm_password": confirmPasswordController.text.trim(),
        },
      );

      if (response == null) {
        TopMessage.show(context, "Server error");
        return;
      }

      if (response["error"] == false) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MyprofileYoureAllSetScreen(),
          ),
        );
      } else {
        TopMessage.show(
            context, response["message"] ?? "Failed to reset password");
      }
    } catch (e) {
      TopMessage.show(context, "Something went wrong");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Column(
          children: [

            SizedBox(height: 35,),

            /// 🔝 BACK BUTTON
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
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
              ),
            ),

            /// 🔥 MAIN CONTENT CENTER
             Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// TITLE
                    const Text(
                      "Set Your New Password",
                      style: TextStyle(
                        color: ColorCode.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Unbounded",
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// SUBTITLE
                    const Text(
                      "You're almost done! Set a new password to secure your account. Make sure it's strong and unique.",
                      style: TextStyle(
                        color: ColorCode.kWhiteOpacity70,
                        fontSize: 14,
                        fontFamily: "Outfit",
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// NEW PASSWORD
                    CustomInputField(
                      title: "New Password*",
                      controller: newPasswordController,
                      isPassword: true,
                      isVisible: showNewPassword,
                      onChanged: (_) => checkFields(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            showNewPassword = !showNewPassword;
                          });
                        },
                        icon: SvgPicture.asset(
                          showNewPassword
                              ? AppImages.eyeOpen
                              : AppImages.eyeClose,
                          height: 22,
                          colorFilter: const ColorFilter.mode(
                            ColorCode.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// CONFIRM PASSWORD
                    CustomInputField(
                      title: "Confirm Password*",
                      controller: confirmPasswordController,
                      isPassword: true,
                      isVisible: showConfirmPassword,
                      onChanged: (_) => checkFields(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            showConfirmPassword = !showConfirmPassword;
                          });
                        },
                        icon: SvgPicture.asset(
                          showConfirmPassword
                              ? AppImages.eyeOpen
                              : AppImages.eyeClose,
                          height: 22,
                          colorFilter: const ColorFilter.mode(
                            ColorCode.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Spacer(),

            /// 🔻 BOTTOM BUTTON (FIXED)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                  isFilled && !isLoading ? savePassword : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD6BE97),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Save New Password",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColorCode.black,
                      fontFamily: "Unbounded",
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}