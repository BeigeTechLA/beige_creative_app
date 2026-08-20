import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';

/// Frosted "time ago" pill shown over shoot cover images ("39m Ago").
///
/// Uses a backdrop blur plus a semi-transparent white fill and border so the
/// label stays legible over both dark and bright cover images.
class TimeAgoPill extends StatelessWidget {
  const TimeAgoPill({super.key, required this.label});

  /// Raw relative-time label from the API (e.g. "39m ago"). The trailing
  /// "ago" is title-cased for display ("39m Ago").
  final String label;

  static String _titleCaseAgo(String value) =>
      value.replaceAll(RegExp(r'\bago\b'), 'Ago');

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.pillAll,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: const Color(0x33FFFFFF), // #FFFFFF33 (20% opacity white)
            borderRadius: AppRadii.pillAll,
            border: Border.all(
              color: const Color(0x66FFFFFF), // #FFFFFF66 (40% opacity white)
              width: 1,
            ),
          ),
          child: Text(
            _titleCaseAgo(label),
            style: AppTextStyles.body10.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
