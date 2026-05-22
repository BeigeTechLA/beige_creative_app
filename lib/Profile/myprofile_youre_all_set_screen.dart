import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../app/route_names.dart';
import '../utility/colorcode.dart';
import 'package:beige_creative_app/app/assets.dart';

class MyprofileYoureAllSetScreen extends StatefulWidget {
  const MyprofileYoureAllSetScreen({super.key});

  @override
  State<MyprofileYoureAllSetScreen> createState() => _MyprofileYoureAllSetScreenState();
}

class _MyprofileYoureAllSetScreenState extends State<MyprofileYoureAllSetScreen> {
  @override
  @override
  void initState() {

    super.initState();

    Future.delayed(
      const Duration(seconds: 3),
          () {

        if (mounted) {

          context.goNamed(
            RouteNames.login,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// ✅ SUCCESS LOTTIE
            Lottie.asset(
              // "assets/lottie/Untitled file.json",
              AppAssets.lottie1,
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
