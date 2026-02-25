import 'package:flutter/material.dart';
import '../../../service/api_endpoints.dart';
import '../../../service/api_service.dart';

class ChangePasswordController {
  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;

  /// 📧 Email Validation
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(email);
  }


  void dispose() {
    emailController.dispose();
  }
}