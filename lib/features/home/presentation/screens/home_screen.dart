import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../providers/home_notifier.dart';
import '../widgets/common/home_section_divider.dart';
import '../widgets/home_availability_section.dart';
import '../widgets/home_dashboard_summary.dart';
import '../widgets/home_pending_shoot_card.dart';
import '../widgets/home_shoot_categories_panel.dart';
import '../widgets/home_shoot_status_panel.dart';
import '../widgets/home_upcoming_carousel.dart';
import '../../../shoots/presentation/routes/shoots_args.dart';
import '../widgets/home_upcoming_meetings_carousel.dart';
import '../widgets/home_welcome_header.dart';

import '../../../../shared/widgets/loading.dart';
import '../../../../shared/widgets/top_message.dart';

/// Dashboard ("Home") screen — Riverpod-backed (Task 4.16).
///
/// All data state is owned by [homeNotifierProvider]. The widget retains only
/// `AnimationController` + carousel `_currentIndex` because those are
/// animation-lifecycle state that requires `TickerProviderStateMixin`.
///
/// Class name preserved as `HomeScreen` so the `main_screen.dart` import
/// retarget is a one-liner.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;

  late AnimationController _meetingsController;
  int _meetingsCurrentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final upcoming = ref
            .read(homeNotifierProvider)
            .filteredUpcomingShootsList;
        if (upcoming.isNotEmpty) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % upcoming.length;
          });
          _controller.reset();
        }
      }
    });

    _meetingsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _meetingsController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final upcoming = ref.read(homeNotifierProvider).upcomingMeetingsList;
        if (upcoming.isNotEmpty) {
          setState(() {
            _meetingsCurrentIndex =
                (_meetingsCurrentIndex + 1) % upcoming.length;
          });
          _meetingsController.reset();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _meetingsController.dispose();
    super.dispose();
  }

  void _goToNext() {
    final upcoming = ref.read(homeNotifierProvider).filteredUpcomingShootsList;
    if (!_controller.isAnimating && upcoming.isNotEmpty) {
      _controller.forward();
    }
  }

  void _goToPrevious() {
    final upcoming = ref.read(homeNotifierProvider).filteredUpcomingShootsList;
    if (!_controller.isAnimating && upcoming.isNotEmpty) {
      setState(() {
        _currentIndex = (_currentIndex - 1 + upcoming.length) % upcoming.length;
      });
    }
  }

  void _onCardTap() {
    final upcoming = ref.read(homeNotifierProvider).filteredUpcomingShootsList;
    if (!_controller.isAnimating && upcoming.isNotEmpty) {
      _controller.forward();
    }
  }

  void _goToNextMeeting() {
    final upcoming = ref.read(homeNotifierProvider).upcomingMeetingsList;
    if (!_meetingsController.isAnimating && upcoming.isNotEmpty) {
      _meetingsController.forward();
    }
  }

  void _goToPreviousMeeting() {
    final upcoming = ref.read(homeNotifierProvider).upcomingMeetingsList;
    if (!_meetingsController.isAnimating && upcoming.isNotEmpty) {
      setState(() {
        _meetingsCurrentIndex =
            (_meetingsCurrentIndex - 1 + upcoming.length) % upcoming.length;
      });
    }
  }

  void _onMeetingCardTap() {
    final upcoming = ref.read(homeNotifierProvider).upcomingMeetingsList;
    if (!_meetingsController.isAnimating && upcoming.isNotEmpty) {
      _meetingsController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final notifier = ref.read(homeNotifierProvider.notifier);

    // Reset carousel index when list shrinks.
    if (_currentIndex >= homeState.filteredUpcomingShootsList.length &&
        homeState.filteredUpcomingShootsList.isNotEmpty) {
      _currentIndex = 0;
    }

    // Reset meetings carousel index when list shrinks.
    if (_meetingsCurrentIndex >= homeState.upcomingMeetingsList.length &&
        homeState.upcomingMeetingsList.isNotEmpty) {
      _meetingsCurrentIndex = 0;
    }

    final data = homeState.pendingRequestCards.isNotEmpty
        ? homeState.pendingRequestCards.first
        : null;

    return Stack(
      children: [
        Column(
          children: [
            HomeWelcomeHeader(
              firstName: homeState.profileData?.firstName,
              profileImageUrl: homeState.profileData?.profileImageUrl ?? "",
              onAvatarTap: () {
                context.pushNamed(Routes.myProfile.name).then((value) {
                  if (value == true) {
                    notifier.refreshAfterProfileReturn();
                  }
                });
              },
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surfaceMid,
                onRefresh: () => notifier.refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HomeDashboardSummary(
                          completedShoots: homeState.completedShoots,
                          upcomingShoots: homeState.upcomingShoots,
                          pendingRequests: homeState.pendingRequests,
                          selectedIndex: homeState.selectedDashboardIndex,
                          onSelect: notifier.selectDashboardCard,
                        ),
                        const SizedBox(height: 24),
                        const HomeSectionDivider(centerAlpha: 0.24),

                        if (homeState.upcomingShootsList.isNotEmpty) ...[
                          const SizedBox(height: 18), // 18 + 6 (header padding) = 24 visual gap below divider
                          HomeUpcomingCarousel(
                            upcomingShoots: homeState.upcomingShootsList,
                            hasOriginalShoots: homeState.upcomingShootsList.isNotEmpty,
                            currentIndex: _currentIndex,
                            controller: _controller,
                            onCardTap: _onCardTap,
                            onSwipeNext: _goToNext,
                            onSwipePrevious: _goToPrevious,
                          ),
                          const SizedBox(height: 24), // 24 visual gap above divider
                          const HomeSectionDivider(centerAlpha: 0.24),
                        ],

                        if (homeState.upcomingMeetingsList.isNotEmpty) ...[
                          const SizedBox(height: 18), // 18 + 6 (header padding) = 24 visual gap below divider
                          HomeUpcomingMeetingsCarousel(
                            upcomingMeetings: homeState.upcomingMeetingsList,
                            currentIndex: _meetingsCurrentIndex,
                            controller: _meetingsController,
                            onCardTap: _onMeetingCardTap,
                            onSwipeNext: _goToNextMeeting,
                            onSwipePrevious: _goToPreviousMeeting,
                          ),
                          // meetings stack has 25px bottom centering padding, so we don't need additional SizedBox!
                          const HomeSectionDivider(centerAlpha: 0.24),
                        ],

                        const SizedBox(height: 24), // 24 visual gap below divider
                        HomeAvailabilitySection(
                          focusedDay: homeState.focusedDay,
                          selectedEvent: homeState.selectedEvent,
                          eventList: const ['All Events', 'Available', 'Shoot'],
                          events: homeState.events,
                          onAddPressed: () {
                            notifier.onPageChanged(homeState.focusedDay);
                          },
                          onPrevMonth: () => notifier.changeMonth(-1),
                          onNextMonth: () => notifier.changeMonth(1),
                          onSelectedEventChanged: notifier.selectEvent,
                          onPageChanged: notifier.onPageChanged,
                          onDaySelected: (day, event) {
                            if (event != 'Shoot') return;
                            int? bookingId = homeState
                                .availabilityDays[day]
                                ?.bookingId;
                            if (bookingId == null) {
                              for (final s in homeState.upcomingShootsList) {
                                if (s.eventDate.year == day.year &&
                                    s.eventDate.month == day.month &&
                                    s.eventDate.day == day.day) {
                                  bookingId = s.projectId;
                                  break;
                                }
                              }
                            }
                            if (bookingId != null) {
                              context.pushNamed(
                                Routes.upcomingShootDetails.name,
                                extra: UpcomingShootDetailsArgs(
                                  projectId: bookingId,
                                ).toExtra(),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 24), // 24 visual gap above divider
                        const HomeSectionDivider(centerAlpha: 0.24),

                        if (homeState.pendingRequestCards.isNotEmpty) ...[
                          const SizedBox(height: 24), // 24 visual gap below divider
                          HomePendingShootCard(
                            pendingShoot: data,
                            onAccept: (projectId) async {
                              final success =
                                  await notifier.acceptDecline(projectId, 1);
                              if (!context.mounted) return;
                              if (success) {
                                TopMessage.show(
                                  context,
                                  'Shoot accepted successfully',
                                  type: TopMessageType.success,
                                );
                              } else {
                                final err =
                                    ref.read(homeNotifierProvider).errorMessage;
                                TopMessage.show(
                                  context,
                                  err ?? 'Failed to accept shoot',
                                  type: TopMessageType.error,
                                );
                              }
                            },
                            onRejectComplete: () {
                              TopMessage.show(
                                context,
                                'Shoot declined successfully',
                                type: TopMessageType.success,
                              );
                              notifier.refresh();
                            },
                          ),
                          const SizedBox(height: 24), // 24 visual gap above divider
                          const HomeSectionDivider(centerAlpha: 0.24),
                        ],

                        const SizedBox(height: 24), // 24 visual gap below divider
                        HomeShootStatusPanel(
                          successfulShoots: homeState.successfulShoots,
                          pendingShoots: homeState.pendingShootsCount,
                          rejectedShoots: homeState.rejectedShoots,
                          shootRequests: homeState.shootRequests,
                          selectedRange: homeState.selectedRange,
                          rangeOptions: const ['Week', 'Month', 'Year'],
                          onRangeChanged: notifier.changeStatsRange,
                        ),
                        const SizedBox(height: 24), // 24 visual gap above divider
                        const HomeSectionDivider(centerAlpha: 0.24),

                        const SizedBox(height: 24), // 24 visual gap below divider
                        HomeShootCategoriesPanel(
                          selectedTab: homeState.selectedTab,
                          categoryPhotoTotal: homeState.categoryPhotoTotal,
                          categoryVideoTotal: homeState.categoryVideoTotal,
                          acceptPhotographyShoots: homeState.acceptPhotographyShoots,
                          acceptVideographyShoots: homeState.acceptVideographyShoots,
                          rejectedPhoto: homeState.rejectedPhoto,
                          rejectedVideo: homeState.rejectedVideo,
                          requestPhoto: homeState.requestPhoto,
                          requestVideo: homeState.requestVideo,
                          onTabChanged: notifier.changeShootCategoryTab,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (homeState.isLoading || homeState.actionInFlightProjectId != 0)
          const AppLoadingOverlay(),
      ],
    );
  }
}
