import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/colors.dart';
import '../../../../app/text_styles.dart';

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
