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
import '../../../shoots/presentation/screens/shoot_cancelled_screen.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../model_class/cp_profile_model.dart';
import '../../../../model_class/create_dashboard_details_model.dart';
import '../../../../config/env.dart';
import '../../../../utility/date_time_utils.dart';

/// Pending shoot showcase card (image, project name, view-details link,
/// date / time / location row, accept + reject CTAs).
///
/// Renders nothing when [pendingShoot] is null; behavior preserved verbatim
/// from `home_screen.dart`'s `if (creatordashboarddetaillist.isNotEmpty)`
/// branch (uses `.first`).
class HomePendingShootCard extends ConsumerWidget {
  final PendingRequestCard? pendingShoot;
  final void Function(int projectId) onAccept;
  final VoidCallback onRejectComplete;

  const HomePendingShootCard({
    super.key,
    required this.pendingShoot,
    required this.onAccept,
    required this.onRejectComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = pendingShoot;
    if (data == null) {
      return const SizedBox.shrink();
    }
    final statusLower = data.status.toLowerCase();
    final isCompleted = statusLower == 'completed';
    final isConfirmed = statusLower == 'confirmed' ||
        statusLower == 'accepted' ||
        data.crewAccept == 1;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Pending Request",
              style: AppTextStyles.displayLabel16.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceMid,
            borderRadius: AppRadii.portfolioCompactAll,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: AppRadii.topPortfolioCompact,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: data.shootTypeImageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: Env.imageUrl + data.shootTypeImageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) {
                                return SvgPicture.asset(
                                  AppAssets.imageHolder,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : SvgPicture.asset(
                              AppAssets.imageHolder,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: AppRadii.topPortfolioCompact,
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [AppColors.surfaceMid, AppColors.transparent],
                        ),
                      ),
                    ),
                  ),
                  if (data.requestTimeAgo.isNotEmpty)
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x33FFFFFF), // #FFFFFF33 (20% opacity white)
                          borderRadius: AppRadii.pillAll,
                        ),
                        child: Text(
                          data.requestTimeAgo,
                          style: AppTextStyles.body10.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
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
                        if (data.shootType.isNotEmpty) ...[
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
                              data.shootType,
                              style: AppTextStyles.body11.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data.projectName,
                            style: AppTextStyles.body15Medium.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        AppSpacing.gapHSm,
                        GestureDetector(
                          onTap: () {
                            if (ref.read(guestModeProvider)) {
                              showLoginDialog(context);
                              return;
                            }
                            context.pushNamed(
                              Routes.upcomingShootDetails.name,
                              extra: UpcomingShootDetailsArgs(
                                projectId: data.projectId,
                              ).toExtra(),
                            );
                          },
                          child: Text(
                            "View Details",
                            style: AppTextStyles.bodySmallStrong.copyWith(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(color: AppColors.dividerDark, thickness: 0.8),
                    AppSpacing.verticalMd,
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppAssets.calendar,
                          width: 14,
                          height: 14,
                        ),
                        AppSpacing.gapHXs,
                        Text(
                          DateTimeUtils.formatReadableDate(
                            data.eventDate.toIso8601String(),
                          ),
                          style: AppTextStyles.body10.copyWith(
                            color: AppColors.white70,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.mld),
                        SvgPicture.asset(
                          AppAssets.time,
                          width: 14,
                          height: 14,
                        ),
                        AppSpacing.gapHXs,
                        Text(
                          "${DateTimeUtils.formatTime(data.startTime)} - ${DateTimeUtils.formatTime(data.endTime)}",
                          style: AppTextStyles.body10.copyWith(
                            color: AppColors.white70,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.mld),
                        SvgPicture.asset(
                          AppAssets.location,
                          width: 14,
                          height: 14,
                        ),
                        AppSpacing.gapHXs,
                        Expanded(
                          child: Text(
                            data.eventLocation,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body10.copyWith(
                              color: AppColors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalLg,
                    Builder(
                      builder: (context) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            data.cpProfiles.isNotEmpty
                                ? _buildMembersStack(data.cpProfiles)
                                : const SizedBox(),
                            if (data.canTakeAction == true)
                              Row(
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.shootAcceptButtonBackground,
                                      foregroundColor:
                                          AppColors.shootAcceptButtonText,
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
                                    onPressed: () {
                                      onAccept(data.projectId);
                                    },
                                    child: Text(
                                      data.cta?.primary.isNotEmpty == true
                                          ? data.cta!.primary
                                          : "Accept",
                                      style: AppTextStyles.bodySmallStrong.copyWith(
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
                                      foregroundColor:
                                          AppColors.shootDeclineButtonText,
                                      disabledBackgroundColor:
                                          AppColors.shootDeclineButtonBackground,
                                      disabledForegroundColor:
                                          AppColors.shootDeclineButtonText,
                                      elevation: 0,
                                      shape: const StadiumBorder(),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 8,
                                      ),
                                    ),
                                    onPressed: () {
                                      showDeclineShootBottomSheet(
                                        context,
                                        projectId: data.projectId,
                                      ).then((value) {
                                        if (value == true) {
                                          onRejectComplete();
                                        }
                                      });
                                    },
                                    child: Text(
                                      (data.cta?.secondary.isNotEmpty == true &&
                                              data.cta!.secondary.toLowerCase() != 'reject')
                                          ? data.cta!.secondary
                                          : "Decline",
                                      style: AppTextStyles.bodySmallStrong.copyWith(
                                        color: AppColors.shootDeclineButtonText,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMembersStack(List<CpProfile> profiles) {
    final displayProfiles = profiles.take(3).toList();
    final remaining = profiles.length - displayProfiles.length;
    const avatarSize = 26.0;

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
                          errorWidget: (context, url, error) => _buildAvatarFallback(displayProfiles[i].name),
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
