import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../routes/shoots_args.dart';
import '../../../../app/shadows.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../model_class/shoots_model.dart';
import '../../../../config/env.dart';
import '../../../../utility/date_time_utils.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../providers/shoots_providers.dart';

class ShootsScreen extends ConsumerStatefulWidget {
  const ShootsScreen({super.key});

  @override
  ConsumerState<ShootsScreen> createState() => _ShootsScreenState();
}

class _ShootsScreenState extends ConsumerState<ShootsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shootsListProvider);
    final notifier = ref.read(shootsListProvider.notifier);

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              /// TOP BAR
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => InkWell(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: SvgPicture.asset(AppAssets.menu, height: 26),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'shoots',
                      style: AppTextStyles.displayLabel16,
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              /// COUNT CARDS
              SizedBox(
                height: 76,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.mld),
                  children: [
                    _CountCard(
                      number: '${state.counts?.pendingRequests ?? 0}',
                      title: 'Pending Shoots',
                      iconPath: AppAssets.clock_icon,
                    ),
                    _CountCard(
                      number: '${state.counts?.confirmedRequests ?? 0}',
                      title: 'Confirmed Shoots',
                      iconPath: AppAssets.video_icon,
                    ),
                    _CountCard(
                      number: '${state.counts?.completedShoots ?? 0}',
                      title: 'Completed Shoots',
                      iconPath: AppAssets.photo_icon,
                    ),
                    _CountCard(
                      number: '${state.counts?.rejectedRequests ?? 0}',
                      title: 'Declined',
                      iconPath: AppAssets.declined_icon,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.cardCompactInset),

              /// SEARCH BAR — debounced through the notifier.
              Padding(
                padding: AppSpacing.insetsHBase,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMid,
                    borderRadius: AppRadii.xlAll,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: notifier.updateSearch,
                    style: AppTextStyles.inherit14,
                    cursorColor: AppColors.white,
                    decoration: InputDecoration(
                      hintText: 'Search events or crew...',
                      hintStyle: AppTextStyles.bodyMedium,
                      prefixIcon: Padding(
                        padding:
                            const EdgeInsets.all(AppSpacing.inlineNudge),
                        child: SvgPicture.asset(
                          AppAssets.search_icon,
                          width: 14,
                          height: 14,
                          fit: BoxFit.contain,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.mld),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              /// LIST
              Expanded(
                child: ListView.builder(
                  padding: AppSpacing.insetsHBase,
                  itemCount: state.visibleShoots.length,
                  itemBuilder: (context, index) {
                    final shoot = state.visibleShoots[index];
                    final inFlight =
                        state.actionInFlightProjectId == shoot.projectId;
                    return _ShootCard(
                      shoot: shoot,
                      isAcceptInFlight: inFlight,
                      onAccept: () => notifier.acceptShoot(shoot.projectId),
                      onDecline: () => context.pushNamed(
                        Routes.cancelShoot.name,
                        extra: CancelShootArgs(projectId: shoot.projectId)
                            .toExtra(),
                      ).then((_) => notifier.refresh()),
                      onViewDetails: () => context.pushNamed(
                        Routes.upcomingShootDetails.name,
                        extra: UpcomingShootDetailsArgs(
                          projectId: shoot.projectId,
                        ).toExtra(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (state.isLoading) const AppLoader(),
        ],
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  final String number;
  final String title;
  final String iconPath;

  const _CountCard({
    required this.number,
    required this.title,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 174,
      height: 74,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.dropdownIconInset,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.shootStatsCardTop,
            AppColors.shootStatsCardBottom,
          ],
        ),
        borderRadius: AppRadii.xlAll,
        border: Border.all(
          color: AppColors.shootStatsCardBorder,
          width: 0.8,
        ),
        boxShadow: AppShadows.cardBlack12,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  number.padLeft(2, '0'),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 0.95,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyCompactMedium.copyWith(
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 4,
            child: Container(
              alignment: Alignment.center,
              child: SvgPicture.asset(
                iconPath,
                width: 25,
                height: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShootCard extends StatelessWidget {
  final Shoot shoot;
  final bool isAcceptInFlight;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onViewDetails;

  const _ShootCard({
    required this.shoot,
    required this.isAcceptInFlight,
    required this.onAccept,
    required this.onDecline,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateTimeUtils.formatDateValue(shoot.eventDate);
    final formattedTime =
        '${DateTimeUtils.formatTime(shoot.startTime)} - ${DateTimeUtils.formatTime(shoot.endTime)}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: AppRadii.hugeAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: AppRadii.topHuge,
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: shoot.shootTypeImageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: Env.imageUrl + shoot.shootTypeImageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.surfaceStats,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        AppAssets.image_holder,
                        height: 60,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white24,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.mld),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ID: ${shoot.id}',
                      style: AppTextStyles.inherit.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      onTap: onViewDetails,
                      child: Text(
                        'View Details',
                        style: AppTextStyles.bodySmallStrong.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  shoot.projectName,
                  style: AppTextStyles.body15Strong,
                ),
                AppSpacing.verticalSm,
                const Divider(color: AppColors.dividerDark),
                Row(
                  children: [
                    SvgPicture.asset(AppAssets.calender, width: 14, height: 14),
                    AppSpacing.gapHXs,
                    Text(formattedDate, style: AppTextStyles.body10),
                    const SizedBox(width: AppSpacing.mld),
                    SvgPicture.asset(AppAssets.time, width: 14, height: 14),
                    AppSpacing.gapHXs,
                    Text(formattedTime, style: AppTextStyles.body10),
                    const SizedBox(width: AppSpacing.mld),
                    SvgPicture.asset(AppAssets.location,
                        width: 14, height: 14),
                    AppSpacing.gapHXs,
                    Expanded(
                      child: Text(
                        shoot.eventLocation,
                        style: AppTextStyles.body10,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalMd,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    if (shoot.status.toLowerCase() == 'pending')
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                            ),
                            onPressed: isAcceptInFlight ? null : onAccept,
                            child: isAcceptInFlight
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.black,
                                    ),
                                  )
                                : const Text(
                                    'Accept',
                                    style: AppTextStyles.bodySmall,
                                  ),
                          ),
                          AppSpacing.gapHSmd,
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                            ),
                            onPressed: onDecline,
                            child: const Text(
                              'Decline',
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        ],
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
}
