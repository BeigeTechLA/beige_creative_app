import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../shoots/presentation/routes/shoots_args.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../model_class/create_dashboard_details_model.dart';
import '../../../../config/env.dart';
import '../../../../utility/date_time_utils.dart';

/// Pending shoot showcase card (image, project name, view-details link,
/// date / time / location row, accept + reject CTAs).
///
/// Renders nothing when [pendingShoot] is null; behavior preserved verbatim
/// from `home_screen.dart`'s `if (creatordashboarddetaillist.isNotEmpty)`
/// branch (uses `.first`).
class HomePendingShootCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final data = pendingShoot;
    if (data == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "shoots",
              style: AppTextStyles.displayLabel16.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
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
                    Wrap(
                      spacing: AppSpacing.mld,
                      runSpacing: AppSpacing.sm,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              AppAssets.calendar,
                              width: 14,
                              height: 14,
                            ),
                            SizedBox(width: 6),
                            Text(
                              DateTimeUtils.formatDateValue(data.eventDate),
                              style: AppTextStyles.body10.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              AppAssets.time,
                              width: 14,
                              height: 14,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "${DateTimeUtils.formatTime(data.startTime)} - ${DateTimeUtils.formatTime(data.endTime)}",
                              style: AppTextStyles.body10.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              AppAssets.location,
                              width: 14,
                              height: 14,
                            ),
                            SizedBox(width: 6),
                            Text(
                              data.eventLocation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body10.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    AppSpacing.verticalLg,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Avatar stack left placeholder kept verbatim (was
                        // commented out in legacy).
                        SizedBox(),
                        if (data.canTakeAction == true)
                          Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.white,
                                ),
                                onPressed: () {
                                  onAccept(data.projectId);
                                },
                                child: Text(
                                  data.cta?.primary.isNotEmpty == true
                                      ? data.cta!.primary
                                      : "Accept",
                                  style: AppTextStyles.bodySmallStrong.copyWith(
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                              AppSpacing.gapHSmd,
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.white,
                                ),
                                onPressed: () async {
                                  context
                                      .pushNamed(
                                        Routes.cancelShoot.name,
                                        extra: CancelShootArgs(
                                          projectId: data.projectId,
                                        ).toExtra(),
                                      )
                                      .then((value) {
                                        if (value == true) {
                                          onRejectComplete();
                                        }
                                      });
                                },
                                child: Text(
                                  data.cta?.secondary.isNotEmpty == true
                                      ? data.cta!.secondary
                                      : "Reject",
                                  style: AppTextStyles.bodySmallStrong.copyWith(
                                    color: AppColors.error,
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
        ),
      ],
    );
  }
}
