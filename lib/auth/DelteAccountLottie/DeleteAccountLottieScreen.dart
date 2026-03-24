import 'package:beige_creative_app/auth/login/login.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../utility/ColorCode.dart';






class DeleteAccountLottieScreen extends StatefulWidget {
  const DeleteAccountLottieScreen({super.key});

  @override
  State<DeleteAccountLottieScreen> createState() => _DeleteAccountLottieScreenState();
}

class _DeleteAccountLottieScreenState extends State<DeleteAccountLottieScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => Login()),
              (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Lottie.asset(
              "assets/lottie/Untitled file.json",
              height: 180,
              repeat: false,
            ),

            const SizedBox(height: 24),

            const Text(
              "Account Deleted",
              style: TextStyle(
                color: ColorCode.kButtonColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: "Unbounded",
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Your account has been successfully.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorCode.kWhiteOpacity70,
                fontSize: 14,
                fontFamily: "Outfit",
              ),
            ),
            const Text(
              "deleted.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorCode.kWhiteOpacity70,
                fontSize: 14,
                fontFamily: "Outfit",
              ),
            ),
          ],
        ),
      ),
    );
  }
}