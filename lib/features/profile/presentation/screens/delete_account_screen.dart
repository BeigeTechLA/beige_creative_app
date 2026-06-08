import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../providers/delete_account_providers.dart';

class DeleteAccountScreen extends ConsumerWidget {
  const DeleteAccountScreen({super.key});

  static const _reasons = [
    "What's the reason for deleting your account?",
    "Help us understand why you're leaving",
    "I'm not using the app anymore",
    'Others',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<DeleteAccountState>(deleteAccountNotifierProvider,
        (prev, next) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      if (next.validationMessage != null &&
          next.validationMessage != prev?.validationMessage) {
        messenger.showSnackBar(
          SnackBar(content: Text(next.validationMessage!)),
        );
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        messenger.showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    final state = ref.watch(deleteAccountNotifierProvider);
    final notifier = ref.read(deleteAccountNotifierProvider.notifier);

    return AppScaffold(
      body: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: SvgPicture.asset(
                  AppAssets.back,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete Account',
                style: AppTextStyles.displayStrong16w600.copyWith(
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'This action will permanently delete your account and all associated data. If you need help or have questions, please contact us at support@beige.com',
                style: AppTextStyles.body14LineRelaxed.copyWith(
                  color: AppColors.white30,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: const BoxDecoration(color: AppColors.surfaceMid),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Why do you wish to leave Beige?',
                          style: AppTextStyles.body14Medium.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please let us know the reason for deleting your account.',
                      style: AppTextStyles.body12.copyWith(
                        color: AppColors.white30,
                      ),
                    ),
                    ..._reasons.map(
                      (reason) => _ReasonOption(
                        reason: reason,
                        isSelected: state.selectedReason == reason,
                        onTap: () => notifier.selectReason(reason),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () async {
                          final ok = await notifier.requestDelete();
                          if (ok && context.mounted) {
                            context.pushNamed(
                              Routes.deleteAccountOtp.name,
                              extra: {'reason': state.selectedReason},
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.xlAll,
                    ),
                  ),
                  child: state.isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(AppColors.black),
                          ),
                        )
                      : Text(
                          'Continue',
                          style: AppTextStyles.displayLabel14.copyWith(
                            color: AppColors.textHeading,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonOption extends StatelessWidget {
  final String reason;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReasonOption({
    required this.reason,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.white30,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                reason,
                style: AppTextStyles.body14.copyWith(
                  color: AppColors.white30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
