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
import '../../../../shared/widgets/common_calendar.dart';
import '../../domain/entities/availability_entry.dart';
import '../providers/availability_providers.dart';

class ManageAvailabilityScreen extends ConsumerWidget {
  const ManageAvailabilityScreen({super.key});

  static const _filters = ['All Events', 'Available', 'Shoot'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manageAvailabilityNotifierProvider);
    final notifier = ref.read(manageAvailabilityNotifierProvider.notifier);
    final calendarEvents = _toCalendarMap(state.events);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.mld,
              ),
              child: Row(
                children: [
                  Builder(
                    builder: (ctx) => InkWell(
                      onTap: () => Scaffold.of(ctx).openDrawer(),
                      child: SvgPicture.asset(AppAssets.menu, width: 26),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Manage Availability',
                    style: AppTextStyles.displayLabel16,
                  ),
                  const Spacer(),
                ],
              ),
            ),
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
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surfaceMid,
                borderRadius: AppRadii.xxxlAll,
                border: Border.all(width: 0.6, color: AppColors.darkCharcoal),
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
                                          .copyWith(color: AppColors.white),
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
                          margin: const EdgeInsets.only(right: AppSpacing.sm),
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
                              style: AppTextStyles.bodySmallMedium.copyWith(
                                color: AppColors.black,
                              ),
                              items: _filters
                                  .map((v) => DropdownMenuItem(
                                        value: v,
                                        child: Text(v),
                                      ))
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
            AppSpacing.verticalXl,
            const SizedBox(height: 14),
            Padding(
              padding: AppSpacing.cardInsets,
              child: InkWell(
                borderRadius: AppRadii.hugeAll,
                onTap: () async {
                  final result = await context.pushNamed(
                    Routes.addAvailability.name,
                  );
                  if (result == true) {
                    notifier.refresh();
                  }
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadii.lgAll,
                  ),
                  child: Center(
                    child: Text(
                      'Add Availability',
                      style: AppTextStyles.displayLabel16.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.circleGradientTop,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<DateTime, String> _toCalendarMap(
    Map<DateTime, AvailabilityStatus> events,
  ) {
    return {
      for (final entry in events.entries)
        entry.key: switch (entry.value) {
          AvailabilityStatus.shoot => 'Shoot',
          AvailabilityStatus.available => 'Available',
          AvailabilityStatus.none => 'None',
        }
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
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.white70),
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
