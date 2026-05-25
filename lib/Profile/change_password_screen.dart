import 'package:beige_creative_app/app/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../app/route_names.dart';
import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../app/colors.dart';
import '../app/radii.dart';
import '../app/spacing.dart';
import '../app/text_styles.dart';
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
    //     backgroundColor: AppColors.error,
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.s15,
          ),
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
                          AppAssets.back,
                          height: 24,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "Change your Password",//
                        style: AppTextStyles.displayLabel16.copyWith(
                          color: AppColors.white,
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
                            style: AppTextStyles.body13.copyWith(
                              color: AppColors.white60,
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
                        ? AppColors.primary
                        : AppColors.borderGold,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.xlAll,
                    ),
                  ),
                  child: Text(
                    "Send OTP",
                    style: AppTextStyles.displayLabel14.copyWith(
                      color: isEmailFilled
                          ? AppColors.textHeading
                          : AppColors.surfaceMid,
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

          labelStyle: AppTextStyles.systemDefault.copyWith(
            color: AppColors.white, // #1D1D1B 60% opacity
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),

          /// ⭐ 0.5px BORDER + OPACITY COLOR
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadii.lgAll,
            borderSide:  BorderSide(
              color: AppColors.white60, // #1D1D1B99 (60% opacity)
              width: 0.5,                       // 🔥 exact 0.5px
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadii.lgAll,
            borderSide: const BorderSide(
              color: AppColors.white60, // #1D1D1B99 (60% opacity)
              width: 0.5,                          // focus border thicker
            ),
          ),

          floatingLabelStyle: AppTextStyles.systemDefault.copyWith(
            color: AppColors.white60,
          ),)

    );
  }
}