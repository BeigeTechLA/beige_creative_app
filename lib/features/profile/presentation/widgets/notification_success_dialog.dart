import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_cta_button.dart';

class NotificationSuccessSheet extends StatelessWidget {
  const NotificationSuccessSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (_) => const NotificationSuccessSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),

          // Circle Checkmark Badge with Starburst Confetti Accents
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0,
                left: 12,
                child: _ConfettiDot(color: AppColors.arcGreen, size: 8),
              ),
              Positioned(
                top: 8,
                right: 16,
                child: _ConfettiDot(color: AppColors.blueAccent, size: 6),
              ),
              Positioned(
                bottom: 4,
                left: 20,
                child: _ConfettiDot(color: AppColors.arcYellow, size: 7),
              ),
              Positioned(
                bottom: 8,
                right: 12,
                child: _ConfettiDot(color: AppColors.wine, size: 8),
              ),

              // Main Gold Circle Badge
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check,
                    size: 48,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Title & Subtitle
          Text(
            'Push Notification Updated',
            textAlign: TextAlign.center,
            style: AppTextStyles.displayStrong16w600.copyWith(
              color: AppColors.primary,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Text(
              'Your selected notification categories have been saved successfully.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.copyWith(
                color: AppColors.white60,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Done CTA Button
          AppCtaButton(
            label: 'Done',
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ConfettiDot extends StatelessWidget {
  const _ConfettiDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 3),
      ),
    );
  }
}
