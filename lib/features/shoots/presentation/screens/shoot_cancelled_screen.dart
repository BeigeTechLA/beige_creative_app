import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/loading.dart';
import '../providers/shoots_providers.dart';

class ShootCancelledScreen extends ConsumerStatefulWidget {
  final int? projectId;
  const ShootCancelledScreen({super.key, this.projectId});

  @override
  ConsumerState<ShootCancelledScreen> createState() => _ShootCancelledScreenState();
}

class _ShootCancelledScreenState extends ConsumerState<ShootCancelledScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isOtherSelected = false;

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

    ref.listen(cancelShootProvider(id).select((s) => s.submittedSignal),
        (prev, next) {
      if ((prev ?? 0) < next) {
        context.goNamed(Routes.shootCancelotties.name);
      }
    });

    return AppScaffold(
      safeTop: false,
      backgroundColor: AppColors.black.withValues(alpha: 0.4),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surfaceMid,
            borderRadius: AppRadii.topHeader,
          ),
          child: SafeArea(
            top: false,
            child: Column(
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
                    InkWell(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.close, color: AppColors.white),
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

                Expanded(
                  child: ListView(
                    children: [
                      ..._reasons.map((reason) {
                        final selected = state.selectedReason == reason;
                        return InkWell(
                          onTap: () {
                            notifier.selectReason(reason);
                            setState(() {
                              _isOtherSelected = reason == 'Others';
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.smd),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.white24,
                                      width: 1.3,
                                    ),
                                  ),
                                  child: selected
                                      ? Center(
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.primary,
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
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _isOtherSelected
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(top: AppSpacing.smd),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.mld),
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadii.xlAll,
                                    border:
                                        Border.all(color: AppColors.white24),
                                    color: AppColors.black
                                        .withValues(alpha: 0.2),
                                  ),
                                  child: TextField(
                                    controller: _commentController,
                                    maxLines: 3,
                                    style: AppTextStyles.inherit,
                                    decoration: const InputDecoration(
                                      hintText: 'Any additional details...',
                                      hintStyle: AppTextStyles.inherit13,
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ),
                    ],
                  ),
                ),

                AppSpacing.verticalBase,

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.xxlAll,
                            ),
                          ),
                          onPressed: () => context.pop(),
                          child: const Text(
                            'Cancel',
                            style: AppTextStyles.displayLabel14,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.gapHBase,
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.xxlAll,
                            ),
                          ),
                          onPressed: state.selectedReason.isEmpty ||
                                  state.isSubmitting
                              ? null
                              : () => notifier.submit(
                                    comment: _isOtherSelected
                                        ? _commentController.text.trim()
                                        : null,
                                  ),
                          child: state.isSubmitting
                              ? const AppCircularLoader(
                                  size: 18,
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                )
                              : const Text(
                                  'Decline',
                                  style: AppTextStyles.displayLabel14,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalSmd,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
