import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

/// Styled version badge (e.g. "V2" or "V3 Latest").
class FmVersionTag extends StatelessWidget {
  final int? version;
  final bool isLatest;
  final double fontSize;

  const FmVersionTag({
    super.key,
    required this.version,
    this.isLatest = false,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final ver = version;
    if (ver == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.chipPaddingH,
            vertical: AppSpacing.chipPaddingV,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary20,
            borderRadius: isLatest
                ? const BorderRadius.horizontal(left: Radius.circular(12))
                : AppRadii.fullAll,
          ),
          child: Text(
            'V$ver',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ),
        if (isLatest)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.chipPaddingH,
              vertical: AppSpacing.chipPaddingV,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
            ),
            child: Text(
              'Latest',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
                fontSize: fontSize,
              ),
            ),
          ),
      ],
    );
  }
}
