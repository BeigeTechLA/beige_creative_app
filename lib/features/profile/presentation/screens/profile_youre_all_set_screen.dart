import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/routes.dart';
import '../../../../app/text_styles.dart';

class ProfileYoureAllSetScreen extends ConsumerStatefulWidget {
  const ProfileYoureAllSetScreen({super.key});

  @override
  ConsumerState<ProfileYoureAllSetScreen> createState() =>
      _ProfileYoureAllSetScreenState();
}

class _ProfileYoureAllSetScreenState
    extends ConsumerState<ProfileYoureAllSetScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.goNamed(Routes.login.name);
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
            Lottie.asset(AppAssets.lottieSuccess, height: 180, repeat: false),
            const SizedBox(height: 24),
            Text(
              "You're All Set",
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Congratulations! Your password has been\nchanged successfully',
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
