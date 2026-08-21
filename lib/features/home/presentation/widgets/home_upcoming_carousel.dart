import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../core/providers/guest_mode_provider.dart';
import '../../../../shared/widgets/login_dialog.dart';
import '../../../shoots/presentation/routes/shoots_args.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../model_class/cp_profile_model.dart';
import '../../../../model_class/upcoming_shoots_model.dart';
import '../../../../config/env.dart';
import '../../../../utility/date_time_utils.dart';

/// "Upcoming Shoots" stacked-card carousel. Renders 1 card when there is a
/// single upcoming shoot; renders an animated 3-card swipeable stack when
/// there are multiple.
class HomeUpcomingCarousel extends ConsumerStatefulWidget {
  final List<UpcomingShootDatum> upcomingShoots;
  final bool hasOriginalShoots;
  final int currentIndex;
  final AnimationController controller;
  final VoidCallback onCardTap;
  final VoidCallback onSwipeNext;
  final VoidCallback onSwipePrevious;

  const HomeUpcomingCarousel({
    super.key,
    required this.upcomingShoots,
    required this.hasOriginalShoots,
    required this.currentIndex,
    required this.controller,
    required this.onCardTap,
    required this.onSwipeNext,
    required this.onSwipePrevious,
  });

  @override
  ConsumerState<HomeUpcomingCarousel> createState() => _HomeUpcomingCarouselState();
}

class _HomeUpcomingCarouselState extends ConsumerState<HomeUpcomingCarousel> {
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
      'cpProfiles': datum.cpProfiles,
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
          onTap: () {
            if (ref.read(guestModeProvider)) {
              showLoginDialog(context);
              return;
            }
            context.goNamed(Routes.shoots.name);
          },
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

                  // ✅ 👉 MULTIPLE DATA → SWIPE + STACK (Add top margin for stacked card overflow -24px/-32px)
                  return Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: GestureDetector(
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
                const SizedBox(height: 25),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.mld,
                              vertical: AppSpacing.xs,
                            ),
                            backgroundColor: AppColors.primary,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.hugeAll,
                            ),
                          ),
                          onPressed: () {
                            if (ref.read(guestModeProvider)) {
                              showLoginDialog(context);
                              return;
                            }
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
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if ((data['cpProfiles'] as List<CpProfile>?)?.isNotEmpty == true)
                      Expanded(
                        flex: 4,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildMembersStack(
                            data['cpProfiles'] as List<CpProfile>,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersStack(List<CpProfile> profiles) {
    final displayProfiles = profiles.take(4).toList();
    final remaining = profiles.length - displayProfiles.length;
    const avatarSize = 22.0;

    return SizedBox(
      height: avatarSize,
      width: displayProfiles.length * 15.0 + (remaining > 0 ? 22.0 : 8.0),
      child: Stack(
        children: [
          for (int i = 0; i < displayProfiles.length; i++)
            Positioned(
              left: i * 14.0,
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceMid, width: 1.5),
                  color: AppColors.surfaceDim,
                ),
                child: ClipOval(
                  child: displayProfiles[i].profileImageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: Env.imageUrl + displayProfiles[i].profileImageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => _buildAvatarFallback(displayProfiles[i].name),
                        )
                      : _buildAvatarFallback(displayProfiles[i].name),
                ),
              ),
            ),
          if (remaining > 0)
            Positioned(
              left: displayProfiles.length * 14.0,
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                  border: Border.all(color: AppColors.surfaceMid, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  "+$remaining",
                  style: AppTextStyles.body10.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "M";
    return Container(
      color: AppColors.dashboardPanelDark,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.body10.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
