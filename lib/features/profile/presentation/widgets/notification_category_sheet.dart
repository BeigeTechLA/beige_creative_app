import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_cta_button.dart';
import '../../../../shared/widgets/app_toggle_switch.dart';
import 'notification_success_dialog.dart';
import '../providers/notification_settings_providers.dart';

enum NotificationCategoryType { push, email }

class NotificationCategorySheet extends ConsumerStatefulWidget {
  const NotificationCategorySheet({super.key, required this.type});

  final NotificationCategoryType type;

  static Future<void> show(
    BuildContext context, {
    NotificationCategoryType type = NotificationCategoryType.push,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (_) => NotificationCategorySheet(type: type),
    );
  }

  @override
  ConsumerState<NotificationCategorySheet> createState() =>
      _NotificationCategorySheetState();
}

class _NotificationCategorySheetState
    extends ConsumerState<NotificationCategorySheet> {
  late NotificationSettingsState _localState;

  @override
  void initState() {
    super.initState();
    _localState = ref.read(notificationSettingsProvider);
    // Fetch preferences when opening categories
    Future.microtask(() {
      final notifier = ref.read(notificationSettingsProvider.notifier);
      final future = widget.type == NotificationCategoryType.push
          ? notifier.loadPushPreferences()
          : notifier.loadEmailPreferences();
          
      future.then((_) {
        if (mounted) {
          setState(() {
            _localState = ref.read(notificationSettingsProvider);
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Title & Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Categories',
                style: AppTextStyles.displayStrong16w600.copyWith(
                  color: AppColors.white,
                  fontSize: 18,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(
            color: AppColors.white10,
            height: 1,
            thickness: 1,
          ),
          const SizedBox(height: 16),

          // Category List
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _CategoryRow(
                    svgAsset: AppAssets.notificationCategoryShoots,
                    title: 'Shoots',
                    subtitle: 'Shoot schedules, assignments, & updates',
                    value: _localState.categoryShoots,
                    onChanged: (val) {
                      setState(() {
                        _localState = _localState.copyWith(categoryShoots: val);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                 /* _CategoryRow(
                    svgAsset: AppAssets.notificationCategoryPayments,
                    title: 'Payments',
                    subtitle: 'Invoices, payment receipts, & reminders',
                    value: _localState.categoryPayouts,
                    onChanged: (val) {
                      setState(() {
                        _localState = _localState.copyWith(categoryPayouts: val);
                      });
                    },
                  ),*/
                  const SizedBox(height: 16),
                  _CategoryRow(
                    svgAsset: AppAssets.notificationCategoryMessages,
                    title: 'Messages',
                    subtitle: 'Direct messages and mentions',
                    value: _localState.categoryMessages,
                    onChanged: (val) {
                      setState(() {
                        _localState = _localState.copyWith(categoryMessages: val);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _CategoryRow(
                    svgAsset: AppAssets.notificationCategoryMeetings,
                    title: 'Meetings',
                    subtitle: 'Meeting invites, reminders, & updates',
                    value: _localState.categoryMeetings,
                    onChanged: (val) {
                      setState(() {
                        _localState = _localState.copyWith(categoryMeetings: val);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                 /* _CategoryRow(
                    svgAsset: AppAssets.notificationCategoryProposals,
                    title: 'Proposals',
                    subtitle: 'Proposal shares, approvals, & feedback',
                    value: _localState.categoryProposals,
                    onChanged: (val) {
                      setState(() {
                        _localState = _localState.copyWith(categoryProposals: val);
                      });
                    },
                  ),*/
                  const SizedBox(height: 16),
                 /* _CategoryRow(
                    svgAsset: AppAssets.notificationCategoryFiles,
                    title: 'Files',
                    subtitle: 'File uploads, shares, & review requests',
                    value: _localState.categoryFiles,
                    onChanged: (val) {
                      setState(() {
                        _localState = _localState.copyWith(categoryFiles: val);
                      });
                    },
                  ),*/
                  const SizedBox(height: 16),
                  /*_CategoryRow(
                    svgAsset: AppAssets.notificationCategorySystem,
                    title: 'System',
                    subtitle: 'System alerts & account updates',
                    value: _localState.categorySystem,
                    onChanged: (val) {
                      setState(() {
                        _localState = _localState.copyWith(categorySystem: val);
                      });
                    },
                  ),*/
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Save CTA Button
          AppCtaButton(
            label: 'Save',
            onPressed: () {
              final notifier = ref.read(notificationSettingsProvider.notifier);
              notifier.updateState(_localState);
              if (widget.type == NotificationCategoryType.push) {
                notifier.savePushPreferences();
              } else {
                notifier.saveEmailPreferences();
              }
              
              Navigator.of(context).pop();
              NotificationSuccessSheet.show(context);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.svgAsset,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String svgAsset;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
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
      ),
    );
  }
}
