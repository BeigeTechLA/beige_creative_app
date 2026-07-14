import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige_creative_app/shared/widgets/app_icon_tap_target.dart';
import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../model_class/myprofile_model.dart';
import '../../../../config/env.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/loading.dart';
import '../providers/profile_details_providers.dart';

class ProfileDetails1Screen extends ConsumerWidget {
  const ProfileDetails1Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileDetailsViewProvider);
    final notifier = ref.read(profileDetailsViewProvider.notifier);

    return AppScaffold(
      body: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.smd,
                ),
                child: Row(
                  children: [
                    AppIconTapTarget(
                      semanticLabel: 'Back',
                      onTap: () => context.pop(),
                      icon: SvgPicture.asset(AppAssets.back, height: 24),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Profile Details',
                          style: AppTextStyles.displayLabel16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xxs,
                ),
                padding: const EdgeInsets.all(AppSpacing.tabInnerPad),
                height: 53,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMid,
                  borderRadius: AppRadii.xlAll,
                ),
                child: Row(
                  children: [
                    _Tab(
                      title: 'Personal',
                      index: 0,
                      selected: state.selectedTab == 0,
                      onTap: notifier.selectTab,
                    ),
                    _Tab(
                      title: 'Professional',
                      index: 1,
                      selected: state.selectedTab == 1,
                      onTap: notifier.selectTab,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: state.selectedTab == 0
                    ? _PersonalCard(
                        profile: state.profile,
                        onEdit: () async {
                          final result = await context.pushNamed(
                            Routes.editPersonalDetails.name,
                          );
                          if (result == true) notifier.refresh();
                        },
                      )
                    : _ProfessionalCard(
                        profile: state.profile,
                        onEdit: () async {
                          final result = await context.pushNamed(
                            Routes.enterProfessionalDetails.name,
                          );
                          if (result == true) notifier.refresh();
                        },
                      ),
              ),
            ],
          ),
          if (state.isLoading) AppLoader(),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String title;
  final int index;
  final bool selected;
  final ValueChanged<int> onTap;

  const _Tab({
    required this.title,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          decoration: BoxDecoration(
            gradient: selected ? AppColors.goldHorizontalGradient : null,
            borderRadius: AppRadii.mldAll,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTextStyles.body14Medium.copyWith(
              color: selected ? AppColors.textHeading : AppColors.white30,
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonalCard extends StatelessWidget {
  final MyProfileData? profile;
  final VoidCallback onEdit;

  const _PersonalCard({required this.profile, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final nameParts = (profile?.user.name ?? '').trim().split(' ');
    final firstName = nameParts.isNotEmpty && nameParts.first.isNotEmpty
        ? nameParts.first
        : 'No name';
    final lastName = nameParts.length > 1 && nameParts.last.isNotEmpty
        ? nameParts.last
        : 'No Name';

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(
            top: AppSpacing.avatarOverlapTop,
            left: AppSpacing.inlineNudge,
            right: AppSpacing.inlineNudge,
            bottom: AppSpacing.xl,
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.profileCardTop,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceMid,
            borderRadius: AppRadii.hugeAll,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  '$firstName $lastName',
                  style: AppTextStyles.displayBold20,
                ),
                const SizedBox(height: 15),
                _EditButton(onTap: onEdit),
                const SizedBox(height: 25),
                const _Divider(),
                const SizedBox(height: 15),
                _InfoRow(title: 'First Name', value: firstName),
                _InfoRow(title: 'Last Name', value: lastName),
                _InfoRow(
                  title: 'Email',
                  value: profile?.user.email ?? 'No Email Found',
                ),
                _InfoRow(
                  title: 'Location',
                  value: profile?.user.location ?? 'No location Found',
                ),
              ],
            ),
          ),
        ),
        _Avatar(profileImageUrl: profile?.profileImageUrl ?? ''),
      ],
    );
  }
}

class _ProfessionalCard extends StatelessWidget {
  final MyProfileData? profile;
  final VoidCallback onEdit;

  const _ProfessionalCard({required this.profile, required this.onEdit});

  String _primaryRoleLabel(String? role) {
    if (role == null || role.isEmpty) return '-';
    final roles = <String>[];
    if (role.contains('1')) roles.add('Videographer');
    if (role.contains('2')) roles.add('Photographer');
    return roles.isEmpty ? '-' : roles.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final nameParts = (profile?.user.name ?? '').trim().split(' ');
    final firstName = nameParts.isNotEmpty && nameParts.first.isNotEmpty
        ? nameParts.first
        : 'No name';
    final lastName = nameParts.length > 1 && nameParts.last.isNotEmpty
        ? nameParts.last
        : 'No Name';

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(
            top: AppSpacing.profileCardTop,
            left: AppSpacing.inlineNudge,
            right: AppSpacing.inlineNudge,
            bottom: AppSpacing.xl,
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.profileCardTop,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceMid,
            borderRadius: AppRadii.hugeAll,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    '$firstName $lastName',
                    style: AppTextStyles.displayBold20,
                  ),
                ),
                const SizedBox(height: 15),
                Center(child: _EditButton(onTap: onEdit)),
                const SizedBox(height: 25),
                const _Divider(),
                const SizedBox(height: 20),
                _InfoRow(
                  title: 'Primary Role',
                  value: _primaryRoleLabel(profile?.primaryRole),
                ),
                _InfoRow(
                  title: 'Years of Experience',
                  value: profile != null
                      ? '${profile!.yearsOfExperience} Years'
                      : '-',
                ),
                _InfoRow(
                  title: 'Hourly Rate (\$)',
                  value: profile != null && profile!.hourlyRate.isNotEmpty
                      ? '\$${profile!.hourlyRate}'
                      : 'No Rate Found',
                ),
                const SizedBox(height: 15),
                const Text('Skills', style: AppTextStyles.body14),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 10,
                  runSpacing: 10,
                  children: (profile?.skills ?? [])
                      .map(
                        (skill) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.mld,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: AppRadii.smAll,
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.08),
                              width: 1,
                            ),
                            gradient: LinearGradient(
                              colors: [AppColors.white10, AppColors.white10],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Text(
                            skill.name,
                            style: AppTextStyles.bodyCompact.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                const _Divider(),
                const SizedBox(height: 20),
                const Text('Bio / About', style: AppTextStyles.body14),
                const SizedBox(height: 8),
                Text(
                  profile?.bio.isNotEmpty == true ? profile!.bio : '-',
                  style: AppTextStyles.bodyCompact.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        _Avatar(profileImageUrl: profile?.profileImageUrl ?? ''),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String profileImageUrl;

  const _Avatar({required this.profileImageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.goldSoftSand, width: 3),
      ),
      child: ClipOval(
        child: profileImageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: '${Env.imageUrl}$profileImageUrl',
                fit: BoxFit.cover,
                errorWidget: (_, _, _) {
                  return SvgPicture.asset(
                    AppAssets.userCircle,
                    fit: BoxFit.cover,
                  );
                },
              )
            : SvgPicture.asset(AppAssets.userCircle, fit: BoxFit.cover),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.whiteTransparent,
            AppColors.white10,
            AppColors.white20,
            AppColors.white10,
            AppColors.whiteTransparent,
          ],
        ),
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.editProfileBtnH,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadii.portfolioAll,
        ),
        child: Text(
          'Edit Profile Details',
          style: AppTextStyles.body14Medium.copyWith(
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.mld),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.body14.copyWith(color: AppColors.white),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.body14.copyWith(color: AppColors.white60),
            ),
          ),
        ],
      ),
    );
  }
}
