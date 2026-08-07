import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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
                iconPath: AppAssets.userId,
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
                title: 'Certificates',
                onTap: () => context.pushNamed(Routes.certificates.name),
              ),
              const _SectionDivider(),
              _MenuRow(
                iconPath: AppAssets.resume,
                title: 'Resume',
                onTap: () => context.pushNamed(Routes.resume.name),
              ),
            ],
          ),

          const _SectionHeader('Settings'),
          _SectionCard(
            children: [
              _MenuRow(
                iconPath: AppAssets.appPreference,
                title: 'App Preferences',
                onTap: () => context.pushNamed(Routes.appPreferences.name),
              ),
              _SectionDivider(),
              _MenuRow(
                iconPath: AppAssets.notificationSetting,
                title: 'Notifications Settings',
              ),
            ],
          ),

          const _SectionHeader('Legal'),
          const SizedBox(height: 10),
          _SectionCard(
            children: [
              _MenuRow(
                iconPath: AppAssets.profileTerms,
                title: 'Terms & Condition',
                onTap: () async {
                  final uri = Uri.parse(
                    "https://beige.app/terms-and-conditions",
                  );
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
              ),
              const _SectionDivider(),
              _MenuRow(
                iconPath: AppAssets.profilePrivacy,
                title: 'Privacy Policy',
                onTap: () async {
                  final uri = Uri.parse("https://beige.app/privacy-policy");
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
      ),
      child: Container(
        height: 1,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.white.withValues(alpha: 0.09),
              AppColors.white.withValues(alpha: 0.24),
              AppColors.white.withValues(alpha: 0.09),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }
}
