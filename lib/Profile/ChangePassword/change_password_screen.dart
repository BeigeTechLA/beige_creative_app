import 'package:flutter/material.dart';
import '../../utility/ColorCode.dart';
import '../../widgets/custom_text_field.dart';
import '../../service/api_service.dart';
import '../../service/api_endpoints.dart';
import 'change_password_controller.dart';
import 'enter_otp_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String? email;
  const ChangePasswordScreen({super.key, this.email});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {

  ChangePasswordController controller =
  ChangePasswordController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    /// ✅ EMAIL PREFILL
    if ((widget.email ?? "").isNotEmpty) {
      controller.emailController.text = widget.email!;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// 🔥 EMAIL VALIDATION
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// 🔥 SNACKBAR
  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// 🔥 API CALL (OTP SEND)
  Future<void> sendOtp() async {
    final email = controller.emailController.text.trim();

    if (email.isEmpty) {
      _showSnack("Please enter email");
      return;
    }

    if (!isValidEmail(email)) {
      _showSnack("Invalid email format");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await ApiService().postData(
        ApiEndpoints.forgotpassword,
        {
          "email": email,
        },
      );

      if (response == null) {
        _showSnack("Server error");
        return;
      }

      if (response["error"] == false) {
        /// ✅ SUCCESS → OTP SCREEN
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EnterOtpScreen(email: email),
          ),
        );
      } else {
        _showSnack(response["message"] ?? "Something went wrong");
      }
    } catch (e) {
      _showSnack("Something went wrong");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔼 TOP CONTENT
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      /// 🔙 BACK
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Image.asset(
                          "assets/icons/Reply.png",
                          height: 24,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// 🔹 TITLE
                      Text(
                        "Change your Password",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Unbounded",
                          fontWeight: FontWeight.w500,
                          color: ColorCode.white,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// 🔹 DESCRIPTION
                      const Text(
                        "Enter your email ID to receive an OTP code to change your password.",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w400,
                          color:
                          ColorCode.kWhiteOpacity60,
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// 🔹 EMAIL FIELD
                      CustomTextField(
                        label: "Email ID*",
                        controller:
                        controller.emailController,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔥 SEND OTP BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorCode.kButtonColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Send OTP",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "Unbounded",
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}