import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

/// Single labeled count + colored ring row, used by both the "Shoot Status"
/// and "Shoot Categories" arc panels.
///
/// Lifted verbatim from `_statusItem` on `_HomeScreenState`.
class HomeStatusItem extends StatelessWidget {
  final String count;
  final String label;
  final Color color;

  const HomeStatusItem({
    super.key,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.statusItemPadV),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 70,
            padding:
                const EdgeInsets.symmetric(vertical: AppSpacing.statusItemPadV),
            decoration: BoxDecoration(
              borderRadius: AppRadii.roundAll,
              border: Border.all(
                color: color.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                count,
                style: AppTextStyles.bodyMediumStrong.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xxl),
              child: Text(
                label,
                textAlign: TextAlign.right,
                style: AppTextStyles.body13.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
