import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beige_creative_app/shared/widgets/app_icon_tap_target.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/loading.dart';
import '../providers/shoots_providers.dart';

/// Triggers the Decline Shoot Request modal bottom sheet.
Future<bool?> showDeclineShootBottomSheet(
  BuildContext context, {
  required int projectId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: (_) => ShootCancelledScreen(projectId: projectId),
  );
}

/// Modal Bottom Sheet for declining a shoot request.
class ShootCancelledScreen extends ConsumerStatefulWidget {
  final int? projectId;
  const ShootCancelledScreen({super.key, this.projectId});

  @override
  ConsumerState<ShootCancelledScreen> createState() =>
      _ShootCancelledScreenState();
}

class _ShootCancelledScreenState extends ConsumerState<ShootCancelledScreen> {
  final TextEditingController _commentController = TextEditingController();

  static const List<String> _reasons = [
    'Schedule conflict',
    'Equipment unavailable',
    'Location too far',
    'Rate too low',
    'Others',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.projectId ?? 0;
    final state = ref.watch(cancelShootProvider(id));
    final notifier = ref.read(cancelShootProvider(id).notifier);
    final isOtherSelected = state.selectedReason == 'Others';

    ref.listen(cancelShootProvider(id).select((s) => s.submittedSignal), (
      prev,
      next,
    ) {
      if ((prev ?? 0) < next) {
        if (context.mounted) {
          Navigator.of(context).pop(true);
        }
      }
    });

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: AppRadii.topMassive,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Drag Handle
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.white24,
                      borderRadius: AppRadii.hugeAll,
                    ),
                  ),
                ),
                AppSpacing.verticalXxl,

                /// Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Decline Shoot Request',
                      style: AppTextStyles.displayLabel16,
                    ),
                    AppIconTapTarget(
                      semanticLabel: 'Close',
                      onTap: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close, color: AppColors.white),
                    ),
                  ],
                ),

                AppSpacing.verticalBase,

                const Text(
                  "Please let us know why you're declining this request.\nThis helps improve future matching.",
                  style: AppTextStyles.bodyCompact,
                ),

                const SizedBox(height: AppSpacing.lg),
                const Divider(
                  color: AppColors.dividerDark,
                  thickness: 0.8,
                ),
                const SizedBox(height: AppSpacing.lg),

                const Text(
                  'Reason for Declining',
                  style: AppTextStyles.body14Medium,
                ),

                AppSpacing.verticalMd,

                ..._reasons.map((reason) {
                  final selected = state.selectedReason == reason;
                  return InkWell(
                    onTap: () {
                      notifier.selectReason(reason);
                    },
                    borderRadius: AppRadii.mdAll,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.smd,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.transparent,
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.white30,
                                width: 1.5,
                              ),
                            ),
                            child: selected
                                ? Center(
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.onPrimary,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.mld),
                          Text(reason, style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: AppSpacing.md),
                _buildCommentField(isOtherSelected),

                AppSpacing.verticalXxl,

                /// Action buttons: Cancel & Decline (Option 1 - Dark text on Gold primary)
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.white30),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.xxlAll,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.displayLabel14.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.gapHBase,
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            disabledBackgroundColor:
                                AppColors.primary.withValues(alpha: 0.35),
                            disabledForegroundColor:
                                AppColors.onPrimary.withValues(alpha: 0.4),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.xxlAll,
                            ),
                          ),
                          onPressed:
                              state.selectedReason.isEmpty || state.isSubmitting
                                  ? null
                                  : () => notifier.submit(
                                        comment: isOtherSelected &&
                                                _commentController.text
                                                    .trim()
                                                    .isNotEmpty
                                            ? _commentController.text.trim()
                                            : null,
                                      ),
                          child: state.isSubmitting
                              ? const AppCircularLoader(
                                  size: 18,
                                  strokeWidth: 2,
                                  color: AppColors.onPrimary,
                                )
                              : Text(
                                  'Decline',
                                  style: AppTextStyles.displayLabel14.copyWith(
                                    color: state.selectedReason.isEmpty
                                        ? AppColors.white38
                                        : AppColors.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentField(bool isOtherSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional comments (optional)',
          style: AppTextStyles.body12.copyWith(
            color: isOtherSelected ? AppColors.white70 : AppColors.white30,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.mld,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadii.xlAll,
            border: Border.all(
              color: isOtherSelected ? AppColors.white24 : AppColors.white10,
              width: 1.0,
            ),
            color: isOtherSelected
                ? AppColors.black.withValues(alpha: 0.2)
                : AppColors.surfaceStats.withValues(alpha: 0.3),
          ),
          child: TextField(
            controller: _commentController,
            enabled: isOtherSelected,
            maxLines: 3,
            style: AppTextStyles.body14.copyWith(
              color: isOtherSelected ? AppColors.white : AppColors.white30,
            ),
            decoration: InputDecoration(
              hintText: isOtherSelected
                  ? 'Any additional details..'
                  : 'Select "Others" to add details..',
              hintStyle: AppTextStyles.inherit13.copyWith(
                color: isOtherSelected ? AppColors.white30 : AppColors.white24,
              ),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}
