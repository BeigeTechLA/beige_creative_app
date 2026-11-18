import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/routes.dart';
import '../../../../app/text_styles.dart';
import '../providers/delete_account_providers.dart';
import '../widgets/delete_flow_widgets.dart';

class DeleteAccountScreen extends ConsumerWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              const DeleteFlowBack(),
              const SizedBox(height: 8),
              Text(
                'Before You Delete Your Account',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Deleting your Beige account will deactivate your access to the platform and start the account deletion process.',
                style: DeleteFlowStyle.body,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: DeleteFlowStyle.warning.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: DeleteFlowStyle.warning, width: .5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: DeleteFlowStyle.warning.withValues(alpha: .2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/svg/delete_flow_warning.svg',
                          width: 16,
                          height: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Once data is permanently deleted, it may not be possible to recover it.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'If you have ongoing bookings, shoots, payments, or disputes, please contact Beige Support before proceeding.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white70,
                              fontSize: 10,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13),
              const _InfoCard(
                icon: 'user',
                title: 'Account access',
                description:
                    'You will no longer be able to access your account or use its features.',
              ),
              const _InfoCard(
                icon: 'profile',
                title: 'Profile and Personal Information',
                description:
                    'Eligible personal data will be scheduled for deletion.',
              ),
              const _InfoCard(
                icon: 'calendar',
                title: 'Bookings and assignments',
                description:
                    'You may lose access to your booking history, shoot details, assignments, and related conversations.',
              ),
              const _InfoCard(
                icon: 'folder',
                title: 'Files and Media',
                description:
                    'Your access to uploaded briefs, portfolios, and other files may be removed. Some files may be retained or handled separately where necessary.',
              ),
              const _InfoCard(
                icon: 'dollar',
                title: 'Payments and Records',
                description:
                    'Certain invoices, payment records, contracts, and dispute records may need to be retained as required by law.',
              ),
              const _InfoCard(
                icon: 'hourglass',
                title: 'Grace Period',
                description:
                    'Your eligible data will be scheduled for deletion. You can cancel your request before the scheduled deletion date.',
              ),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: DeleteFlowButton(
              label: ref.watch(deletionProvider).busy
                  ? 'Sending code…'
                  : 'Continue & Proceed to Verification',
              onPressed: ref.watch(deletionProvider).busy
                  ? null
                  : () async {
                      final sent = await ref
                          .read(deletionProvider.notifier)
                          .requestOtp();
                      if (!context.mounted) return;
                      if (sent) {
                        context.pushNamed(Routes.deleteAccountOtp.name);
                      } else {
                        final error = ref.read(deletionProvider).error ??
                            'Unable to send verification code. Please try again.';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      }
                    },
            ),
          ),
        ),
      ),
    ),
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final String icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: DeleteFlowStyle.border, width: .5),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/svg/delete_flow_$icon.svg',
              width: 16,
              height: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMediumStrong.copyWith(
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: DeleteFlowStyle.body,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
