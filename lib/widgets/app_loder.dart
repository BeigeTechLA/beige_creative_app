import 'package:beige_creative_app/app/assets.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../utility/colorcode.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill( // 🔥 full screen cover
      child: Container(
        color: ColorCode.backgroundColor,
        child: Center(
          child: Lottie.asset(
            AppAssets.lottieLoader,
            height: 70,
            width: 70,
          ),
        ),
      ),
    );
  }
}