import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/routes.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';
import '../../core/providers/guest_mode_provider.dart';

void showLoginDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColors.black.withValues(alpha: 0.6),
    builder: (dialogContext) {
      return Consumer(
        builder: (context, ref, child) {
          return Material(
            type: MaterialType.transparency,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.round),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.round),
                        color: AppColors.white.withValues(alpha: 0.15),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Please Login to Continue',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          _LoginDialogButton(
                            label: 'Ok',
                            onTap: () {
                              ref.read(guestModeProvider.notifier).exit();
                              Navigator.of(dialogContext).pop();
                              context.goNamed(Routes.login.name);
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _LoginDialogButton(
                            label: 'Cancel',
                            onTap: () => Navigator.of(dialogContext).pop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class _LoginDialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _LoginDialogButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.round),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMediumStrong.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
