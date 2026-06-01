import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

/// Menu card: "My Account / Portfolio & Credentials / Settings" rows. Pure
/// presentation; tap callbacks navigate via go_router.
class ProfileSectionList extends StatelessWidget {
  const ProfileSectionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          const _SectionHeader('My Account'),
          _SectionCard(
            children: [
              _MenuRow(
                iconPath: AppAssets.userid,
                title: 'Profile Details',
                onTap: () => context.pushNamed(Routes.profileDetails.name),
              ),
            ],
          ),
          const _SectionHeader('Portfolio & Credentials'),
          _SectionCard(
            children: [
              _MenuRow(
                iconPath: AppAssets.gallery,
                title: 'Featured Works',
                onTap: () => context.pushNamed(Routes.featuredWorks.name),
              ),
              const _SectionDivider(),
              _MenuRow(
                iconPath: AppAssets.certificates,
                title: 'certificates',
                onTap: () => context.pushNamed(Routes.certificates.name),
              ),
              const _SectionDivider(),
              _MenuRow(
                iconPath: AppAssets.resume,
                title: 'resume',
                onTap: () => context.pushNamed(Routes.resume.name),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Divider(color: AppColors.dividerDark),
          ),
          const _SectionHeader('Settings'),
          const SizedBox(height: 10),
          _SectionCard(
            children: [
              _MenuRow(
                iconPath: AppAssets.appperference,
                title: 'App Preferences',
                onTap: () => context.pushNamed(Routes.appPreferences.name),
              ),
              const _SectionDivider(),
              const _MenuRow(
                iconPath: AppAssets.notificationsetting,
                title: 'Notifications Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.displayLabel14
                .copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadii.hugeAll,
      ),
      child: Column(children: children),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final String iconPath;
  final String title;
  final VoidCallback? onTap;

  const _MenuRow({
    required this.iconPath,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadii.hugeAll,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: const BoxDecoration(
                color: AppColors.calendarGrid,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: AppTextStyles.body14),
            ),
            SvgPicture.asset(
              AppAssets.goto,
              height: 10,
              width: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Divider(height: 1, color: AppColors.dividerDark),
    );
  }
}
