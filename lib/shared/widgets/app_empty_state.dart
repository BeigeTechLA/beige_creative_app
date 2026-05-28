import 'package:flutter/material.dart';

import '../../app/colors.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';
import 'app_button.dart';

/// Empty-state placeholder. Icon + title + optional description + optional CTA.
///
/// Use anywhere a list, grid, or detail screen has no content — keep the
/// message specific to the absent thing ("No upcoming shoots yet" beats "No
/// data").
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? ctaLabel;
  final VoidCallback? onCta;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.ctaLabel,
    this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    final showCta = ctaLabel != null && onCta != null;
    return Padding(
      padding: EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppColors.textTertiary),
          SizedBox(height: AppSpacing.base),
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            SizedBox(height: AppSpacing.sm),
            Text(
              description!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (showCta) ...[
            SizedBox(height: AppSpacing.xl),
            AppButton(
              label: ctaLabel!,
              onPressed: onCta,
              variant: AppButtonVariant.primary,
            ),
          ],
        ],
      ),
    );
  }
}
