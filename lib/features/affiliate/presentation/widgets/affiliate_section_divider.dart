import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/spacing.dart';

/// Horizontal hairline divider with a soft gradient used between sections
/// on the Affiliate screen.
class AffiliateSectionDivider extends StatelessWidget {
  final double centerAlpha;
  final double edgeAlpha;

  const AffiliateSectionDivider({
    super.key,
    this.centerAlpha = 0.24,
    this.edgeAlpha = 0.09,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,


        vertical: AppSpacing.smd,
      ),
      child: Container(
        height: 1,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.white.withValues(alpha: edgeAlpha),
              AppColors.white.withValues(alpha: centerAlpha),
              AppColors.white.withValues(alpha: edgeAlpha),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }
}
