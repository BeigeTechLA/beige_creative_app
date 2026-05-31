import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../service/api_service.dart';
import '../../../../utility/date_time_utils.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/top_message.dart';
import '../providers/upcoming_shoot_providers.dart';

class UpcomingShootViewDetails extends ConsumerWidget {
  final int? projectid;
  const UpcomingShootViewDetails({super.key, this.projectid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = projectid ?? 0;
    final provider = upcomingShootDetailProvider(id);

    ref.listen(provider, (prev, next) {
      final msg = next.errorMessage;
      if (msg != null && msg != prev?.errorMessage) {
        TopMessage.show(context, msg);
      }
    });

    final state = ref.watch(provider);
    final mydata = state.data;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 330,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: AppRadii.noneAll,
                        child: Image.network(
                          '${ApiService.imageURL}${mydata?.project.imageUrl ?? ''}',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) {
                            return SvgPicture.asset(
                              AppAssets.image_holder,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => context.pop(),
                            child: SvgPicture.asset(AppAssets.back),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: AppSpacing.xl,
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${mydata?.clientContact.fullName}',
                              style: AppTextStyles.displayLabel16
                                  .copyWith(color: AppColors.white),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'ID: ${mydata?.project.idLabel}',
                            style: AppTextStyles.bodyMediumStrong
                                .copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _InfoCard(mydata: mydata),
              ],
            ),
          ),
          if (state.isLoading || state.isSubmitting) AppLoader(),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final dynamic mydata;

  const _InfoCard({required this.mydata});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.mld),
            decoration: BoxDecoration(
              color: AppColors.surfaceMid,
              borderRadius: AppRadii.xxxlAll,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                _InfoRow(
                  icon: Icons.calendar_today,
                  text: DateTimeUtils.formatDate(
                      '${mydata?.project.eventDate}'),
                ),
                const SizedBox(height: AppSpacing.xs),
                _InfoRow(
                  icon: Icons.access_time,
                  text:
                      '${DateTimeUtils.formatTime(mydata?.project.startTime ?? "")} - ${DateTimeUtils.formatTime(mydata?.project.endTime ?? "")}',
                ),
                const SizedBox(height: AppSpacing.xs),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  text: '${mydata?.project.eventLocation}',
                ),
                const SizedBox(height: AppSpacing.mld),
                Divider(color: AppColors.dividerDark, thickness: 0.8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Shoot Type',
                            style: AppTextStyles.body12
                                .copyWith(color: AppColors.white30),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Booking Type',
                            style: AppTextStyles.body12
                                .copyWith(color: AppColors.white30),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _Chip(text: '${mydata?.project.shootType}'),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child:
                                _Chip(text: '${mydata?.project.bookingType}'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Divider(color: AppColors.dividerDark, thickness: 0.8),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.mld),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundOpacity70,
                    borderRadius: AppRadii.xlAll,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shoot Status',
                        style: AppTextStyles.bodyMediumStrong
                            .copyWith(color: AppColors.primary),
                      ),
                      const Divider(
                        color: AppColors.dividerDark,
                        thickness: 0.8,
                      ),
                      const SizedBox(height: AppSpacing.mld),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current Stage',
                            style: AppTextStyles.body12
                                .copyWith(color: AppColors.white30),
                          ),
                          Text(
                            'Pre Production',
                            style: AppTextStyles.body12
                                .copyWith(color: AppColors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Last Updated',
                            style: AppTextStyles.body12
                                .copyWith(color: AppColors.white30),
                          ),
                          Text(
                            DateTimeUtils.formatReadableDateTime(
                              mydata?.project.lastUpdated?.toString(),
                            ),
                            style: AppTextStyles.body12
                                .copyWith(color: AppColors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Divider(color: AppColors.dividerDark, thickness: 0.8),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Time & Budget',
                style: AppTextStyles.displayLabel14Strong
                    .copyWith(color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.mld,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceMid,
              borderRadius: AppRadii.portfolioCompactAll,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _BudgetItem(
                    icon: Icons.attach_money,
                    title: 'Event Budget',
                    value: '\$${mydata?.project.budget}',
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: _BudgetItem(
                    icon: Icons.access_time,
                    title: 'Total Time Duration',
                    value:
                        '${mydata?.project.totalTimeDurationHours ?? 0} hours',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(borderRadius: AppRadii.clientContactAll),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: AppColors.dividerDark, thickness: 0.8),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Client Contact Information',
                  style: AppTextStyles.displayLabel14Strong,
                ),
                const SizedBox(height: AppSpacing.mld),
                _ContactItem(
                  icon: SvgPicture.asset(AppAssets.person_icons),
                  title: 'Contact Name',
                  value: '${mydata?.clientContact.fullName}',
                ),
                const SizedBox(height: AppSpacing.mld),
                _ContactItem(
                  icon: SvgPicture.asset(AppAssets.Phone_Calling),
                  title: 'Contact Number',
                  value: mydata?.clientContact.phone ?? 'No number found',
                ),
                const SizedBox(height: AppSpacing.mld),
                _ContactItem(
                  icon: SvgPicture.asset(AppAssets.mail_icon),
                  title: 'Email ID',
                  value: '${mydata?.clientContact.email}',
                ),
                const SizedBox(height: AppSpacing.xxl),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.white60),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body12.copyWith(color: AppColors.white30),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;

  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceDim,
        borderRadius: AppRadii.portfolioAll,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.body12.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _BudgetItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _BudgetItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppRadii.lgAll,
          ),
          child: Icon(icon, color: AppColors.black, size: 20),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body12.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                value,
                style: AppTextStyles.body12.copyWith(
                  color: AppColors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final String value;

  const _ContactItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: AppColors.surfaceMid,
            borderRadius: AppRadii.xxlAll,
          ),
          child: Center(child: icon),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.white30),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                value,
                style: AppTextStyles.bodyMediumStrong
                    .copyWith(color: AppColors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
