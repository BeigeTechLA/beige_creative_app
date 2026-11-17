import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/text_styles.dart';
import '../../domain/models/deletion_request.dart';
import '../providers/delete_account_providers.dart';

abstract final class DeleteFlowStyle {
  static const border = AppColors.darkCharcoal;
  static const filledInput = AppColors.surfaceCoal;
  static const warning = Color(0xFFF59E0B);
  static const info = AppColors.blueAccent;
  static TextStyle get body => AppTextStyles.bodyMedium.copyWith(
    color: AppColors.white60,
    height: 18 / 14,
  );
}

class DeleteFlowBack extends StatelessWidget {
  const DeleteFlowBack({super.key});
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        tooltip: 'Back',
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.zero,
        onPressed: () => context.pop(),
        icon: SvgPicture.asset(
          'assets/svg/delete_flow_back.svg',
          width: 24,
          height: 24,
        ),
      ),
    ),
  );
}

// The shared AppButton fixes its font to Outfit. This flow needs Unbounded
// and wrapping labels for accessibility, so keep its button local.
class DeleteFlowButton extends StatelessWidget {
  const DeleteFlowButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: .5),
        disabledForegroundColor: AppColors.onPrimary.withValues(alpha: .5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.titleSmall.copyWith(fontSize: 14),
      ),
      child: Text(label, textAlign: TextAlign.center),
    ),
  );
}

class DeleteFlowPreviewNotice extends StatelessWidget {
  const DeleteFlowPreviewNotice({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Text(
      'UI preview only. No email is sent and your account is unchanged.',
      textAlign: TextAlign.center,
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.white60),
    ),
  );
}

class DeletionDateText extends StatelessWidget {
  const DeletionDateText({
    super.key,
    required this.prefix,
    required this.date,
    this.suffix = '.',
  });
  final String prefix, suffix;
  final String? date;
  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      text: prefix,
      children: [
        TextSpan(
          text: date ?? 'Loading…',
          style: AppTextStyles.bodyMediumStrong.copyWith(
            color: AppColors.primary,
          ),
        ),
        TextSpan(text: suffix),
      ],
    ),
    style: DeleteFlowStyle.body,
  );
}

class DeletionFeedback extends StatelessWidget {
  const DeletionFeedback({super.key, required this.state, this.onRetry});
  final DeletionState state;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (state.busy)
        const Padding(
          padding: EdgeInsets.all(12),
          child: LinearProgressIndicator(),
        ),
      if (state.error case final String error) ...[
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(error, style: DeleteFlowStyle.body),
        ),
        if (onRetry != null)
          TextButton(
            onPressed: state.busy ? null : onRetry,
            child: const Text('Refresh request details'),
          ),
      ],
    ],
  );
}

class DeletionSuccessContent extends ConsumerWidget {
  const DeletionSuccessContent({
    super.key,
    required this.cancelled,
    this.receipt,
  });
  final bool cancelled;
  final DeletionRequest? receipt;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = receipt ?? ref.watch(deletionProvider).request;
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Lottie.asset(
            AppAssets.lottieSuccess,
            height: 206,
            fit: BoxFit.contain,
            repeat: false,
          ),
          const SizedBox(height: 8),
          Text(
            cancelled
                ? 'Account Deletion Cancelled'
                : 'Account Deletion Requested',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            cancelled
                ? 'Your account deletion request has been cancelled successfully.'
                : 'Your account deletion request has been submitted successfully.',
            textAlign: TextAlign.center,
            style: DeleteFlowStyle.body.copyWith(height: 20 / 14),
          ),
          const SizedBox(height: 10),
          if (cancelled)
            Text(
              'Your Beige account is now active. Some data that was already deleted may not be recoverable.',
              textAlign: TextAlign.center,
              style: DeleteFlowStyle.body.copyWith(height: 20 / 14),
            )
          else
            DeletionDateText(
              prefix:
                  'Your Beige account has been deactivated, and your eligible data is scheduled for deletion on ',
              date: request?.dateLabel,
            ),
          if (request?.id case final String id) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary, width: .5),
              ),
              child: Row(
                children: [
                  Text(
                    'Request ID',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      id,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.bodyMediumStrong.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (request?.confirmationEmailSent == true) ...[
            const SizedBox(height: 12),
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
                children: [
                  SvgPicture.asset(
                    'assets/svg/delete_flow_info.svg',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'A confirmation email has been sent to your registered email address.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
