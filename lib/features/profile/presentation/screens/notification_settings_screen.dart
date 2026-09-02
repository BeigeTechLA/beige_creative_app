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

import '../providers/notification_settings_providers.dart';
import '../widgets/notification_category_sheet.dart';


class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationSettingsProvider.notifier).loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {

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
              onTap: () => context.pop(true),
              icon: SvgPicture.asset(AppAssets.back, height: 24),
            ),
            const SizedBox(height: 16),

            Text(
              'Notification Settings',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose how you want to receive notifications',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white60,
                fontSize: 14,
              ),

            ),
            const SizedBox(height: 20),

            // Push Notifications Row
            _NotificationRow(
              svgAsset: AppAssets.icPushNotification,
              title: 'Push Notifications',
              subtitle: 'Receive notifications on your mobile device',
              value: state.pushNotifications,
              onChanged: (val) {
                notifier.togglePushNotifications(val);
                NotificationCategorySheet.show(context, type: NotificationCategoryType.push);
              },
              onTapRow: () => NotificationCategorySheet.show(context, type: NotificationCategoryType.push),
            ),
            const SizedBox(height: 16),

            // Email Notifications Row
         /*   _NotificationRow(
              svgAsset: AppAssets.icEmailNotification,
              iconBorderColor: AppColors.magentaAccent,
              iconBgColor: AppColors.purpleWash,
              title: 'Email Notifications',
              subtitle: 'Receive notifications via email',
              value: state.emailNotifications,
              onChanged: (val) {
                notifier.toggleEmailNotifications(val);
                NotificationCategorySheet.show(context, type: NotificationCategoryType.email);
              },
              onTapRow: () => NotificationCategorySheet.show(context, type: NotificationCategoryType.email),
            ),*/
            const SizedBox(height: 24),
/*
            // Smart Delivery Info Box (Matches mockup design)
            Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                borderRadius: AppRadii.lgAll,
                color: AppColors.blueSkyWash,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.blueElectric,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Smart Delivery',
                        style: AppTextStyles.body15Strong.copyWith(
                          color: AppColors.blueElectric,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Critical notifications are always sent via push and email, regardless of your preferences. We also suppress notifications when you\'re actively using the app to reduce interruptions.',
                    style: AppTextStyles.body12.copyWith(
                      color: AppColors.blueElectric,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Future Ready Section (Matches mockup design)
            Row(
              children: [
                Text(
                  'Future Ready',
                  style: AppTextStyles.displayStrong16w600.copyWith(
                    color: AppColors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.magentaAccent.withValues(alpha: 0.6)),
                    color: AppColors.magentaAccent.withValues(alpha: 0.15),
                  ),
                  child: Text(
                    'Coming Soon',
                    style: AppTextStyles.body12.copyWith(
                      color: AppColors.magentaAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Future Ready Cards
            const _FutureReadyCard(
              title: 'AI Notification Summaries',
              subtitle: 'Get smart digests like "3 files uploaded and 2 approvals pending"',
            ),
            const SizedBox(height: 12),
            const _FutureReadyCard(
              title: 'Workflow Automation',
              subtitle: 'Build custom rules like "If proposal approved -> notify finance team"',
            ),*/
          ],
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.svgAsset,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.onTapRow,
  });

  final String svgAsset;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onTapRow;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapRow ?? () => onChanged(!value),
      borderRadius: AppRadii.lgAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            SvgPicture.asset(
              svgAsset,
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            AppToggleSwitch(
              value: value,
              onChanged: onChanged,
              width: 41,
              height: 26,
            ),
          ],
        ),
      ),
    );
  }
}

/*class _FutureReadyCard extends StatelessWidget {
  const _FutureReadyCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body15Strong.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.body12.copyWith(
              color: AppColors.white60,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}*/
