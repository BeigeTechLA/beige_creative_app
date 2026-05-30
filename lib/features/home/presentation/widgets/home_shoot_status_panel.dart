import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../widgets/multi_arc_painter.dart';
import 'home_status_item.dart';

/// "Shoot Status" arc panel — Week/Month/Year dropdown + 4-arc chart +
/// 4 status rows (Successful / Pending / Rejected / Requests).
///
/// Pure presentation. Orchestrator owns counts + selected range + change
/// callback.
class HomeShootStatusPanel extends StatelessWidget {
  final int successfulShoots;
  final int pendingShoots;
  final int rejectedShoots;
  final int shootRequests;
  final String selectedRange;
  final List<String> rangeOptions;
  final ValueChanged<String> onRangeChanged;

  const HomeShootStatusPanel({
    super.key,
    required this.successfulShoots,
    required this.pendingShoots,
    required this.rejectedShoots,
    required this.shootRequests,
    required this.selectedRange,
    required this.rangeOptions,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final stats = [
      successfulShoots,
      pendingShoots,
      rejectedShoots,
      shootRequests,
    ];
    final total = stats.fold<int>(0, (sum, item) => sum + item);
    final arcValues = stats.map((e) {
      if (e == 0 || total == 0) {
        return 0.0;
      }
      return (e / total).clamp(0.0, 1.0);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Shoot Status",
              style: AppTextStyles.displayLabel15.copyWith(
                color: AppColors.white,
              ),
            ),
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.mld,
              ),
              decoration: BoxDecoration(
                color: AppColors.dashboardPanelDark,
                borderRadius: AppRadii.roundAll,
                border: Border.all(color: AppColors.darkCharcoal),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedRange,
                  dropdownColor: AppColors.surfaceStats,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.white24,
                    size: 20,
                  ),
                  style: AppTextStyles.body14Medium.copyWith(
                    color: AppColors.white,
                  ),
                  items: rangeOptions
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      onRangeChanged(val);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        AppSpacing.verticalBase,
        Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: AppColors.dashboardPanelDark,
            borderRadius: AppRadii.massiveAll,
            border: Border.all(
              color: AppColors.darkCharcoal,
              width: 0.6,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  height: 160,
                  width: 300,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      CustomPaint(
                        size: const Size(700, 150),
                        painter: MultiArcPainter(
                          values: arcValues,
                          colors: const [
                            AppColors.arcPurple,
                            AppColors.arcBlue,
                            AppColors.arcYellow,
                            AppColors.arcGreen,
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${successfulShoots + pendingShoots + rejectedShoots + shootRequests}",
                            style: AppTextStyles.body26Bold.copyWith(
                              color: AppColors.goldCream,
                            ),
                          ),
                          AppSpacing.verticalXxs,
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.statusGap),
              HomeStatusItem(
                count: "$successfulShoots",
                label: "Successful shoots",
                color: AppColors.arcPurple,
              ),
              HomeStatusItem(
                count: "$pendingShoots",
                label: "Pending shoots",
                color: AppColors.arcBlue,
              ),
              HomeStatusItem(
                count: "$rejectedShoots",
                label: "Rejected shoots",
                color: AppColors.arcYellow,
              ),
              HomeStatusItem(
                count: "$shootRequests",
                label: "Shoot Requests",
                color: AppColors.arcGreen,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
