import 'package:beige_creative_app/app/assets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/route_names.dart';
import '../app/colors.dart';

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

 /*     Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Mainscreen(),
        ),
      );*/
      context.goNamed(RouteNames.home);
    }else{

      context.goNamed(RouteNames.onboarding);
    }




  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.textHeading,
        child: Center(
          child: Lottie.asset(
            AppAssets.lottie2,
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