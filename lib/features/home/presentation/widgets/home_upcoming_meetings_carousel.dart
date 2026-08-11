import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../core/providers/guest_mode_provider.dart';
import '../../../../shared/widgets/login_dialog.dart';
import '../../../meetings/domain/models/meeting.dart';
import '../../../meetings/presentation/widgets/meeting_card.dart';
import '../../../meetings/presentation/widgets/meeting_details_sheet.dart';
import '../../../meetings/presentation/util/launch_meeting_link.dart';

/// "Upcoming Meetings" stacked-card carousel. Renders 1 card when there is a
/// single upcoming meeting; renders an animated 3-card swipeable stack when
/// there are multiple.
///
/// Mimics the changing pattern of [HomeUpcomingCarousel] but tailored for
/// online meetings.
class HomeUpcomingMeetingsCarousel extends ConsumerWidget {
  final List<Meeting> upcomingMeetings;
  final int currentIndex;
  final AnimationController controller;
  final VoidCallback onCardTap;
  final VoidCallback onSwipeNext;
  final VoidCallback onSwipePrevious;

  const HomeUpcomingMeetingsCarousel({
    super.key,
    required this.upcomingMeetings,
    required this.currentIndex,
    required this.controller,
    required this.onCardTap,
    required this.onSwipeNext,
    required this.onSwipePrevious,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (upcomingMeetings.isEmpty) {
      return const SizedBox.shrink();
    }
    final n = upcomingMeetings.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            if (ref.read(guestModeProvider)) {
              showLoginDialog(context);
              return;
            }
            context.goNamed(Routes.meetings.name);
          },
          borderRadius: AppRadii.mdAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Upcoming Meetings",
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
        ),
        const SizedBox(height: 16),
        // ==================== UPCOMING MEETINGS CARD STACK ====================
        Builder(
          builder: (context) {
            // ONLY 1 DATA → NO SWIPE, NO STACK
            if (n == 1) {
              return _buildCard(context, upcomingMeetings[0], isMain: true);
            }

            // MULTIPLE DATA → SWIPE + STACK
            return GestureDetector(
              onTap: onCardTap,
              onHorizontalDragEnd: (details) {
                if (controller.isAnimating || upcomingMeetings.isEmpty) {
                  return;
                }
                if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
                  onCardTap();
                }
              },
              child: SizedBox(
                height: 350,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    // Guard against invalid animation values before calculating transforms.
                    double val = controller.value;
                    if (val.isNaN) val = 0.0;

                    // Front card transform.
                    double frontSlide = val * 300;
                    double frontOpacity = 1 - val;

                    // Back card transform.
                    double backOffsetX = 20 * (1 - val);
                    double backOffsetY = -20 * (1 - val);
                    double backScale = 0.96 + (0.04 * val);
                    double backRotate = 0.08 * (1 - val);

                    // Keep indices within the available bookings list.
                    int frontIndex = currentIndex % n;
                    int nextIndex = (currentIndex + 1) % n;

                    return Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // Back card.
                        Transform.translate(
                          offset: Offset(backOffsetX, backOffsetY),
                          child: Transform.rotate(
                            angle: backRotate,
                            child: Transform.scale(
                              scale: backScale,
                              child: Opacity(
                                opacity: 0.5 + (0.5 * val),
                                child: _buildCard(
                                  context,
                                  upcomingMeetings[nextIndex],
                                  isBack: true,
                                  isBackCard: val < 0.5,
                                  height: 300,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Front card.
                        Transform.translate(
                          offset: Offset(0, frontSlide),
                          child: Opacity(
                            opacity: frontOpacity,
                            child: _buildCard(
                              context,
                              upcomingMeetings[frontIndex],
                              isMain: true,
                              isBackCard: false,
                              height: 300,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context,
    Meeting meeting, {
    bool isMain = false,
    bool isBack = false,
    bool isMiddle = false,
    bool isBackCard = false,
    double? height,
    EdgeInsetsGeometry? margin,
  }) {
    final bgColor = isMain
        ? AppColors.surfaceMid
        : isMiddle
        ? AppColors.surfaceDim
        : AppColors.surfaceMute;

    return MeetingCard(
      meeting: meeting,
      backgroundColor: bgColor,
      onTap: onCardTap,
      onDetailTap: () =>
          showMeetingDetailsSheet(context, meetingId: meeting.id),
      onJoin: () => launchMeetingLink(context, meeting.link),
      isBackCard: isBackCard,
      height: height,
      margin: margin,
    );
  }
}
