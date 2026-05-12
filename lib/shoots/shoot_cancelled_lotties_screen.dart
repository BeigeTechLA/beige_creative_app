import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../MainScreen.dart';
import '../utility/ColorCode.dart';
import '../utility/imges_icons.dart';


class ShootCancelledLottiesScreen extends StatefulWidget {
  const ShootCancelledLottiesScreen({super.key});

  @override
  State<ShootCancelledLottiesScreen> createState() => _ShootCancelledLottiesScreenState();
}

class _ShootCancelledLottiesScreenState extends State<ShootCancelledLottiesScreen> {
  @override
  void initState() {
    super.initState();

    /// ⏳ 5 second delay then go to MainScreen
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => Mainscreen()),
              (route) => false,
        );
      }
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// ✅ SUCCESS LOTTIE
            Lottie.asset(
              AppImages.lottie1,
              height: 180,
              repeat: false,
            ),

            const SizedBox(height: 24),

            const Text(
              "Shoot Cancelled",
              style: TextStyle(
                color: ColorCode.kButtonColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: "Unbounded",
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "The shoot request has been cancelled.\nsuccessfully.",
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
