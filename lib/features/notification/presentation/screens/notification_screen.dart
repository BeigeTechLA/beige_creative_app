import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/app_icon_tap_target.dart';
import '../../../../shared/widgets/app_toggle_switch.dart';
import '../providers/notification_providers.dart';
import '../widgets/notification_category_sheet.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SVG Back Icon from AppAssets.back
            AppIconTapTarget(
              semanticLabel: 'Back',
              onTap: () => context.pop(),
              icon: SvgPicture.asset(
                AppAssets.back,
                height: 24,
                width: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title & Subtitle (Unbounded / Outfit typography)
            Text(
              'Notification Settings',
              style: AppTextStyles.displayStrong16w600.copyWith(
                color: AppColors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose how you want to receive notifications',
              style: AppTextStyles.body14.copyWith(
                color: AppColors.white60,
              ),
            ),
            const SizedBox(height: 20),

            // Notification Toggles & Smart Delivery Container
            Column(
              children: [
                // Push Notifications Row
                _NotificationRow(
                  iconData: Icons.smartphone_outlined,
                  iconBorderColor: const Color(0xFF155DFC),
                  iconBgColor: const Color(0xFFDBEAFE),
                  title: 'Push Notifications',
                  subtitle: 'Receive notifications on your mobile device',
                  value: state.pushNotifications,
                  onChanged: (val) {
                    notifier.togglePushNotifications(val);
                    // When Push Notifications is toggled ON, automatically open Select Categories dialog
                    if (val) {
                      NotificationCategorySheet.show(context);
                    }
                  },
                ),
            const _SectionDivider(),


            // Email Notifications Row
                _NotificationRow(
                  iconData: Icons.mail_outline,
                  iconBorderColor: const Color(0xFFC026D3),
                  iconBgColor: const Color(0xFFF3E8FF),
                  title: 'Email Notifications',
                  subtitle: 'Receive notifications via email',
                  value: state.emailNotifications,
                  onChanged: (val) {
                    notifier.toggleEmailNotifications(val);
                  },
                ),
                const SizedBox(height: 16),

                // Smart Delivery Info Box (#DBEAFE background, #155DFC text)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.hugeAll,
                    color: const Color(0xFFDBEAFE),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF155DFC),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Smart Delivery',
                            style: AppTextStyles.bodyLargeStrong.copyWith(
                              color: const Color(0xFF155DFC),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Critical notifications are always sent via push and email, regardless of your preferences. We also suppress notifications when you\'re actively using the app to reduce interruptions.',
                        style: AppTextStyles.body13.copyWith(
                          color: const Color(0xFF155DFC),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Future Ready Header & Pill Badge
            Row(
              children: [
                Text(
                  'Future Ready',
                  style: AppTextStyles.displayStrong16w600.copyWith(
                    color: AppColors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Coming Soon',
                    style: AppTextStyles.body12.copyWith(
                      color: const Color(0xFFC026D3),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Future Feature Cards Container
            Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                borderRadius: AppRadii.hugeAll,
                color: AppColors.surfaceVariant,
              ),
              child: Column(
                children: const [
                  _FutureFeatureRow(
                    title: 'AI Notification Summaries',
                    description:
                        'Get smart digests like "3 files uploaded and 2 approvals pending"',
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Divider(color: AppColors.dividerDark, height: 1),
                  ),
                  _FutureFeatureRow(
                    title: 'Workflow Automation',
                    description:
                        'Build custom rules like "If proposal approved -> notify finance team"',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.iconData,
    required this.iconBorderColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData iconData;
  final Color iconBorderColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: AppRadii.lgAll,
              border: Border.all(color: iconBorderColor, width: 1.5),
            ),
            child: Icon(iconData, color: iconBorderColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body15Strong.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.body12.copyWith(
                    color: AppColors.white60,
                  ),
                ),
              ],
            ),
          ),
          AppToggleSwitch(
            value: value,
            onChanged: onChanged,
            width: 44,
            height: 26,
          ),
        ],
      ),
    );
  }
}

class _FutureFeatureRow extends StatelessWidget {
  const _FutureFeatureRow({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body15Strong.copyWith(
                    color: AppColors.white54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.body12.copyWith(
                    color: AppColors.white38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
