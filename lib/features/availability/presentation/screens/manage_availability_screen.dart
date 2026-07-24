import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../utility/date_time_utils.dart';
import '../../../../shared/widgets/app_cta_button.dart';
import '../../../../shared/widgets/app_main_toolbar.dart';
import '../../../../shared/widgets/common_calendar.dart';
import '../../../home/presentation/widgets/home_upcoming_carousel.dart';
import '../../../../shared/widgets/loading.dart';
import '../../../shoots/presentation/routes/shoots_args.dart';
import '../../domain/entities/availability_entry.dart';
import '../providers/availability_providers.dart';

class ManageAvailabilityScreen extends ConsumerStatefulWidget {
  const ManageAvailabilityScreen({super.key});

  static const _filters = ['All Events', 'Available', 'Shoot'];

  @override
  ConsumerState<ManageAvailabilityScreen> createState() =>
      _ManageAvailabilityScreenState();
}

class _ManageAvailabilityScreenState
    extends ConsumerState<ManageAvailabilityScreen>
    with TickerProviderStateMixin {
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
            ref.read(manageAvailabilityNotifierProvider).upcomingShootsList;
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
    final upcoming =
        ref.read(manageAvailabilityNotifierProvider).upcomingShootsList;
    if (!_controller.isAnimating && upcoming.isNotEmpty) {
      _controller.forward();
    }
  }

  void _goToPrevious() {
    final upcoming =
        ref.read(manageAvailabilityNotifierProvider).upcomingShootsList;
    if (!_controller.isAnimating && upcoming.isNotEmpty) {
      setState(() {
        _currentIndex =
            (_currentIndex - 1 + upcoming.length) % upcoming.length;
      });
    }
  }

  void _onCardTap() {
    final upcoming =
        ref.read(manageAvailabilityNotifierProvider).upcomingShootsList;
    if (!_controller.isAnimating && upcoming.isNotEmpty) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(manageAvailabilityNotifierProvider);
    final notifier = ref.read(manageAvailabilityNotifierProvider.notifier);
    final calendarEvents = _toCalendarMap(state.events);

    if (_currentIndex >= state.upcomingShootsList.length &&
        state.upcomingShootsList.isNotEmpty) {
      _currentIndex = 0;
    }

    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              const AppMainToolbar(title: 'Manage Availability'),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AppSpacing.verticalSm,
                      Container(
                        margin: AppSpacing.insetsHBase,
                        padding: const EdgeInsets.all(AppSpacing.smd),
                        decoration: BoxDecoration(
                          color: AppColors.blueWash,
                          borderRadius: AppRadii.lgAll,
                          border: Border.all(width: 0.5),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(AppAssets.info),
                            AppSpacing.gapHSm,
                            Expanded(
                              child: Text(
                                'Your availability is automatically blocked for confirmed shoots',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.blueAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.verticalXl,
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMid,
                          borderRadius: AppRadii.xxxlAll,
                          border: Border.all(
                            width: 0.6,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: AppRadii.xxxlAll,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.chevron_left,
                                            color: AppColors.white,
                                            size: 24,
                                          ),
                                          onPressed: () => notifier.shiftMonth(-1),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                DateTimeUtils.formatFullMonthYear(
                                                  state.focusedDay,
                                                ),
                                                style: AppTextStyles.bodyLargeMedium
                                                    .copyWith(
                                                      color: AppColors.white,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.chevron_right,
                                            color: AppColors.white,
                                            size: 24,
                                          ),
                                          onPressed: () => notifier.shiftMonth(1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                      right: AppSpacing.sm,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: 7.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: AppRadii.lgAll,
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: state.eventFilter,
                                        isDense: true,
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: AppColors.black,
                                          size: 18,
                                        ),
                                        dropdownColor: AppColors.white,
                                        style: AppTextStyles.bodySmallMedium
                                            .copyWith(color: AppColors.black),
                                        items: ManageAvailabilityScreen._filters
                                            .map(
                                              (v) => DropdownMenuItem(
                                                value: v,
                                                child: Text(v),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (v) {
                                          if (v != null) notifier.setFilter(v);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.verticalSmd,
                              CommonCalendar(
                                focusedDay: state.focusedDay,
                                events: calendarEvents,
                                selectedEvent: state.eventFilter,
                                onPageChanged: notifier.setFocusedDay,
                                onDaySelected: (day, event) {
                                  if (event != 'Shoot') return;
                                  final bookingId = state.events[day]?.bookingId;
                                  if (bookingId == null) return;
                                  context.pushNamed(
                                    Routes.upcomingShootDetails.name,
                                    extra: UpcomingShootDetailsArgs(
                                      projectId: bookingId,
                                    ).toExtra(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      AppSpacing.verticalXl,
                      Container(
                        margin: AppSpacing.insetsHBase,
                        padding: AppSpacing.cardInsets,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSlate,
                          borderRadius: AppRadii.hugeAll,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'This Month',
                              style: AppTextStyles.headingOutfitLg.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            AppSpacing.verticalBase,
                            _StatCard(
                              svgIcon: AppAssets.calendar,
                              title: 'Available Days',
                              value: '${state.availableDaysCount}',
                            ),
                            AppSpacing.verticalMd,
                            _StatCard(
                              svgIcon: AppAssets.bookVideo,
                              title: 'Book shoots',
                              value: '${state.shootDaysCount}',
                            ),
                            AppSpacing.verticalMd,
                            const _StatCard(
                              svgIcon: AppAssets.hourglassTime,
                              title: 'Time Off',
                              value: '0',
                            ),
                          ],
                        ),
                      ),

                      if (state.upcomingShootsList.isNotEmpty) ...[
                        AppSpacing.verticalXl,
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: HomeUpcomingCarousel(
                            upcomingShoots: state.upcomingShootsList,
                            hasOriginalShoots: state.upcomingShootsList.isNotEmpty,
                            currentIndex: _currentIndex,
                            controller: _controller,
                            onCardTap: _onCardTap,
                            onSwipeNext: _goToNext,
                            onSwipePrevious: _goToPrevious,
                          ),
                        ),
                      ],

                      AppSpacing.verticalXl,
                      Padding(
                        padding: AppSpacing.cardInsets,
                        child: AppCtaButton(
                          label: 'Add Availability',
                          height: 56,
                          onPressed: () async {
                            final result = await context.pushNamed(
                              Routes.addAvailability.name,
                            );
                            if (result == true) {
                              notifier.refresh();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (state.isLoading) const AppLoadingOverlay(),
      ],
    );
  }

  Map<DateTime, String> _toCalendarMap(Map<DateTime, AvailabilityDay> events) {
    return {
      for (final entry in events.entries)
        entry.key: switch (entry.value.status) {
          AvailabilityStatus.shoot => 'Shoot',
          AvailabilityStatus.available => 'Available',
          AvailabilityStatus.none => 'None',
        },
    };
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String svgIcon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.svgIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.mld,
        vertical: AppSpacing.mld,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceAsh,
        borderRadius: AppRadii.xxlAll,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.smd),
            decoration: BoxDecoration(
              color: AppColors.surfaceFog,
              borderRadius: AppRadii.lgAll,
            ),
            child: SvgPicture.asset(
              svgIcon,
              height: 20,
              width: 20,
              // ignore: deprecated_member_use
              color: AppColors.white70,
            ),
          ),
          const SizedBox(width: AppSpacing.mld),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white70,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyLargeStrong.copyWith(
              color: AppColors.goldSand,
            ),
          ),
        ],
      ),
    );
  }
}
