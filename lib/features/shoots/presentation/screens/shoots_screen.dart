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
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_main_toolbar.dart';
import '../../../../shared/widgets/app_count_card.dart';
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
              const AppMainToolbar(title: 'shoots'),

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
                      iconPath: AppAssets.clockIcon,
                    ),
                    AppCountCard(
                      number: '${state.counts?.confirmedRequests ?? 0}',
                      title: 'Confirmed Shoots',
                      iconPath: AppAssets.videoIcon,
                    ),
                    AppCountCard(
                      number: '${state.counts?.completedShoots ?? 0}',
                      title: 'Completed Shoots',
                      iconPath: AppAssets.photoIcon,
                    ),
                    AppCountCard(
                      number: '${state.counts?.rejectedRequests ?? 0}',
                      title: 'Declined',
                      iconPath: AppAssets.declinedIcon,
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
                                  title: 'No shoots found',
                                  description:
                                      'No shoots matched "${state.searchQuery.trim()}". Try searching with a different keyword.',
                                )
                              : const AppEmptyState(
                                  icon: Icons.event_busy_rounded,
                                  iconSize: 56,
                                  title: 'No shoots available',
                                  description:
                                      'You don\'t have any shoots assigned at the moment.',
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
                            onAccept: () => notifier.acceptShoot(shoot.projectId),
                            onDecline: () => context
                                .pushNamed(
                                  Routes.cancelShoot.name,
                                  extra: CancelShootArgs(
                                    projectId: shoot.projectId,
                                  ).toExtra(),
                                )
                                .then((_) => notifier.refresh()),
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

    final isActionable = DateTimeUtils.isActionableBeforeOneHour(
      eventDate: shoot.eventDate,
      startTime: shoot.startTime,
      status: shoot.status,
      crewAccept: shoot.crewAccept,
    );

    final isConfirmed = shoot.status.toLowerCase() == 'confirmed' ||
        shoot.status.toLowerCase() == 'accepted' ||
        shoot.crewAccept == 1;

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
                        color: isConfirmed
                            ? AppColors.shootAcceptButtonBackground
                            : AppColors.lightGoldenBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isConfirmed
                                ? Icons.check_circle
                                : Icons.schedule,
                            size: 14,
                            color: isConfirmed
                                ? AppColors.shootAcceptButtonText
                                : AppColors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isConfirmed ? 'Confirmed' : 'Pending',
                            style: AppTextStyles.body11.copyWith(
                              color: isConfirmed
                                  ? AppColors.shootAcceptButtonText
                                  : AppColors.amber,
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
                    if (isActionable)
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
