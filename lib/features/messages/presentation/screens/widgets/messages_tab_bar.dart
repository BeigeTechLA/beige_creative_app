import 'package:flutter/material.dart';

import '../../../../../app/colors.dart';
import '../../../../../app/durations.dart';
import '../../../../../app/radii.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';
import '../../../domain/entities/conversation.dart';

/// Pill segmented tab bar — All / Shoots / Admin. Active tab uses
/// [AppColors.primary] cream surface with dark text; inactive tabs render
/// transparent with [AppColors.textSecondary] text.
class MessagesTabBar extends StatelessWidget {
  const MessagesTabBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ConversationTab selected;
  final ValueChanged<ConversationTab> onChanged;

  static const _items = <(ConversationTab, String)>[
    (ConversationTab.all, 'All'),
    (ConversationTab.shoots, 'Messages'),
    (ConversationTab.admin, 'Admin'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 53,
      padding: const EdgeInsets.all(AppSpacing.tabInnerPad),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: AppRadii.xlAll,
      ),
      child: Row(
        children: [
          for (final entry in _items)
            Expanded(
              child: _Pill(
                label: entry.$2,
                isActive: entry.$1 == selected,
                onTap: () => onChanged(entry.$1),
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
      label: '$label conversations',
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
            style: AppTextStyles.body14Medium.copyWith(
              color: isActive ? AppColors.textHeading : AppColors.white30,
            ),
          ),
        ),
      ),
    );
  }
}
