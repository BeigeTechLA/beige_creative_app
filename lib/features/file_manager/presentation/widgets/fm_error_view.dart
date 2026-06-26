import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_button.dart';

/// Centered error column + retry button. Used by both root + folder lists.
class FmErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const FmErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Retry',
              onPressed: onRetry,
              variant: AppButtonVariant.outline,
              fullWidth: false,
              size: AppButtonSize.sm,
            ),
          ],
        ),
      ),
    );
  }
}
