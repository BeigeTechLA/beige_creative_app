import 'package:flutter/material.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_count_card.dart';

/// "Your Dashboard" summary panel with 3 tap-to-highlight cards
/// (Completed shoots / Pending Requests / Upcoming shoots).
///
/// Pure presentation. Orchestrator owns counts + selected index +
/// `onSelect(index)` callback.
class HomeDashboardSummary extends StatelessWidget {
  final int completedShoots;
  final int upcomingShoots;
  final int pendingRequests;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const HomeDashboardSummary({
    super.key,
    required this.completedShoots,
    required this.upcomingShoots,
    required this.pendingRequests,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Your Dashboard",
              style: AppTextStyles.displayLabel14.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
        AppSpacing.verticalBase,
        SizedBox(
          height: 76,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              AppCountCard(
                number: '$completedShoots',
                title: 'Completed Shoots',
                iconPath: AppAssets.videoIcon,
                width: 160,
                onTap: () => onSelect(0),
              ),
              AppCountCard(
                number: '$pendingRequests',
                title: 'Pending Requests',
                iconPath: AppAssets.clockIcon,
                width: 160,
                onTap: () => onSelect(2),
              ),
              AppCountCard(
                number: '$upcomingShoots',
                title: 'Upcoming Shoots',
                iconPath: AppAssets.calendarIcon,
                width: 160,
                onTap: () => onSelect(1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
