import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../app/route_names.dart';
import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../utility/ColorCode.dart';
import '../widgets/Topmessgae.dart';
import '../widgets/new_Textfield.dart';


class ChangePasswordScreen extends StatefulWidget {
  final String email;

  const ChangePasswordScreen({super.key, required this.email});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  bool isEmailFilled = false;
  bool isLoading = false;


  @override
  void initState() {
    super.initState();


    emailController.text = widget.email;

    isEmailFilled = emailController.text.trim().isNotEmpty;
  }
  Future<void> _fetchForgotPassword() async {
    final apiService = ApiService();
    final email = emailController.text.trim();

    /// EMAIL EMPTY VALIDATION
    if (email.isEmpty) {
      TopMessage.show(context, "Please enter your email");
      return;
    }

    /// EMAIL FORMAT VALIDATION
    if (!isValidEmail(email)) {
      TopMessage.show(context, "Please enter a valid email address");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await apiService.postData(
        ApiEndpoints.forgotpassword,
        {"email": email},
      );

      /// SERVER NULL RESPONSE
      if (response == null) {
        TopMessage.show(context, "Server error, please try again");
        return;
      }

      /// SUCCESS CASE
      if (response['error'] == false) {
        if (!mounted) return;

        context.pushNamed(
          RouteNames.profileOtp,
          extra: {
            "email": emailController.text.trim(),
          },
        );
      } else {
        /// BACKEND ERROR MESSAGE
        TopMessage.show(
          context,
          response['message'] ?? "Email not registered",
        );
      }
    } catch (e) {
      /// API EXCEPTION
      TopMessage.show(context, "Something went wrong");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$',
    );
    return emailRegex.hasMatch(email);
  }


  void _showSnack(String message) {
    TopMessage.show(context, message);

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(message),
    //     backgroundColor: Colors.red,
    //   ),
    // );

  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      InkWell(
                        onTap: () => Navigator.pop(context,true),
                        child: SvgPicture.asset(
                          "assets/svg/back.svg",
                          height: 24,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "Change your Password",//
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Unbounded",
                          fontWeight: FontWeight.w500,
                          color: ColorCode.white,
                        ),
                      ),

                      const SizedBox(height: 6),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Text(
                            "Enter your email ID to receive an OTP code to change your password.",
                            textAlign: TextAlign.left,
                            softWrap: true,
                            maxLines: 3,
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w400,
                              color: ColorCode.kWhiteOpacity60,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 25),

                      CustomInputField(
                        readOnly: true,
                        title: "Email ID*",
                        controller: emailController, //
                        onChanged: (value) {
                          setState(() {
                            isEmailFilled = value.trim().isNotEmpty;
                          });
                        },
                      ),
                      // _buildEmailField(),
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
                  // onPressed: (isEmailFilled && !isLoading)
                  //     ? _fetchForgotPassword
                  //     : null,
                  onPressed: _fetchForgotPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEmailFilled
                        ? ColorCode.kButtonColor
                        : ColorCode.kGoldGradientLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "Send OTP",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "Unbounded",
                      color: isEmailFilled
                          ? ColorCode.kHeadingColor
                          : ColorCode.k282828,
                      fontWeight: FontWeight.w500,
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

  Widget _buildEmailField() {
    return TextField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) {
          setState(() {
            isEmailFilled = value.trim().isNotEmpty;
          });
        },
        decoration: InputDecoration(
          labelText: "Email ID*",
          floatingLabelBehavior: FloatingLabelBehavior.always,

          labelStyle: const TextStyle(
            color: ColorCode.white, // #1D1D1B 60% opacity
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),

          /// ⭐ 0.5px BORDER + OPACITY COLOR
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:  BorderSide(
              color: ColorCode.kWhiteOpacity60, // #1D1D1B99 (60% opacity)
              width: 0.5,                       // 🔥 exact 0.5px
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: ColorCode.kWhiteOpacity60, // #1D1D1B99 (60% opacity)
              width: 0.5,                          // focus border thicker
            ),
          ),

          floatingLabelStyle: const TextStyle(
            color: ColorCode.kWhiteOpacity60,
          ),)

    );
  }
}