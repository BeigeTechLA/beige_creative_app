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
  final String completedShootsLabel;
  final String upcomingShootsLabel;
  final String pendingRequestsLabel;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const HomeDashboardSummary({
    super.key,
    required this.completedShoots,
    required this.upcomingShoots,
    required this.pendingRequests,
    required this.completedShootsLabel,
    required this.upcomingShootsLabel,
    required this.pendingRequestsLabel,
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
                percentLabel: completedShootsLabel,
                iconPath: AppAssets.videoIcon,
                selectedIndex: selectedIndex,
                onSelect: onSelect,
              ),
              AppSpacing.verticalMd,
              _DashboardCard(
                index: 1,
                title: "Upcoming shoots",
                count: upcomingShoots,
                percentLabel: upcomingShootsLabel,
                iconPath: AppAssets.calendarIcon,
                selectedIndex: selectedIndex,
                onSelect: onSelect,
              ),
              AppSpacing.verticalMd,
              _DashboardCard(
                index: 2,
                title: "Pending Requests",
                count: pendingRequests,
                percentLabel: pendingRequestsLabel,
                iconPath: AppAssets.clockIcon,
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
  final String percentLabel;
  final String iconPath;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _DashboardCard({
    required this.index,
    required this.title,
    required this.count,
    required this.percentLabel,
    required this.iconPath,
    required this.selectedIndex,
    required this.onSelect,
  });

  Color _getTrendColor(String label, bool isSelected) {
    final bool isNegative = label.contains('-') || label.contains('▼');
    if (isSelected) {
      return isNegative ? const Color(0xFFB71C1C) : const Color(0xFF1B5E20);
    } else {
      return isNegative ? AppColors.errorAccent : AppColors.online;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedIndex == index;
    final String countText = count.toString().padLeft(2, '0');

    final String percentagePart;
    final String restPart;

    if (percentLabel.isNotEmpty) {
      final percentageRegex = RegExp(r'^([▲▼]?\s*[+-]?\d+(?:\.\d+)?%)');
      final match = percentageRegex.firstMatch(percentLabel);
      if (match != null) {
        percentagePart = match.group(1)!;
        restPart = percentLabel.substring(percentagePart.length);
      } else {
        percentagePart = "";
        restPart = percentLabel;
      }
    } else {
      percentagePart = "";
      restPart = "";
    }

    return GestureDetector(
      onTap: () => onSelect(index),
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
                  countText,
                  style: AppTextStyles.body22w700.copyWith(
                    color: isSelected ? AppColors.black : AppColors.white,
                  ),
                ),
                if (percentLabel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: percentagePart,
                          style: TextStyle(
                            color: _getTrendColor(percentagePart, isSelected),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (restPart.isNotEmpty)
                          TextSpan(
                            text: restPart,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.textDark
                                  : AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                AppSpacing.verticalXxs,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
