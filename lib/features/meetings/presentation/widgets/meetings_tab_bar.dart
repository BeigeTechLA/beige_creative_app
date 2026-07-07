import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/durations.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../domain/models/meetings_tab.dart';

/// Pill segmented tab bar — Upcoming / Completed. Active pill uses
/// the gold horizontal gradient; inactive pills sit flat on the surface.
class MeetingsTabBar extends StatelessWidget {
  const MeetingsTabBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final MeetingsTab selected;
  final ValueChanged<MeetingsTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 53,
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: AppRadii.xlAll,
      ),
      child: Row(
        children: [
          for (final tab in MeetingsTab.values)
            Expanded(
              child: _Pill(
                label: tab.label,
                isActive: tab == selected,
                onTap: () => onChanged(tab),
              ),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: '$label meetings',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast250,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            gradient: isActive ? AppColors.goldHorizontalGradient : null,
            borderRadius: AppRadii.mldAll,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: isActive ? AppColors.textHeading : AppColors.white30,
            ),
          ),
        ),
      ),
    );
  }
}
