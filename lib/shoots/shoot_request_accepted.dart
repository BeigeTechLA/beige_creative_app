import 'package:beige_creative_app/Shoots/shoots_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../MainScreen.dart';
import '../utility/colorcode.dart';
import '../utility/imges_icons.dart' show AppImages;

class ShootRequestAccepted extends StatefulWidget {
  const ShootRequestAccepted({super.key});

  @override
  State<ShootRequestAccepted> createState() => _ShootRequestAcceptedState();
}

class _ShootRequestAcceptedState extends State<ShootRequestAccepted> {
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
              AppImages.lottie1,
              height: 180,
              repeat: false,
            ),

            const SizedBox(height: 24),

            const Text(
              "Shoot request accepted",
              style: TextStyle(
                color: ColorCode.kButtonColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: "Unbounded",
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "You’ve successfully accepted the shoot.\nCheck your calendar for details.",
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
