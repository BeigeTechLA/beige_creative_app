import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/durations.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../widgets/multi_arc_painter.dart';
import 'home_status_item.dart';

/// "Shoot Categories" arc panel — Photo / Video tabs + 4-arc chart +
/// 4 status rows (Photography / Videography / Rejected / Requests).
///
/// Pure presentation. Orchestrator owns counts + selectedTab + tab-change
/// callback.
class HomeShootCategoriesPanel extends StatelessWidget {
  final int selectedTab;
  final int categoryPhotoTotal;
  final int categoryVideoTotal;
  final int acceptPhotographyShoots;
  final int acceptVideographyShoots;
  final int rejectedPhoto;
  final int rejectedVideo;
  final int requestPhoto;
  final int requestVideo;
  final ValueChanged<int> onTabChanged;

  const HomeShootCategoriesPanel({
    super.key,
    required this.selectedTab,
    required this.categoryPhotoTotal,
    required this.categoryVideoTotal,
    required this.acceptPhotographyShoots,
    required this.acceptVideographyShoots,
    required this.rejectedPhoto,
    required this.rejectedVideo,
    required this.requestPhoto,
    required this.requestVideo,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categoryStats = [
      selectedTab == 0 ? acceptPhotographyShoots : acceptVideographyShoots,
      selectedTab == 0 ? 0 : acceptVideographyShoots,
      selectedTab == 0 ? rejectedPhoto : rejectedVideo,
      selectedTab == 0 ? requestPhoto : requestVideo,
    ];
    final categoryTotal = categoryStats.fold<int>(0, (sum, item) => sum + item);
    final categoryArcValues = categoryStats.map((e) {
      if (e == 0 || categoryTotal == 0) {
        return 0.0;
      }
      return (e / categoryTotal).clamp(0.0, 1.0);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Shoot Categories",
              style: AppTextStyles.displayLabel15.copyWith(
                color: AppColors.white,
              ),
            ),
            Container(
              height: 38,
              padding: const EdgeInsets.all(AppSpacing.xxs),
              decoration: BoxDecoration(
                color: AppColors.dashboardPanelDark,
                borderRadius: AppRadii.roundAll,
                border: Border.all(color: AppColors.darkCharcoal),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => onTabChanged(0),
                    child: AnimatedContainer(
                      duration: AppDurations.fast250,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        color: selectedTab == 0
                            ? AppColors.goldCream
                            : AppColors.transparent,
                        borderRadius: AppRadii.portfolioAll,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Photo",
                        style: AppTextStyles.bodyCompactMedium.copyWith(
                          color: selectedTab == 0
                              ? AppColors.black
                              : AppColors.white30,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onTabChanged(1),
                    child: AnimatedContainer(
                      duration: AppDurations.fast250,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        color: selectedTab == 1
                            ? AppColors.goldCream
                            : AppColors.transparent,
                        borderRadius: AppRadii.portfolioAll,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Video",
                        style: AppTextStyles.bodyCompactMedium.copyWith(
                          color: selectedTab == 1
                              ? AppColors.black
                              : AppColors.white30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        AppSpacing.verticalMld,
        Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: AppColors.black,
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
                          values: categoryArcValues,
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
                            selectedTab == 0
                                ? categoryPhotoTotal.toString()
                                : categoryVideoTotal.toString(),
                            //      Text(
                            //                                     selectedTab == 0?
                            //                                     acceptphotographyShoots.toString()
                            //                                     :.toString(),
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
                count: "$acceptPhotographyShoots",
                label: "Photography shoots",
                color: AppColors.arcPurple,
              ),
              HomeStatusItem(
                count: "$acceptVideographyShoots",
                label: "Videography shoots",
                color: AppColors.arcBlue,
              ),
              HomeStatusItem(
                count: selectedTab == 0 ? "$rejectedPhoto" : "$rejectedVideo",
                label: "Rejected shoots",
                color: AppColors.arcYellow,
              ),
              HomeStatusItem(
                count: selectedTab == 0 ? "$requestPhoto" : "$requestVideo",
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
