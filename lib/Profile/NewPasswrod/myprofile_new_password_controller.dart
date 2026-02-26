import 'package:flutter/cupertino.dart';

class MyprofileNewPasswordController {

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;

  // ✅ Check validation
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

  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}