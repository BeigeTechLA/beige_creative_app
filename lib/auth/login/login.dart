import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/route_names.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../service/shared_service.dart';
import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart';
import '../../widgets/Topmessgae.dart';
import '../../widgets/new_Textfield.dart';
// import '../creative_sign_up/signup1_screen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool showConfirmPassword = false;
  bool savePassword = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoggingIn = false;

  bool get isFormValid {
    return emailController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty;
  }

  _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  Future<void> _fetchLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    /// ✅ VALIDATION
    if (email.isEmpty) {
      TopMessage.show(context, 'Please enter your email address');
      return;
    }

    if (!isValidEmail(email)) {
      TopMessage.show(context, 'Please enter a valid email address');
      return;
    }

    if (password.isEmpty) {
      TopMessage.show(context, "Please enter your password");
      return;
    }

    setState(() => isLoggingIn = true);

    try {
      final response = await ApiService().postData(ApiEndpoints.login, {
        "email": email,
        "password": password,
      });

      debugPrint("Response ::::: $response");

      /// ✅ NULL RESPONSE
      if (response == null) {
        TopMessage.show(context, "Server error, please try again");
        return;
      }

      /// ✅ ERROR FROM API
      if (response["error"] == true) {
        TopMessage.show(
          context,
          response["message"]?.toString() ?? "Login failed",
        );
        return;
      }

      /// ✅ USER DATA CHECK
      if (response["data"] == null || response["data"]["user"] == null) {
        TopMessage.show(context, "User data not found");
        return;
      }

      /// ✅ SAVE LOGIN DATA
      await SharedService.setLoginDetails(response);

      final prefs = await SharedPreferences.getInstance();

      if (savePassword) {
        await prefs.setString("email", email);
        await prefs.setString("password", password);
      }

      /// ✅ SUCCESS NAVIGATION
      /*      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => Mainscreen()),
            (route) => false,
      );*/
      context.goNamed(RouteNames.home);
    } catch (e) {
      debugPrint("Login Error: $e");

      String errorMessage = "Invalid email or password";

      /// ✅ Case 1: Agar Map throw hua hai (best case)
      if (e is Map<String, dynamic>) {
        errorMessage = e["message"] ?? errorMessage;
      }
      /// ✅ Case 2: Agar string me JSON aa raha hai
      else if (e.toString().contains("{") && e.toString().contains("message")) {
        try {
          final data = e.toString();

          final match = RegExp(r'"message":"(.*?)"').firstMatch(data);
          if (match != null) {
            errorMessage = match.group(1) ?? errorMessage;
          }
        } catch (_) {}
      }

      TopMessage.show(context, errorMessage);
    } finally {
      if (mounted) {
        setState(() => isLoggingIn = false);
      }
    }
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> _loadSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();

    String? savedEmail = prefs.getString("email");
    String? savedPassword = prefs.getString("password");

    if (savedEmail != null && savedPassword != null) {
      emailController.text = savedEmail;
      passwordController.text = savedPassword;

      setState(() {
        savePassword = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials(); //

    emailController.addListener(_updateUI);
    passwordController.addListener(_updateUI);
  }

  void _updateUI() {
    setState(() {});
  }

  void _checkSavedEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();

    String savedEmail = prefs.getString("email") ?? "";
    String savedPassword = prefs.getString("password") ?? "";

    if (email.trim() == savedEmail.trim() && savedPassword.isNotEmpty) {
      setState(() {
        passwordController.text = savedPassword;
      });
    }
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    String? savedEmail = prefs.getString("email");
    String? savedPassword = prefs.getString("password");

    if (savedEmail != null && savedPassword != null) {
      emailController.text = savedEmail;
      passwordController.text = savedPassword;

      setState(() {
        savePassword = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 🔝 TOP IMAGE + TITLE SECTION
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              child: Stack(
                children: [
                  /// 🖼️ BACKGROUND IMAGE
                  Positioned.fill(
                    child: Image.asset(AppAssets.rectangle, fit: BoxFit.fill),
                  ),

                  /// 🏷️ TITLE + SUBTITLE (CENTER)
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Welcome Back",
                          style: AppTextStyles.displayLabel16.copyWith(
                            color: AppColors.white,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Enter your details to access your account. Continue\nmanaging your bookings and profile.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body14.copyWith(
                            color: AppColors.white.withValues(alpha: 0.60),
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
                    padding: AppSpacing.authCardPadding,
                    margin: AppSpacing.authCardMargin,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadii.massiveAll,
                      border: Border.all(color: AppColors.white24, width: 1),
                    ),
                    child: AutofillGroup(
                      child: Column(
                        children: [
                          CustomInputField(
                            title: "Email ID*",
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [
                              AutofillHints.username,
                              AutofillHints.email,
                            ],
                          ),

                          SizedBox(height: 20),

                          CustomInputField(
                            title: "Password*",
                            controller: passwordController,
                            isPassword: true,
                            isVisible: showConfirmPassword,
                            autofillHints: const [AutofillHints.password],
                            onToggle: () {
                              setState(() {
                                showConfirmPassword = !showConfirmPassword;
                              });
                            },
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  showConfirmPassword = !showConfirmPassword;
                                });
                              },
                              icon: SvgPicture.asset(
                                showConfirmPassword
                                    ? AppAssets.eyeOpen
                                    : AppAssets.eyeClose,
                                height: 22,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  context.pushNamed(RouteNames.forgotPassword);
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: AppTextStyles.bodySmallBold.copyWith(
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 1.8,
                                    decorationColor: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: (!isFormValid || isLoggingIn)
                                  ? null
                                  : () {
                                      TextInput.finishAutofillContext();
                                      _fetchLogin();
                                    },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFormValid
                                    ? AppColors.primary
                                    : AppColors.borderGold,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadii.xlAll,
                                ),
                              ),

                              child: Text(
                                "Login",
                                style: AppTextStyles.displayLabel13.copyWith(
                                  color: isFormValid
                                      ? AppColors.textHeading
                                      : AppColors.surfaceMid,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don’t have an account? ",
              style: AppTextStyles.system15Medium.copyWith(
                color: AppColors.white60,
              ),
            ),
            InkWell(
              onTap: () {
                /* Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignUp1Screen(),
                  ),
                );*/
                context.pushNamed(RouteNames.signupStep1);
              },
              child: Text(
                "Sign Up",
                style: AppTextStyles.system15Strong.copyWith(
                  color: AppColors.white,
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
