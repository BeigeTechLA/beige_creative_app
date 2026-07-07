import 'package:flutter/material.dart';
import 'loading.dart';
import '../../app/assets.dart';
import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, text, destructive }

enum AppButtonSize { sm, md, lg }

/// Canonical project button. Phase 4 features consume this; no per-screen
/// button reinvention.
///
/// Variants:
/// - `primary` — gold CTA on dark surface (default).
/// - `secondary` — surface-tinted, low emphasis.
/// - `outline` — transparent fill, gold border.
/// - `text` — text-only, no fill / border.
/// - `destructive` — error-tinted (delete account, cancel shoot).
///
/// Sizes drive vertical padding + label style — never raw font sizes.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.fullWidth = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;
    final colors = _colorsFor(variant);
    final pad = _paddingFor(size);
    final textStyle = _textStyleFor(size).copyWith(color: colors.foreground);

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          AppCircularLoader(
            size: 20,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(colors.foreground),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...[
          Icon(icon, size: 18, color: colors.foreground),
          const SizedBox(width: AppSpacing.xs),
        ],
        Flexible(
          child: Text(
            label,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final button = Material(
      color: disabled
          ? colors.background.withValues(alpha: 0.5)
          : colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.mdAll,
        side: colors.borderColor != null
            ? BorderSide(color: colors.borderColor!)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: AppRadii.mdAll,
        child: Padding(padding: pad, child: child),
      ),
    );

    return fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  EdgeInsets _paddingFor(AppButtonSize s) {
    switch (s) {
      case AppButtonSize.sm:
        return EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        );
      case AppButtonSize.md:
        return EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.mld,
        );
      case AppButtonSize.lg:
        return EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.base,
        );
    }
  }

  TextStyle _textStyleFor(AppButtonSize s) {
    switch (s) {
      case AppButtonSize.sm:
        return AppTextStyles.buttonSmall;
      case AppButtonSize.md:
        return AppTextStyles.buttonMedium;
      case AppButtonSize.lg:
        return AppTextStyles.buttonLarge;
    }
  }

  _ButtonColors _colorsFor(AppButtonVariant v) {
    switch (v) {
      case AppButtonVariant.primary:
        return _ButtonColors(
          background: AppColors.primary,
          foreground: AppColors.onPrimary,
        );
      case AppButtonVariant.secondary:
        return _ButtonColors(
          background: AppColors.surface,
          foreground: AppColors.textPrimary,
        );
      case AppButtonVariant.outline:
        return _ButtonColors(
          background: AppColors.transparent,
          foreground: AppColors.primary,
          borderColor: AppColors.primary,
        );
      case AppButtonVariant.text:
        return _ButtonColors(
          background: AppColors.transparent,
          foreground: AppColors.primary,
        );
      case AppButtonVariant.destructive:
        return _ButtonColors(
          background: AppColors.error,
          foreground: AppColors.white,
        );
    }
  }
}

class _ButtonColors {
  final Color background;
  final Color foreground;
  final Color? borderColor;
  const _ButtonColors({
    required this.background,
    required this.foreground,
    this.borderColor,
  });
}
