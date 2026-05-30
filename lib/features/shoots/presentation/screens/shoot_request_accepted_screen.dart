import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/route_names.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

class ShootRequestAccepted extends ConsumerStatefulWidget {
  const ShootRequestAccepted({super.key});

  @override
  ConsumerState<ShootRequestAccepted> createState() =>
      _ShootRequestAcceptedState();
}

class _ShootRequestAcceptedState extends ConsumerState<ShootRequestAccepted> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.goNamed(RouteNames.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCropSheet,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              AppAssets.lottie1,
              height: 180,
              repeat: false,
            ),
            AppSpacing.verticalXxl,
            const Text(
              'Shoot request accepted',
              style: AppTextStyles.titleMedium,
            ),
            AppSpacing.verticalSm,
            const Text(
              "You've successfully accepted the shoot.\nCheck your calendar for details.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
