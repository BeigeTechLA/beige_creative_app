import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../app/route_names.dart' show RouteNames;
import '../app/colors.dart';
import '../app/text_styles.dart';
import '../app/spacing.dart';
import 'package:beige_creative_app/app/assets.dart' show AppAssets;

class ShootRequestAccepted extends StatefulWidget {
  const ShootRequestAccepted({super.key});

  @override
  State<ShootRequestAccepted> createState() => _ShootRequestAcceptedState();
}

class _ShootRequestAcceptedState extends State<ShootRequestAccepted> {
  @override
  void initState() {

    super.initState();

    Future.delayed(
      const Duration(seconds: 3),
          () {

        if (mounted) {

          context.goNamed(
            RouteNames.home,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCropSheet,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// ✅ SUCCESS LOTTIE
            Lottie.asset(
              AppAssets.lottie1,
              height: 180,
              repeat: false,
            ),

            AppSpacing.verticalXxl,

            const Text(
              "Shoot request accepted",
              style: AppTextStyles.titleMedium,
            ),

            AppSpacing.verticalSm,

            const Text(
              "You’ve successfully accepted the shoot.\nCheck your calendar for details.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
