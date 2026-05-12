import 'package:beige_creative_app/Home/home_screen.dart';
import 'package:beige_creative_app/Shoots/shoot_cancelled_lotties_screen.dart';
import 'package:beige_creative_app/utility/imges_icons.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../MainScreen.dart';
import '../onboding/onboding_screen.dart';
import '../utility/ColorCode.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  void _goToNextScreen()async {

    final prefs=await SharedPreferences.getInstance();

    final isloggin= prefs.getBool('isLoggedIn')?? false;

    if(isloggin){

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Mainscreen(),
        ),
      );
    }else{
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OnboardingScreen(),
        ),
      );
    }




  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: ColorCode.kHeadingColor,
        child: Center(
          child: Lottie.asset(
            AppImages.lottie2,
          /*  "assets/lottie/Component10.json",*/
            controller: _controller,
            width: 250,
            fit: BoxFit.contain,
            onLoaded: (composition) {
              _controller
                ..duration = composition.duration
                ..forward().whenComplete(() {
                  _goToNextScreen(); // ✅ animation end → next screen
                });
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}