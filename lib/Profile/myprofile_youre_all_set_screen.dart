import 'package:beige_creative_app/auth/login/login.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../utility/ColorCode.dart';
import 'MyProfile/MyProfile.dart';

class MyprofileYoureAllSetScreen extends StatefulWidget {
  const MyprofileYoureAllSetScreen({super.key});

  @override
  State<MyprofileYoureAllSetScreen> createState() => _MyprofileYoureAllSetScreenState();
}

class _MyprofileYoureAllSetScreenState extends State<MyprofileYoureAllSetScreen> {
  @override
  void initState() {
    super.initState();

    /// ⏳ 5 second delay then go to MainScreen
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
      backgroundColor: const Color(0xFF1C1C1C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// ✅ SUCCESS LOTTIE
            Lottie.asset(
              "assets/lottie/Untitled file.json",
              height: 180,
              repeat: false,
            ),

            const SizedBox(height: 24),

            const Text(
              "You're All Set",
              style: TextStyle(
                color: ColorCode.kButtonColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: "Unbounded",
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Congratulations! Your password has been\nchanged successfully",
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
