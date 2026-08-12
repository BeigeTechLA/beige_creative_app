import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/loading.dart';

class NotificationSuccessScreen extends StatefulWidget {
  const NotificationSuccessScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NotificationSuccessScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<NotificationSuccessScreen> createState() =>
      _NotificationSuccessScreenState();
}

class _NotificationSuccessScreenState
    extends State<NotificationSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-dismiss full screen after 2.5s (plays Lottie 1 time then auto pops, matching DeleteAccountLottieScreen pattern)
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Success Animation (Plays 1 time)
              const AppSuccessAnimation(
                height: 180,
                repeat: false,
              ),
              const SizedBox(height: 32),

              // Title & Subtitle
              Text(
                'Push Notification Updated',
                textAlign: TextAlign.center,
                style: AppTextStyles.displayStrong16w600.copyWith(
                  color: AppColors.primary,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your selected notification categories have been saved successfully.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body14.copyWith(
                  color: AppColors.white60,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Backward compatibility typedef for [NotificationSuccessScreen]
typedef NotificationSuccessSheet = NotificationSuccessScreen;
