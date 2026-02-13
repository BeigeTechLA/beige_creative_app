
import 'dart:async';
import 'package:flutter/material.dart';

import '../OnbodingScreen/onboding_screen.dart';
import '../utility/ColorCode.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int currentIndex = 0;
  Timer? _timer;

  final List<String> centerImages = [
    "assets/Splash/Property_1.png",
    "assets/Splash/Property_2.png",
    "assets/Splash/Property_3.png",
    "assets/Splash/Property_4.png",
    "assets/Splash/Propety_5.png",
    "assets/Splash/Property_6.png",
  ];

  @override
  void initState() {
    super.initState();
    _startImageSwap();
  }

  void _startImageSwap() {
    _timer = Timer.periodic(const Duration(milliseconds: 450), (timer) {
      if (currentIndex < centerImages.length - 1) {
        setState(() {
          currentIndex++;
        });
      } else {
        timer.cancel();

        // hold last frame & navigate
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>  OnboardingScreen(),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🔹 SOLID BACKGROUND (same as design)
          Container(
            color: ColorCode.kHeadingColor,
          ),

          /// 🔹 CENTER IMAGE (ONLY THIS CHANGES)
          Center(
            child: Image.asset(
              centerImages[currentIndex],
              width: 240,
              fit: BoxFit.contain, // ✅ no distortion
            ),
          ),
        ],
      ),
    );
  }
}
