import 'package:beige_creative_app/app/assets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../app/route_names.dart';
import '../../app/colors.dart';
import '../../app/text_styles.dart';


class DeleteAccountLottieScreen extends StatefulWidget {
  const DeleteAccountLottieScreen({super.key});

  @override
  State<DeleteAccountLottieScreen> createState() => _DeleteAccountLottieScreenState();
}

class _DeleteAccountLottieScreenState extends State<DeleteAccountLottieScreen> {
  @override
  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 3),
          () {

        if (mounted) {

          context.goNamed(
            RouteNames.login,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Lottie.asset(
             AppAssets.lottie1,
              height: 180,
              repeat: false,
            ),

            const SizedBox(height: 24),

            Text(
              "Account Deleted",
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
            ),

            const SizedBox(height: 8),

            Text(
              "Your account has been successfully.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white30),
            ),
            Text(
              "deleted.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white30),
            ),
          ],
        ),
      ),
    );
  }
}