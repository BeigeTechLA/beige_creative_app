import 'package:flutter/material.dart';

import '../../app/colors.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';

/// Centered loading spinner with optional caption. Default surface is the
/// app `background`; pass a different [backgroundColor] when overlaying.
class AppLoading extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;

  const AppLoading({
    super.key,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 2.5,
          ),
          if (message != null) ...[
            SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
