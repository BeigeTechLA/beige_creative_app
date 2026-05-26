import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../app/route_names.dart';
import '../app/colors.dart';
import '../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart';

class MyprofileYoureAllSetScreen extends StatefulWidget {
  const MyprofileYoureAllSetScreen({super.key});

  @override
  State<MyprofileYoureAllSetScreen> createState() =>
      _MyprofileYoureAllSetScreenState();
}

class _MyprofileYoureAllSetScreenState
    extends State<MyprofileYoureAllSetScreen> {
  @override
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.goNamed(RouteNames.login);
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
            /// ✅ SUCCESS LOTTIE
            Lottie.asset(AppAssets.lottie1, height: 180, repeat: false),

            const SizedBox(height: 24),

            Text(
              "You're All Set",
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Congratulations! Your password has been\nchanged successfully",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
