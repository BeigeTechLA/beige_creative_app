import 'package:flutter/material.dart';

import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/shadows.dart';
import '../../app/spacing.dart';

enum AppCardVariant { flat, outlined, elevated }

/// Canonical card surface. Wraps children in a `surface`-tinted container with
/// rounded corners + optional border / shadow + optional tap handler.
///
/// `flat` — surface only. `outlined` — surface + 1px border. `elevated` —
/// surface + `AppShadows.card`.
class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.flat,
    this.padding = const EdgeInsets.all(AppSpacing.base),
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = AppRadii.lgAll;
    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: radius,
        border: variant == AppCardVariant.outlined
            ? Border.all(color: AppColors.dividerDark)
            : null,
        boxShadow: variant == AppCardVariant.elevated ? AppShadows.card : null,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return decorated;
    return Material(
      color: AppColors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: decorated,
      ),
    );
  }
}
