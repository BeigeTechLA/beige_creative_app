import 'package:flutter/material.dart';
import 'loading.dart';
import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/text_styles.dart';

/// A standard, full-width CTA button used across the application.
/// Uses the 'Unbounded' font family with font weight w500 and size 14.
class AppCtaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool? visuallyEnabled;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isLoading;

  const AppCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.visuallyEnabled,
    this.height,
    this.borderRadius,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // A button is disabled if `enabled` is false, `onPressed` is null, or it is currently loading.
    final bool isButtonDisabled = !enabled || onPressed == null || isLoading;

    // Use visuallyEnabled if explicitly provided, otherwise default to the active/disabled state.
    final bool showActiveColors = visuallyEnabled ?? !isButtonDisabled;

    final Color backgroundColor = showActiveColors 
        ? AppColors.primary 
        : AppColors.borderGold;
    
    final Color textColor = showActiveColors 
        ? AppColors.textHeading 
        : AppColors.surfaceMid;

    final TextStyle textStyle = AppTextStyles.displayLabel14.copyWith(
      color: textColor,
    );

    return SizedBox(
      width: double.infinity,
      height: height ?? 55, // Defaults to 55px
      child: ElevatedButton(
        onPressed: isButtonDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: AppColors.borderGold,
          foregroundColor: textColor,
          disabledForegroundColor: AppColors.surfaceMid,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? AppRadii.xlAll,
          ),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? AppCircularLoader(
                size: 22,
                strokeWidth: 2,
                color: showActiveColors ? AppColors.black : AppColors.surfaceMid,
              )
            : Text(
                label,
                style: textStyle,
              ),
      ),
    );
  }
}
