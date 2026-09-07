import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/app_cta_button.dart';
import '../../../../shared/widgets/top_message.dart';

class ApplicationRejectedScreen extends ConsumerWidget {
  const ApplicationRejectedScreen({super.key});

  Future<void> _contactSupport(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@beige.app',
      queryParameters: {'subject': 'CP Application Status Inquiry'},
    );
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        if (context.mounted) {
          TopMessage.show(
            context,
            'Please email support@beige.app for assistance.',
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        TopMessage.show(
          context,
          'Please email support@beige.app for assistance.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      safeTop: true,
      safeBottomNavigationBar: true,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.meetingCancelledBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.meetingCancelledFg.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  size: 48,
                  color: AppColors.meetingCancelledFg,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'An Update on Your Application',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingOutfitLg,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Thank you for taking the time to apply to join Beige as a Creator Partner. After reviewing your application, we’re unable to approve it at this time.\n\nThis decision does not diminish your experience or creative work. If you believe we missed something, or you would like guidance before applying again, our support team is here to help.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body14.copyWith(
                  color: AppColors.white70,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppCtaButton(
                label: 'Contact Support',
                height: 52,
                onPressed: () => _contactSupport(context),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () async {
                    await ref.read(authStateProvider.notifier).logout();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.white24),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
                  ),
                  child: Text(
                    'Log Out',
                    style: AppTextStyles.body15Medium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
