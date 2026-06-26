import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/durations.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../domain/models/fm_tab.dart';

/// Root file-manager tab bar — All Files / Recent / Linked / Common Events.
/// Mirrors `MeetingsTabBar`: pill row, gold gradient on the active item.
/// Horizontally scrollable so 4 long labels survive narrow screens.
class FmTabBar extends StatelessWidget {
  final FmTab selected;
  final ValueChanged<FmTab> onChanged;

  const FmTabBar({super.key, required this.selected, required this.onChanged});

  static const _items = FmTab.values;

  @override
  Widget build(BuildContext context) {
    // Clamp at 1.2x to prevent labels from pushing off-screen on extreme scales
    final mq = MediaQuery.of(context);
    final clamped = mq.copyWith(
      textScaler: TextScaler.linear(mq.textScaler.scale(1.0).clamp(1.0, 1.2)),
    );
    return MediaQuery(
      data: clamped,
      child: SizedBox(
        height: 48,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
          child: Row(
            children: [
              for (int i = 0; i < _items.length; i++) ...[
                _TabItem(
                  label: _items[i].label,
                  isActive: _items[i] == selected,
                  onTap: () => onChanged(_items[i]),
                ),
                if (i < _items.length - 1)
                  const SizedBox(width: AppSpacing.lg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast250,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.primary : AppColors.transparent,
                width: 2.0,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.body14Medium.copyWith(
              color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
