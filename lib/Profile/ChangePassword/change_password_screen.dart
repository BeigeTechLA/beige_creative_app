import 'package:flutter/material.dart';
import '../../utility/ColorCode.dart';
import '../../widgets/custom_text_field.dart';
import 'change_password_controller.dart';
import 'enter_otp_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {

  final ChangePasswordController controller =
  ChangePasswordController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  void _showSnack(String message) {
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
      body: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Image.asset(
                          "assets/icons/Reply.png",
                          height: 24,
                        ),
                      ),

                      const SizedBox(height: 20),

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

              /// ✅ SEND OTP BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorCode.kButtonColor,
                    elevation: 0, // shadow remove
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14), // rounded corners
                    ),
                  ),
                  onPressed: () {
                      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EnterOtpScreen(),
      ),
    );                  },
                  child: const Text(
                    "Send OTP",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "Unbounded",
                      fontWeight: FontWeight.w500,
                      color: Colors.black, // dark text
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