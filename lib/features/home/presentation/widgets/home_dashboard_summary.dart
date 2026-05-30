import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

/// "Your Dashboard" summary panel with 3 tap-to-highlight cards
/// (Completed shoots / Upcoming shoots / Pending Requests).
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
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.darkCharcoal,
              width: 0.6,
            ),
            color: AppColors.surfaceMid,
            borderRadius: AppRadii.portfolioCompactAll,
          ),
          child: Column(
            children: [
              _DashboardCard(
                index: 0,
                title: "Completed shoots",
                count: completedShoots,
                percentColor: AppColors.success,
                iconPath: AppAssets.video_icon,
                selectedIndex: selectedIndex,
                onSelect: onSelect,
              ),
              AppSpacing.verticalMd,
              _DashboardCard(
                index: 1,
                title: "Upcoming shoots",
                count: upcomingShoots,
                percentColor: AppColors.success,
                iconPath: AppAssets.calendar_icon,
                selectedIndex: selectedIndex,
                onSelect: onSelect,
              ),
              AppSpacing.verticalMd,
              _DashboardCard(
                index: 2,
                title: "Pending Requests",
                count: pendingRequests,
                percentColor: AppColors.error,
                iconPath: AppAssets.clock_icon,
                selectedIndex: selectedIndex,
                onSelect: onSelect,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final int index;
  final String title;
  final int count;
  // ignore: unused_element_parameter
  final Color percentColor;
  final String iconPath;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _DashboardCard({
    required this.index,
    required this.title,
    required this.count,
    required this.percentColor,
    required this.iconPath,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onSelect(index),
      //  borderRadius: AppRadii.xxlAll,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 86),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.mld,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.transparent,
          borderRadius: AppRadii.xxlAll,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmallMedium.copyWith(
                    color: isSelected
                        ? AppColors.black
                        : AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.dropdownIconInset),
                Text(
                  count.toString(),
                  style: AppTextStyles.body22w700.copyWith(
                    color: isSelected ? AppColors.black : AppColors.white,
                  ),
                ),
                AppSpacing.verticalXxs,
                /*     Text(
                  percent,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? AppColors.success : percentColor,
                  ),
                ),*/
              ],
            ),
            CircleAvatar(
              radius: 17,
              backgroundColor: isSelected
                  ? AppColors.black
                  : AppColors.dashboardPanelDark,
              child: SvgPicture.asset(
                iconPath,
                width: 17,
                height: 17,
                colorFilter: ColorFilter.mode(
                  isSelected ? AppColors.primary : AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              // child: SvgPicture.asset(
              //   iconPath,
              //   width: 16,
              //   height: 16,
              //   color: isSelected ? AppColors.white : AppColors.white70,
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
