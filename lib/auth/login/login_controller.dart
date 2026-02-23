import 'package:flutter/material.dart';

import 'login_controller.dart' as AuthService;

Future<Map<String, dynamic>> login(
    String email,
    String password,
    ) async {

  if (email.isEmpty || password.isEmpty) {
    return {
      "status": false,
      "message": "Please fill all fields"
    };
  }

  try {
    final response =
    await AuthService.login(email, password);

    return response;

  } catch (e) {
    return {
      "status": false,
      "message": "Something went wrong"
    };
  }
}
