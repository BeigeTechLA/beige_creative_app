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
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../model_class/cp_profile_model.dart';
import '../../../../model_class/shoots_model.dart';
import '../../../../config/env.dart';
import '../../../../utility/date_time_utils.dart';
import '../../../../shared/widgets/loading.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_main_toolbar.dart';
import '../../../../shared/widgets/app_count_card.dart';
import '../../../../shared/widgets/app_segmented_control.dart';
import '../providers/shoots_providers.dart';
import '../widgets/shoots_filter_bottom_sheet.dart';
import 'shoot_cancelled_screen.dart';

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
              AppMainToolbar(
                title: 'Shoots',
                trailing: IconButton(
                  tooltip: 'Filter shoots',
                  onPressed: () => ShootsFilterBottomSheet.show(
                    context,
                    currentStatus: state.selectedStatusFilter,
                    onApply: notifier.setStatusFilter,
                  ),
                  icon: SvgPicture.asset(
                    AppAssets.iconFilter,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),

              /// COUNT CARDS
              SizedBox(
                height: 76,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.mld,
                  ),
                  children: [
                    AppCountCard(
                      number: '${state.counts?.pendingRequests ?? 0}',
                      title: 'Pending Shoots',
                      iconPath: state.selectedTopCard == 'Pending Shoots'
                          ? AppAssets.clockIconSel
                          : AppAssets.clockIcon,
                      variant: state.selectedTopCard == 'Pending Shoots'
                          ? AppCountCardVariant.goldAccent
                          : AppCountCardVariant.classic,
                      onTap: () => notifier.selectTopCard('Pending Shoots'),
                    ),
                    AppCountCard(
                      number: '${state.counts?.confirmedRequests ?? 0}',
                      title: 'Confirmed Shoots',
                      iconPath: state.selectedTopCard == 'Confirmed Shoots'
                          ? AppAssets.photoIconSel
                          : AppAssets.photoIcon,

                      variant: state.selectedTopCard == 'Confirmed Shoots'
                          ? AppCountCardVariant.goldAccent
                          : AppCountCardVariant.classic,
                      onTap: () => notifier.selectTopCard('Confirmed Shoots'),
                    ),
                    AppCountCard(
                      number: '${state.counts?.completedShoots ?? 0}',
                      title: 'Completed Shoots',
                      iconPath: state.selectedTopCard == 'Completed Shoots'
                          ? AppAssets.videoIconSel
                          : AppAssets.videoIcon,
                      variant: state.selectedTopCard == 'Completed Shoots'
                          ? AppCountCardVariant.goldAccent
                          : AppCountCardVariant.classic,
                      onTap: () => notifier.selectTopCard('Completed Shoots'),
                    ),
                    AppCountCard(
                      number: '${state.counts?.rejectedRequests ?? 0}',
                      title: 'Declined',
                      iconPath: state.selectedTopCard == 'Declined'
                          ? AppAssets.declinedIconSel
                          : AppAssets.declinedIcon,
                      variant: state.selectedTopCard == 'Declined'
                          ? AppCountCardVariant.goldAccent
                          : AppCountCardVariant.classic,
                      onTap: () => notifier.selectTopCard('Declined'),
                    ),
                  ],
                ),
              ),

              /// REQUEST / SHOOTS SEGMENTED TAB CONTROL (hidden when a top card is selected)
              if (state.selectedTopCard == null) ...[
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: AppSpacing.insetsHBase,
                  child: AppSegmentedControl(
                    items: const ['Request', 'Shoots'],
                    selectedIndex: state.selectedTabIndex,
                    onValueChanged: notifier.selectTab,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.md),

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
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white50,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(AppSpacing.inlineNudge),
                        child: SvgPicture.asset(
                          AppAssets.searchIcon,
                          width: 14,
                          height: 14,
                          fit: BoxFit.contain,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.mld,
                      ),
                    ),
                  ),
                ),
              ),

              /// REMOVABLE WHITE CHIP (shows when top rectangle card is selected)
              if (state.selectedTopCard != null) ...[
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: AppSpacing.insetsHBase,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs + 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppRadii.smAll,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.selectedTopCard!,
                            style: AppTextStyles.bodyCompactMedium.copyWith(
                              color: const Color(0xFF1D1D1B),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          GestureDetector(
                            onTap: notifier.clearTopCardSelection,
                            child: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Color(0xFF1D1D1B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xl),

              /// LIST
              Expanded(
                child: state.visibleShoots.isEmpty && !state.isLoading
                    ? Center(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: state.searchQuery.trim().isNotEmpty
                              ? AppEmptyState(
                                  icon: Icons.search_off_rounded,
                                  iconSize: 56,
                                  title: 'No Shoots found',
                                  description:
                                      'No Shoots matched "${state.searchQuery.trim()}". Try searching with a different keyword.',
                                )
                              : const AppEmptyState(
                                  imageAsset: AppAssets.noData,
                                  iconSize: 150,
                                  title: 'No Shoot Available',
                                  description:
                                      'No shoots available at the moment.\nNew opportunities will appear here when assigned.',
                                ),
                        ),
                      )
                    : ListView.builder(
                        padding: AppSpacing.insetsHBase,
                        itemCount: state.visibleShoots.length,
                        itemBuilder: (context, index) {
                          final shoot = state.visibleShoots[index];
                          final inFlight =
                              state.actionInFlightProjectId == shoot.projectId;
                          return _ShootCard(
                            shoot: shoot,
                            isAcceptInFlight: inFlight,
                            onAccept: () async {
                              final success =
                                  await notifier.acceptShoot(shoot.projectId);
                              if (!context.mounted) return;
                              if (success) {
                                TopMessage.show(
                                  context,
                                  'Shoot accepted successfully',
                                  type: TopMessageType.success,
                                );
                              } else {
                                final err =
                                    ref.read(shootsListProvider).errorMessage;
                                TopMessage.show(
                                  context,
                                  err ?? 'Failed to accept shoot',
                                  type: TopMessageType.error,
                                );
                              }
                            },
                            onDecline: () => showDeclineShootBottomSheet(
                                  context,
                                  projectId: shoot.projectId,
                                ).then((value) {
                                  if (!context.mounted) return;
                                  if (value == true) {
                                    TopMessage.show(
                                      context,
                                      'Shoot declined successfully',
                                      type: TopMessageType.success,
                                    );
                                  }
                                  notifier.refresh();
                                }),
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
          if (state.actionInFlightProjectId != 0) const AppLoadingOverlay(),
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
    final formattedDate =
        DateTimeUtils.formatReadableDate(shoot.eventDate.toIso8601String());
    final formattedTime =
        '${DateTimeUtils.formatTime(shoot.startTime)} - ${DateTimeUtils.formatTime(shoot.endTime)}';

    final statusLower = shoot.status.toLowerCase();
    final isCompleted = statusLower == 'completed';
    final isConfirmed = statusLower == 'confirmed' ||
        statusLower == 'accepted' ||
        shoot.crewAccept == 1;

    final Color badgeBg = isCompleted
        ? AppColors.shootStatusCompletedBg
        : (isConfirmed
            ? AppColors.shootStatusConfirmedBg
            : AppColors.shootStatusPendingBg);

    final Color badgeFg = isCompleted
        ? AppColors.shootStatusCompletedFg
        : (isConfirmed
            ? AppColors.shootStatusConfirmedFg
            : AppColors.shootStatusPendingFg);

    final String badgeAsset = isCompleted || isConfirmed
        ? AppAssets.icCheckmark
        : AppAssets.icLoaderPending;

    final String badgeText = isCompleted
        ? 'Completed'
        : (isConfirmed ? 'Confirmed' : 'Pending');

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: AppRadii.hugeAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
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
                            AppAssets.imageHolder,
                            height: 60,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white24,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                ),
              ),
              // Bottom-left status & category pills
              Positioned(
                bottom: 12,
                left: 12,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            badgeAsset,
                            width: 14,
                            height: 14,
                            colorFilter: (isCompleted || isConfirmed)
                                ? ColorFilter.mode(
                                    badgeFg,
                                    BlendMode.srcIn,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            badgeText,
                            style: AppTextStyles.body11.copyWith(
                              color: badgeFg,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWarmLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        shoot.shootType.isNotEmpty
                            ? shoot.shootType
                            : 'Commercial',
                        style: AppTextStyles.body11.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                      'ID: #${shoot.id}',
                      style: AppTextStyles.inherit.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white70,
                      ),
                    ),
                    InkWell(
                      onTap: onViewDetails,
                      child: Text(
                        'View Details',
                        style: AppTextStyles.bodySmallStrong.copyWith(
                          color: AppColors.white,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  shoot.projectName,
                  style: AppTextStyles.body15Strong.copyWith(
                    color: AppColors.white,
                  ),
                ),
                AppSpacing.verticalSm,
                const Divider(color: AppColors.dividerDark),
                Row(
                  children: [
                    SvgPicture.asset(AppAssets.calendar, width: 14, height: 14),
                    AppSpacing.gapHXs,
                    Text(
                      formattedDate,
                      style: AppTextStyles.body10.copyWith(color: AppColors.white70),
                    ),
                    const SizedBox(width: AppSpacing.mld),
                    SvgPicture.asset(AppAssets.time, width: 14, height: 14),
                    AppSpacing.gapHXs,
                    Text(
                      formattedTime,
                      style: AppTextStyles.body10.copyWith(color: AppColors.white70),
                    ),
                    const SizedBox(width: AppSpacing.mld),
                    SvgPicture.asset(AppAssets.location, width: 14, height: 14),
                    AppSpacing.gapHXs,
                    Expanded(
                      child: Text(
                        shoot.eventLocation,
                        style: AppTextStyles.body10.copyWith(color: AppColors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalMd,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Crew avatars stack
                    _buildAvatarGroup(shoot.cpProfiles),
                    if (shoot.canTakeAction)
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.shootAcceptButtonBackground,
                              foregroundColor: AppColors.shootAcceptButtonText,
                              disabledBackgroundColor:
                                  AppColors.shootAcceptButtonBackground,
                              disabledForegroundColor:
                                  AppColors.shootAcceptButtonText,
                              elevation: 0,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                            ),
                            onPressed: isAcceptInFlight ? null : onAccept,
                            child: isAcceptInFlight
                                ? const AppCircularLoader(
                                    size: 16,
                                    strokeWidth: 2,
                                    color: AppColors.shootAcceptButtonText,
                                  )
                                : Text(
                                    'Accept',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.shootAcceptButtonText,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                          AppSpacing.gapHSmd,
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.shootDeclineButtonBackground,
                              foregroundColor: AppColors.shootDeclineButtonText,
                              elevation: 0,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                            ),
                            onPressed: onDecline,
                            child: Text(
                              'Decline',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.shootDeclineButtonText,
                                fontWeight: FontWeight.w700,
                              ),
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

  Widget _buildAvatarGroup(List<CpProfile> profiles) {
    if (profiles.isEmpty) return const SizedBox();

    final displayProfiles = profiles.take(3).toList();
    final remaining = profiles.length - displayProfiles.length;
    const double avatarSize = 26.0;

    return SizedBox(
      height: avatarSize,
      width: displayProfiles.length * 16.0 + (remaining > 0 ? 22.0 : 8.0),
      child: Stack(
        children: [
          for (int i = 0; i < displayProfiles.length; i++)
            Positioned(
              left: i * 15.0,
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
                          errorWidget: (context, url, error) =>
                              _buildAvatarFallback(displayProfiles[i].name),
                        )
                      : _buildAvatarFallback(displayProfiles[i].name),
                ),
              ),
            ),
          if (remaining > 0)
            Positioned(
              left: displayProfiles.length * 15.0,
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(color: AppColors.surfaceMid, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$remaining',
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
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'M';
    return Container(
      color: AppColors.surfaceStats,
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
