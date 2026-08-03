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

            // Header Title & Subtitle (Unbounded / Outfit typography from AppTextStyles)
            Text(
              'Notification Settings',
              style: AppTextStyles.displayStrong16w600.copyWith(
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose how you want to receive notifications',
              style: AppTextStyles.body14.copyWith(color: AppColors.white60),
            ),
            const SizedBox(height: 20),

            // Push Notifications Row
            _NotificationRow(
              iconData: Icons.smartphone_outlined,
              iconBorderColor: AppColors.blueElectric,
              iconBgColor: AppColors.blueSkyWash,
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
            const SizedBox(height: 16),

            // Email Notifications Row
            _NotificationRow(
              iconData: Icons.mail_outline,
              iconBorderColor: AppColors.magentaAccent,
              iconBgColor: AppColors.purpleWash,
              title: 'Email Notifications',
              subtitle: 'Receive notifications via email',
              value: state.emailNotifications,
              onChanged: (val) {
                notifier.toggleEmailNotifications(val);
              },
            ),
            const SizedBox(height: 24),

            // Smart Delivery Info Box (Matches Figma design)
            // Container(
            //   padding: const EdgeInsets.all(AppSpacing.base),
            //   decoration: BoxDecoration(
            //     borderRadius: AppRadii.hugeAll,
            //     color: AppColors.blueSkyWash,
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Row(
            //         children: [
            //           const Icon(
            //             Icons.info_outline,
            //             color: AppColors.blueElectric,
            //             size: 20,
            //           ),
            //           const SizedBox(width: 8),
            //           Text(
            //             'Smart Delivery',
            //             style: AppTextStyles.bodyLargeStrong.copyWith(
            //               color: AppColors.blueElectric,
            //             ),
            //           ),
            //         ],
            //       ),
            //       const SizedBox(height: 6),
            //       Text(
            //         'Critical notifications are sent via push and email, regardless of your preferences. We also suppress notifications when you\'re actively using the app to reduce interruptions.',
            //         style: AppTextStyles.body13.copyWith(
            //           color: AppColors.blueElectric,
            //           height: 1.4,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 24),
          ],
        ),
      ),
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
