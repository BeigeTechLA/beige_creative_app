import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

class EnterOtpController {
  final List<TextEditingController> controllers =
  List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
  List.generate(6, (_) => FocusNode());

  bool isOtpFilled = false;
  bool isLoading = false;

  int seconds = 60;
  Timer? timer;

  // ✅ Start Timer
  void startTimer(VoidCallback refresh) {
    timer?.cancel();
    seconds = 60;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds > 0) {
        seconds--;
        refresh();
      } else {
        t.cancel();
        refresh(); // 👈 Important (0 pe bhi refresh hoga)
      }
    });
  }

// ✅ Resend OTP Proper Working
  void resendOtp(VoidCallback refresh) {
    timer?.cancel();

    seconds = 60;

    // Clear old OTP fields
    for (var c in controllers) {
      c.clear();
    }

    isOtpFilled = false;

    startTimer(refresh);

    refresh(); // 👈 Important (UI instantly update karega)
  }
  // ✅ Check OTP filled
  void checkOtpFilled(VoidCallback refresh) {
    isOtpFilled =
        controllers.every((c) => c.text.trim().isNotEmpty);
    refresh();
  }

  // ✅ Get OTP
  String getOtp() {
    return controllers.map((c) => c.text).join();
  }

  // ✅ Dispose
  void dispose() {
    timer?.cancel();
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
  }
}