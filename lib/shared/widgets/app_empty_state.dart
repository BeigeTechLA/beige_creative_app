import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/colors.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';
import 'app_button.dart';

/// Empty-state placeholder. Icon or SVG + title + optional description +
/// optional CTA. Use anywhere a list, grid, or detail screen has no content
/// — keep the message specific to the absent thing ("No upcoming shoots yet"
/// beats "No data").
class AppEmptyState extends StatelessWidget {
  final IconData? icon;
  final String? svgAsset;
  final double iconSize;
  final String title;
  final String? description;
  final String? ctaLabel;
  final VoidCallback? onCta;

  const AppEmptyState({
    super.key,
    this.icon,
    this.svgAsset,
    this.iconSize = 56,
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
          if (svgAsset != null) ...[
            SvgPicture.asset(svgAsset!, height: iconSize),
            SizedBox(height: AppSpacing.base),
          ] else if (icon != null) ...[
            Icon(icon, size: iconSize, color: AppColors.textTertiary),
            SizedBox(height: AppSpacing.base),
          ],
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
