import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/routes.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';

class DeleteAccountLottieScreen extends ConsumerStatefulWidget {
  const DeleteAccountLottieScreen({super.key});

  @override
  ConsumerState<DeleteAccountLottieScreen> createState() =>
      _DeleteAccountLottieScreenState();
}

class _DeleteAccountLottieScreenState
    extends ConsumerState<DeleteAccountLottieScreen> {
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
    return AppScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(AppAssets.lottieSuccess, height: 180, repeat: false),
            const SizedBox(height: 24),
            Text(
              'Account Deleted',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your account has been successfully',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white30,
              ),
            ),
            Text(
              'deleted.',
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
