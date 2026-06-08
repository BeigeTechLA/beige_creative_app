import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../app/assets.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';

class ShootCancelledLottiesScreen extends ConsumerStatefulWidget {
  const ShootCancelledLottiesScreen({super.key});

  @override
  ConsumerState<ShootCancelledLottiesScreen> createState() =>
      _ShootCancelledLottiesScreenState();
}

class _ShootCancelledLottiesScreenState
    extends ConsumerState<ShootCancelledLottiesScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.goNamed(Routes.home.name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              AppAssets.lottieSuccess,
              height: 180,
              repeat: false,
            ),
            AppSpacing.verticalXxl,
            const Text(
              'Shoot Cancelled',
              style: AppTextStyles.titleMedium,
            ),
            AppSpacing.verticalSm,
            const Text(
              'The shoot request has been cancelled.\nsuccessfully.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
