import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../config/env.dart';
import '../../../../model_class/upcoming_shootview_model.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/app_icon_tap_target.dart';
import '../../../../shared/widgets/loading.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../../../utility/date_time_utils.dart';
import '../providers/upcoming_shoot_providers.dart';

String? _resolveImageUrl(dynamic rawUrl) {
  if (rawUrl == null) return null;
  final str = rawUrl.toString().trim();
  if (str.isEmpty) return null;
  if (str.startsWith('http://') || str.startsWith('https://')) return str;
  final cleanPath = str.startsWith('/') ? str.substring(1) : str;
  final base = Env.imageUrl.endsWith('/') ? Env.imageUrl : '${Env.imageUrl}/';
  return '$base$cleanPath';
}

Widget _buildHeaderImage(dynamic rawUrl) {
  final resolvedUrl = _resolveImageUrl(rawUrl);
  if (resolvedUrl == null) {
    return Container(
      height: 362,
      width: double.infinity,
      color: AppColors.surfaceDark,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        AppAssets.imageHolder,
        height: 56,
        colorFilter: const ColorFilter.mode(
          AppColors.white38,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  return CachedNetworkImage(
    imageUrl: resolvedUrl,
    fit: BoxFit.cover,
    width: double.infinity,
    height: 362,
    placeholder: (context, url) => Container(
      height: 362,
      width: double.infinity,
      color: AppColors.surfaceDark,
      alignment: Alignment.center,
      child: const AppCircularLoader(size: 28),
    ),
    errorWidget: (context, url, error) {
      return Container(
        height: 362,
        width: double.infinity,
        color: AppColors.surfaceDark,
        alignment: Alignment.center,
        child: SvgPicture.asset(
          AppAssets.imageHolder,
          height: 56,
          colorFilter: const ColorFilter.mode(
            AppColors.white38,
            BlendMode.srcIn,
          ),
        ),
      );
    },
  );
}

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
    final project = mydata?.project;
    final statusText = (project?.status.isNotEmpty == true)
        ? '${project!.status[0].toUpperCase()}${project.status.substring(1).toLowerCase()}'
        : 'Active';

    return AppScaffold(
      safeTop: false,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 362,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: AppRadii.noneAll,
                        child: _buildHeaderImage(project?.imageUrl),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height:
                          MediaQuery.of(context).padding.top +
                          AppSpacing.xxxl,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.7),
                                Colors.black.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 90,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.85),
                                Colors.black.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + AppSpacing.sm,
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppIconTapTarget(
                            semanticLabel: 'Back',
                            onTap: () => context.pop(),
                            icon: SvgPicture.asset(AppAssets.back),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: AppSpacing.md,
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B4D2E),
                              borderRadius: AppRadii.portfolioAll,
                              border: Border.all(
                                color: const Color(0xFF22C55E).withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  statusText,
                                  style: AppTextStyles.body12.copyWith(
                                    color: const Color(0xFF22C55E),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  project?.projectName.isNotEmpty == true
                                      ? project!.projectName
                                      : 'Project Details',
                                  style: AppTextStyles.displayLabel16.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              if (project?.idLabel.isNotEmpty == true)
                                Text(
                                  project!.idLabel.startsWith('#')
                                      ? 'ID: ${project.idLabel}'
                                      : 'ID: #${project.idLabel}',
                                  style: AppTextStyles.bodyMediumStrong.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                            ],
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
  final MyData? mydata;

  const _InfoCard({required this.mydata});

  @override
  Widget build(BuildContext context) {
    final teamMembers = mydata?.teamMembers ?? [];
    final assignedCount = mydata?.teamSummary.assignedCount ?? teamMembers.length;
    final totalRequired = mydata?.teamSummary.totalRequired ?? teamMembers.length;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Info & Shoot Status Ticket Card
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surfaceMid,
              borderRadius: AppRadii.xxxlAll,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.mld),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        icon: Icons.calendar_today,
                        text: DateTimeUtils.formatReadableDate(
                          '${mydata?.project.eventDate}',
                        ),
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
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Shoot Type',
                                  style: AppTextStyles.body12.copyWith(
                                    color: AppColors.white30,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                _Chip(text: '${mydata?.project.shootType}'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Booking Type',
                                  style: AppTextStyles.body12.copyWith(
                                    color: AppColors.white30,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                _Chip(
                                  text: '${mydata?.project.bookingType}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Perforated Ticket Stub Separator
                const _TicketDashedDivider(),

                // Shoot Status Inner Sub-Card
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.mld),
                  child: Container(
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
                          style: AppTextStyles.bodyMediumStrong.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const Divider(
                          color: AppColors.dividerDark,
                          thickness: 0.8,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Current Stage',
                              style: AppTextStyles.body12.copyWith(
                                color: AppColors.white30,
                              ),
                            ),
                            Text(
                              'Pre Production',
                              style: AppTextStyles.body12.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Last Updated',
                              style: AppTextStyles.body12.copyWith(
                                color: AppColors.white30,
                              ),
                            ),
                            Text(
                              DateTimeUtils.formatReadableDateTime(
                                mydata?.project.lastUpdated?.toString(),
                              ),
                              style: AppTextStyles.body12.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Team Members Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Team Members',
                style: AppTextStyles.displayLabel14Strong.copyWith(
                  color: AppColors.white,
                ),
              ),
              Text(
                '(${assignedCount.toString().padLeft(2, '0')}/${totalRequired.toString().padLeft(2, '0')})',
                style: AppTextStyles.bodyMediumStrong.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (teamMembers.isEmpty)
            Text(
              'No team members assigned',
              style: AppTextStyles.body12.copyWith(color: AppColors.white30),
            )
          else
            SizedBox(
              height: 125,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: teamMembers.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.lg),
                itemBuilder: (context, index) {
                  final member = teamMembers[index];
                  return _TeamMemberAvatarItem(member: member);
                },
              ),
            ),

          const SizedBox(height: AppSpacing.xxl),

          // Time & Budget Section
          Text(
            'Time & Budget',
            style: AppTextStyles.displayLabel14Strong.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
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
                    value: '\$${mydata?.project.budget ?? 0}',
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: _BudgetItem(
                    icon: Icons.access_time,
                    title: 'Total Time Duration',
                    value:
                        '${(mydata?.project.totalTimeDurationHours ?? 0).toInt().toString().padLeft(2, '0')} Hours',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Client Contact Information Section
          Text(
            'Client Contact Information',
            style: AppTextStyles.displayLabel14Strong.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ContactItem(
            icon: SvgPicture.asset(AppAssets.personIcon),
            title: 'Contact Name',
            value: mydata?.clientContact.fullName.isNotEmpty == true
                ? mydata!.clientContact.fullName
                : 'No name found',
          ),
          const SizedBox(height: AppSpacing.mld),
          _ContactItem(
            icon: SvgPicture.asset(AppAssets.phoneCalling),
            title: 'Contact Number',
            value: mydata?.clientContact.phone.isNotEmpty == true
                ? mydata!.clientContact.phone
                : 'No number found',
          ),
          const SizedBox(height: AppSpacing.mld),
          _ContactItem(
            icon: SvgPicture.asset(AppAssets.mailIcon),
            title: 'Email ID',
            value: mydata?.clientContact.email.isNotEmpty == true
                ? mydata!.clientContact.email
                : 'No email found',
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _TicketDashedDivider extends StatelessWidget {
  const _TicketDashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: -10,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -10,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final boxWidth = constraints.maxWidth;
                const dashWidth = 6.0;
                const dashHeight = 1.0;
                final dashCount = (boxWidth / (2 * dashWidth)).floor();
                return Flex(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  direction: Axis.horizontal,
                  children: List.generate(dashCount, (_) {
                    return const SizedBox(
                      width: dashWidth,
                      height: dashHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: AppColors.white30),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMemberAvatarItem extends StatelessWidget {
  final TeamMember member;

  const _TeamMemberAvatarItem({required this.member});

  @override
  Widget build(BuildContext context) {
    final imageUrl = member.profileImageUrl.startsWith('http')
        ? member.profileImageUrl
        : '${Env.imageUrl}${member.profileImageUrl}';

    return SizedBox(
      width: 90,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => Container(
                  color: AppColors.surfaceMid,
                  child: Center(
                    child: Text(
                      member.name.isNotEmpty ? member.name[0].toUpperCase() : 'M',
                      style: AppTextStyles.bodyMediumStrong.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            member.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.body12.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            member.roleName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white60,
              fontSize: 10,
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
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white30,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                value,
                style: AppTextStyles.bodyMediumStrong.copyWith(
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
