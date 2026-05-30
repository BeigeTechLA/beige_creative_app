import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

/// Per-hour / experience / radius card row + skill chip wrap.
/// Inputs are pre-formatted strings to keep the widget pure.
class ProfileStatsPanel extends StatelessWidget {
  final String hourlyRateLabel;
  final String experienceLabel;
  final String radiusLabel;
  final List<String> skills;

  const ProfileStatsPanel({
    super.key,
    required this.hourlyRateLabel,
    required this.experienceLabel,
    required this.radiusLabel,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _InfoCard(
              icon: AppAssets.doller,
              value: hourlyRateLabel,
              title: 'Per Hour',
            ),
            _InfoCard(
              icon: AppAssets.medal,
              value: experienceLabel,
              title: 'Experience',
            ),
            _InfoCard(
              icon: AppAssets.map,
              value: radiusLabel,
              title: 'Radius',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          children: _buildSkillChips(skills),
        ),
      ],
    );
  }

  // Legacy semantics: first 2 chips labelled "Skill 1"/"Skill 2", then "+N".
  List<Widget> _buildSkillChips(List<String> skills) {
    final chips = <Widget>[];
    for (int i = 0; i < skills.length && i < 2; i++) {
      chips.add(_SkillChip(text: 'Skill ${i + 1}'));
    }
    if (skills.length > 2) {
      chips.add(_SkillChip(text: '+${skills.length - 2}'));
    }
    return chips;
  }
}

class _InfoCard extends StatelessWidget {
  final String icon;
  final String value;
  final String title;

  const _InfoCard({
    required this.icon,
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: AppRadii.lgAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.40),
            AppColors.primary.withValues(alpha: 0.04),
            AppColors.primary.withValues(alpha: 0.28),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.fine),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceStats,
            borderRadius: AppRadii.statsInnerAll,
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: -1,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  width: 38,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadii.bottomXl,
                  ),
                  child: SvgPicture.asset(
                    icon,
                    color: AppColors.black,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    value,
                    style: AppTextStyles.bodyLargeMedium
                        .copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: AppTextStyles.body12.copyWith(
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String text;

  const _SkillChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smd,
        vertical: AppSpacing.dropdownIconInset,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: AppRadii.mdAll,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Text(text, style: AppTextStyles.body12),
    );
  }
}
