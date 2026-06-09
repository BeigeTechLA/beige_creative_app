import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

class MeetingScheduledScreen extends ConsumerStatefulWidget {
  const MeetingScheduledScreen({super.key});

  @override
  ConsumerState<MeetingScheduledScreen> createState() =>
      _MeetingScheduledScreenState();
}

class _MeetingScheduledScreenState
    extends ConsumerState<MeetingScheduledScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), _goToList);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToList() {
    if (!mounted) return;
    context.goNamed(Routes.meetings.name);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _goToList();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    AppAssets.lottieSuccess,
                    height: 160,
                    repeat: false,
                  ),
                  AppSpacing.verticalBase,
                  const Text(
                    'Meeting Scheduled',
                    style: AppTextStyles.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.verticalSm,
                  Text(
                    'Your meeting has been created and invites are on their way to participants.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
