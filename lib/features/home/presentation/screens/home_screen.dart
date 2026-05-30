import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/route_names.dart';
import '../../../../app/spacing.dart';
import '../providers/home_notifier.dart';
import '../widgets/home_availability_section.dart';
import '../widgets/home_dashboard_summary.dart';
import '../widgets/home_pending_shoot_card.dart';
import '../widgets/home_shoot_categories_panel.dart';
import '../widgets/home_shoot_status_panel.dart';
import '../widgets/home_upcoming_carousel.dart';
import '../widgets/home_welcome_header.dart';

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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final upcoming =
            ref.read(homeNotifierProvider).upcomingShootsList;
        if (upcoming.isNotEmpty) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % upcoming.length;
          });
          _controller.reset();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToNext() {
    final upcoming = ref.read(homeNotifierProvider).upcomingShootsList;
    if (!_controller.isAnimating && upcoming.isNotEmpty) {
      _controller.forward();
    }
  }

  void _goToPrevious() {
    final upcoming = ref.read(homeNotifierProvider).upcomingShootsList;
    if (!_controller.isAnimating && upcoming.isNotEmpty) {
      setState(() {
        _currentIndex =
            (_currentIndex - 1 + upcoming.length) % upcoming.length;
      });
    }
  }

  void _onCardTap() {
    final upcoming = ref.read(homeNotifierProvider).upcomingShootsList;
    if (!_controller.isAnimating && upcoming.isNotEmpty) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final notifier = ref.read(homeNotifierProvider.notifier);

    // Reset carousel index when list shrinks.
    if (_currentIndex >= homeState.upcomingShootsList.length &&
        homeState.upcomingShootsList.isNotEmpty) {
      _currentIndex = 0;
    }

    final data = homeState.pendingRequestCards.isNotEmpty
        ? homeState.pendingRequestCards.first
        : null;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceMid,
      onRefresh: () => notifier.refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          children: [
            HomeWelcomeHeader(
              firstName: homeState.profileData?.firstName,
              profileImageUrl:
                  homeState.profileData?.profileImageUrl ?? "",
              onAvatarTap: () {
                context.pushNamed(RouteNames.myProfile).then((value) {
                  if (value == true) {
                    notifier.refreshAfterProfileReturn();
                  }
                });
              },
            ),
            Padding(
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
                  AppSpacing.verticalMld,
                  Divider(color: AppColors.dividerDark),
                  AppSpacing.verticalMld,
                  if (homeState.upcomingShootsList.isNotEmpty)
                    HomeUpcomingCarousel(
                      upcomingShoots: homeState.upcomingShootsList,
                      currentIndex: _currentIndex,
                      controller: _controller,
                      onCardTap: _onCardTap,
                      onSwipeNext: _goToNext,
                      onSwipePrevious: _goToPrevious,
                    ),
                  AppSpacing.verticalMld,
                  HomeAvailabilitySection(
                    focusedDay: homeState.focusedDay,
                    selectedEvent: homeState.selectedEvent,
                    eventList: const [
                      'All Events',
                      'Available',
                      'Shoot',
                    ],
                    events: homeState.events,
                    onAddPressed: () {
                      notifier.onPageChanged(homeState.focusedDay);
                    },
                    onPrevMonth: () => notifier.changeMonth(-1),
                    onNextMonth: () => notifier.changeMonth(1),
                    onSelectedEventChanged: notifier.selectEvent,
                    onPageChanged: notifier.onPageChanged,
                  ),
                  AppSpacing.verticalMd,
                  Divider(
                    color: AppColors.dividerDark,
                    thickness: 0.8,
                  ),
                  AppSpacing.verticalMd,
                  if (homeState.pendingRequestCards.isNotEmpty) ...[
                    HomePendingShootCard(
                      pendingShoot: data,
                      onAccept: (projectId) {
                        notifier.acceptDecline(projectId, 1);
                      },
                      onRejectComplete: () {
                        notifier.refresh();
                      },
                    ),
                    AppSpacing.verticalMd,
                    Divider(
                      color: AppColors.dividerDark,
                      thickness: 0.8,
                    ),
                  ],
                  AppSpacing.verticalMd,
                  AppSpacing.verticalMld,
                  HomeShootStatusPanel(
                    successfulShoots: homeState.successfulShoots,
                    pendingShoots: homeState.pendingShootsCount,
                    rejectedShoots: homeState.rejectedShoots,
                    shootRequests: homeState.shootRequests,
                    selectedRange: homeState.selectedRange,
                    rangeOptions: const ['Week', 'Month', 'Year'],
                    onRangeChanged: notifier.changeStatsRange,
                  ),
                  AppSpacing.verticalBase,
                  Divider(
                    color: AppColors.dividerDark,
                    thickness: 0.8,
                  ),
                  AppSpacing.verticalBase,
                  HomeShootCategoriesPanel(
                    selectedTab: homeState.selectedTab,
                    categoryPhotoTotal: homeState.categoryPhotoTotal,
                    categoryVideoTotal: homeState.categoryVideoTotal,
                    acceptPhotographyShoots:
                        homeState.acceptPhotographyShoots,
                    acceptVideographyShoots:
                        homeState.acceptVideographyShoots,
                    rejectedPhoto: homeState.rejectedPhoto,
                    rejectedVideo: homeState.rejectedVideo,
                    requestPhoto: homeState.requestPhoto,
                    requestVideo: homeState.requestVideo,
                    onTabChanged: notifier.changeShootCategoryTab,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
