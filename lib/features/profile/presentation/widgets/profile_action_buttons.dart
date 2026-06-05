import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../core/providers/auth_state_provider.dart';

/// Logout button at the bottom of the profile + the confirmation bottom sheet.
class ProfileLogoutButton extends ConsumerWidget {
  const ProfileLogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.smd,
        AppSpacing.base,
        AppSpacing.xl,
      ),
      color: AppColors.background,
      child: InkWell(
        onTap: () => _showLogoutBottomSheet(context, ref),
        borderRadius: AppRadii.xxlAll,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppRadii.xxlAll,
          ),
          child: Center(
            child: Text(
              'Logout',
              style: AppTextStyles.displayLabel14Strong.copyWith(
                color: AppColors.textHeading,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: const BoxDecoration(
            color: AppColors.surfaceStats,
            borderRadius: AppRadii.topMassive,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 30,
                margin: const EdgeInsets.only(bottom: AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.white30,
                  borderRadius: AppRadii.nanoAll,
                ),
              ),
              Text(
                'Logout',
                style: AppTextStyles.displayLabel15Strong
                    .copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to log out?',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.dividerDark),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.white60),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.buttonVertical,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.xlAll,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.displayLabel14.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref.read(authStateProvider.notifier).logout();
                        if (context.mounted) {
                          context.goNamed(Routes.login.name);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.buttonVertical,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.xlAll,
                        ),
                      ),
                      child: Text(
                        'Yes, Logout',
                        style: AppTextStyles.displayLabel14.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textHeading,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
