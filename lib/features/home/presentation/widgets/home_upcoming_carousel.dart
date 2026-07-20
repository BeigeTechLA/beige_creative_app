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
class HomeUpcomingCarousel extends StatefulWidget {
  final List<UpcomingShootDatum> upcomingShoots;
  final bool hasOriginalShoots;
  final int currentIndex;
  final AnimationController controller;
  final VoidCallback onCardTap;
  final VoidCallback onSwipeNext;
  final VoidCallback onSwipePrevious;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTap;
  final bool isFilterActive;

  const HomeUpcomingCarousel({
    super.key,
    required this.upcomingShoots,
    required this.hasOriginalShoots,
    required this.currentIndex,
    required this.controller,
    required this.onCardTap,
    required this.onSwipeNext,
    required this.onSwipePrevious,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.isFilterActive,
  });

  @override
  State<HomeUpcomingCarousel> createState() => _HomeUpcomingCarouselState();
}

class _HomeUpcomingCarouselState extends State<HomeUpcomingCarousel> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant HomeUpcomingCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery &&
        widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      'rawEventDate': datum.eventDate,
      'rawStartTime': datum.startTime,
      'isCompleted': datum.isCompleted,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.hasOriginalShoots) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => context.goNamed(Routes.shoots.name),
          borderRadius: AppRadii.mdAll,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Upcoming Shoots",
                style: AppTextStyles.displayLabel16.copyWith(
                  color: AppColors.white,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_right,
                color: AppColors.white,
                size: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Search & Filter Row
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.12),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SvgPicture.asset(
                        AppAssets.searchIcon,
                        colorFilter: ColorFilter.mode(
                          AppColors.white.withValues(alpha: 0.4),
                          BlendMode.srcIn,
                        ),
                        width: 18,
                        height: 18,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: widget.onSearchChanged,
                        style: AppTextStyles.body14.copyWith(color: AppColors.white),
                        cursorColor: AppColors.primary,
                        decoration: InputDecoration(
                          hintText: "Search events or crew...",
                          hintStyle: AppTextStyles.body12.copyWith(
                            color: AppColors.white.withValues(alpha: 0.4),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: widget.onFilterTap,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: widget.isFilterActive ? AppColors.primary20 : AppColors.surfaceVariant,
                  border: Border.all(
                    color: widget.isFilterActive 
                        ? AppColors.primary
                        : AppColors.white.withValues(alpha: 0.12),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Filter",
                      style: AppTextStyles.body12.copyWith(
                        color: widget.isFilterActive ? AppColors.primary : AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      AppAssets.iconFilter,
                      colorFilter: ColorFilter.mode(
                        widget.isFilterActive ? AppColors.primary : AppColors.white,
                        BlendMode.srcIn,
                      ),
                      width: 16,
                      height: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        // ==================== UPCOMING SHOOTS CARD STACK (DYNAMIC) ====================
        widget.upcomingShoots.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(
                  child: Text(
                    "No upcoming shoots match filters.",
                    style: AppTextStyles.body12.copyWith(
                      color: AppColors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              )
            : Builder(
                builder: (context) {
                  final n = widget.upcomingShoots.length;

                  // ✅ 👉 ONLY 1 DATA → NO SWIPE, NO STACK
                  if (n == 1) {
                    final current = _cardFromDatum(widget.upcomingShoots[0]);
                    return _buildCard(context, current, isMain: true);
                  }

                  // ✅ 👉 MULTIPLE DATA → SWIPE + STACK
                  return GestureDetector(
                    onTap: widget.onCardTap,
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity == null) return;

                      if (details.primaryVelocity! > 0) {
                        widget.onSwipePrevious();
                      } else if (details.primaryVelocity! < 0) {
                        widget.onSwipeNext();
                      }
                    },
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final totalWidth = constraints.maxWidth;

                        final currentDatum = widget.upcomingShoots[widget.currentIndex % n];
                        final nextDatum = widget.upcomingShoots[(widget.currentIndex + 1) % n];
                        final next2Datum =
                            n > 2 ? widget.upcomingShoots[(widget.currentIndex + 2) % n] : null;

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
                                top: widget.controller.isAnimating ? -32 : -24,
                                left: totalWidth * 0.07,
                                right: totalWidth * 0.07,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: widget.controller.isAnimating ? 0.5 : 1,
                                  child: _buildCard(context, next2, isBack: true),
                                ),
                              ),

                            // 👉 2nd card
                            if (n >= 2)
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                top: widget.controller.isAnimating ? -20 : -12,
                                left: totalWidth * 0.035,
                                right: totalWidth * 0.035,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: widget.controller.isAnimating ? 0.7 : 1,
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
                              animation: widget.controller,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, widget.controller.value * 200),
                                  child: Opacity(
                                    opacity: 1 - widget.controller.value,
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
        // const SizedBox(height: AppSpacing.dashboardDividerGap),
        // Divider(color: AppColors.dividerDark, thickness: 0.8),
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
                  AppAssets.imageHolder,
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
                    SvgPicture.asset(AppAssets.calendar, width: 14, height: 14),
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
                Builder(
                  builder: (context) {
                    final isActionable = DateTimeUtils.isActionableBeforeOneHour(
                      eventDate: data['rawEventDate'] as DateTime?,
                      startTime: data['rawStartTime'] as String?,
                      status: data['isCompleted'] == true ? 'completed' : 'pending',
                      crewAccept: 0,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isActionable) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.shootAcceptButtonBackground,
                                    foregroundColor:
                                        AppColors.shootAcceptButtonText,
                                    elevation: 0,
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                  ),
                                  onPressed: () {
                                    final projId = data['projectId'] as int?;
                                    if (projId != null) {
                                      // Action handle
                                    }
                                  },
                                  child: Text(
                                    "Accept",
                                    style: AppTextStyles.body10.copyWith(
                                      color: AppColors.shootAcceptButtonText,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.shootDeclineButtonBackground,
                                    foregroundColor:
                                        AppColors.shootDeclineButtonText,
                                    elevation: 0,
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                  ),
                                  onPressed: () {
                                    final projId = data['projectId'] as int?;
                                    if (projId != null) {
                                      context.pushNamed(
                                        Routes.cancelShoot.name,
                                        extra: CancelShootArgs(
                                          projectId: projId,
                                        ).toExtra(),
                                      );
                                    }
                                  },
                                  child: Text(
                                    "Decline",
                                    style: AppTextStyles.body10.copyWith(
                                      color: AppColors.shootDeclineButtonText,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
