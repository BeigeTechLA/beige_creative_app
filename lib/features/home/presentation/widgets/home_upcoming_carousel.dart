import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../shoots/presentation/routes/shoots_args.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../model_class/upcoming_shoots_model.dart';
import '../../../../config/env.dart';
import '../../../../utility/date_time_utils.dart';

/// "Upcoming Shoots" stacked-card carousel. Renders 1 card when there is a
/// single upcoming shoot; renders an animated 3-card swipeable stack when
/// there are multiple.
///
/// Animation controller, current index, and tap/swipe handlers stay with the
/// orchestrator — this widget reads them through immutable params.
///
/// Note (Task 4.15 decompose): the legacy `home_screen.dart` contained a
/// large commented-out earlier version of this carousel (search filter + an
/// alternate Stack layout). It was unreachable code; not carried over —
/// Task 4.16 will formally close that out.
class HomeUpcomingCarousel extends StatelessWidget {
  final List<UpcomingShootDatum> upcomingShoots;
  final int currentIndex;
  final AnimationController controller;
  final VoidCallback onCardTap;
  final VoidCallback onSwipeNext;
  final VoidCallback onSwipePrevious;

  const HomeUpcomingCarousel({
    super.key,
    required this.upcomingShoots,
    required this.currentIndex,
    required this.controller,
    required this.onCardTap,
    required this.onSwipeNext,
    required this.onSwipePrevious,
  });

  // Helper to convert UpcomingShootDatum to a map for card display.
  static Map<String, dynamic> _cardFromDatum(UpcomingShootDatum datum) {
    return {
      'image': datum.shootTypeImageUrl,
      'projectId': datum.projectId,
      'title': datum.projectName,
      'date':
          DateTimeUtils.formatReadableDate(datum.eventDate.toIso8601String()),
      'time': '${datum.startTime} - ${datum.endTime}',
      'location': datum.eventLocation,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (upcomingShoots.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Upcoming Shoots ",
              style: AppTextStyles.displayLabel14.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sectionGapLg),
        // ==================== UPCOMING SHOOTS CARD STACK (DYNAMIC) ====================
        Builder(
          builder: (context) {
            final n = upcomingShoots.length;

            // ✅ 👉 ONLY 1 DATA → NO SWIPE, NO STACK
            if (n == 1) {
              final current = _cardFromDatum(upcomingShoots[0]);
              return _buildCard(context, current, isMain: true);
            }

            // ✅ 👉 MULTIPLE DATA → SWIPE + STACK
            return GestureDetector(
              onTap: onCardTap,
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;

                if (details.primaryVelocity! > 0) {
                  onSwipePrevious();
                } else if (details.primaryVelocity! < 0) {
                  onSwipeNext();
                }
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;

                  final currentDatum = upcomingShoots[currentIndex % n];
                  final nextDatum = upcomingShoots[(currentIndex + 1) % n];
                  final next2Datum =
                      n > 2 ? upcomingShoots[(currentIndex + 2) % n] : null;

                  final current = _cardFromDatum(currentDatum);
                  final next = _cardFromDatum(nextDatum);
                  final next2 =
                      next2Datum != null ? _cardFromDatum(next2Datum) : null;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 👉 3rd card
                      if (next2 != null)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          top: controller.isAnimating ? -32 : -24,
                          left: totalWidth * 0.07,
                          right: totalWidth * 0.07,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: controller.isAnimating ? 0.5 : 1,
                            child: _buildCard(context, next2, isBack: true),
                          ),
                        ),

                      // 👉 2nd card
                      if (n >= 2)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          top: controller.isAnimating ? -20 : -12,
                          left: totalWidth * 0.035,
                          right: totalWidth * 0.035,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: controller.isAnimating ? 0.7 : 1,
                            child: _buildCard(
                              context,
                              next,
                              isBack: true,
                              isMiddle: true,
                            ),
                          ),
                        ),

                      // 👉 MAIN CARD
                      AnimatedBuilder(
                        animation: controller,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, controller.value * 200),
                            child: Opacity(
                              opacity: 1 - controller.value,
                              child: child,
                            ),
                          );
                        },
                        child: _buildCard(context, current, isMain: true),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.dashboardDividerGap),
        Divider(color: AppColors.dividerDark, thickness: 0.8),
      ],
    );
  }

  // Reusable card widget to avoid duplication.
  Widget _buildCard(
    BuildContext context,
    Map<String, dynamic> data, {
    bool isMain = false,
    bool isBack = false,
    bool isMiddle = false,
  }) {
    final bgColor = isMain
        ? AppColors.surfaceMid
        : isMiddle
            ? AppColors.surfaceDim
            : AppColors.surfaceMute;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.mld),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
        borderRadius: AppRadii.xxxlAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: AppRadii.xlAll,
            child: CachedNetworkImage(
              imageUrl: Env.imageUrl + ((data['image'] ?? '') as String),
              height: 169,
              width: 117,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) {
                return SvgPicture.asset(
                  AppAssets.image_holder,
                  height: 169,
                  width: 117,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          const SizedBox(width: AppSpacing.mld),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMediumStrong.copyWith(
                    color: AppColors.white,
                  ),
                ),
                Divider(color: AppColors.dividerDark, thickness: 0.8),
                AppSpacing.verticalXs,
                Row(
                  children: [
                    SvgPicture.asset(AppAssets.calender, width: 14, height: 14),
                    const SizedBox(width: AppSpacing.tabInnerPad),
                    Text(
                      data['date'],
                      style:
                          AppTextStyles.body12.copyWith(color: AppColors.white),
                    ),
                  ],
                ),
                AppSpacing.verticalXs,
                Row(
                  children: [
                    SvgPicture.asset(AppAssets.time, width: 14, height: 14),
                    const SizedBox(width: AppSpacing.tabInnerPad),
                    Text(
                      data['time'],
                      style:
                          AppTextStyles.body12.copyWith(color: AppColors.white),
                    ),
                  ],
                ),
                AppSpacing.verticalXs,
                Row(
                  children: [
                    SvgPicture.asset(AppAssets.location, width: 14, height: 14),
                    const SizedBox(width: AppSpacing.tabInnerPad),
                    Expanded(
                      child: Text(
                        data['location'],
                        style: AppTextStyles.body12
                            .copyWith(color: AppColors.white),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalMd,
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.hugeAll,
                          ),
                        ),
                        onPressed: () {
                          context.pushNamed(
                            Routes.upcomingShootDetails.name,
                            extra: UpcomingShootDetailsArgs(
                              projectId: data['projectId'] as int?,
                            ).toExtra(),
                          );
                        },
                        child: Text(
                          "View Details",
                          style: AppTextStyles.body11.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
