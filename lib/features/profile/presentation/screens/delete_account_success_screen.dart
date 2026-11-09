import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../app/colors.dart';
import '../../../../app/text_styles.dart';
import 'package:lottie/lottie.dart';
import '../../../../app/assets.dart';
import '../widgets/delete_flow_widgets.dart';

/// Preview of the requested state, not evidence of a completed API operation.
/// TODO(delete-account-api): Use the server's scheduled deletion date and show
/// this screen only after verification and deletion-request submission succeed.
/// Backend contract pending: confirmation-email status, session invalidation,
/// and the final logout/redirect behavior. Preview must not log out or emit
/// account-deleted analytics.
class DeleteAccountSuccessScreen extends StatelessWidget {
  const DeleteAccountSuccessScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  AppAssets.lottieSuccess,
                  height: 206,
                  fit: BoxFit.contain,
                  repeat: false,
                ),
                const SizedBox(height: 8),
                Text(
                  'Account Deletion Requested',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your account deletion request has been submitted successfully.',
                  textAlign: TextAlign.center,
                  style: DeleteFlowStyle.body.copyWith(height: 20 / 14),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    text:
                        'Your Beige account has been deactivated, and your eligible data is scheduled for deletion on ',
                    children: [
                      TextSpan(
                        text: '[Scheduled Deletion Date]',
                        style: AppTextStyles.bodyMediumStrong.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: DeleteFlowStyle.body.copyWith(height: 20 / 14),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DeleteFlowStyle.info.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: DeleteFlowStyle.info.withValues(alpha: .2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: SvgPicture.asset(
                          'assets/svg/delete_flow_info.svg',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'A confirmation email has been sent to your registered email address.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white,
                            height: 20 / 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const DeleteFlowPreviewNotice(),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
