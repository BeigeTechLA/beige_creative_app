import 'package:flutter/material.dart';

/// Icon-only action wrapper with a mobile-safe 44x44 minimum hit target.
class AppIconTapTarget extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final double minSize;
  final BorderRadius? borderRadius;
  final AlignmentGeometry alignment;

  const AppIconTapTarget({
    super.key,
    required this.icon,
    required this.onTap,
    this.semanticLabel,
    this.minSize = 44,
    this.borderRadius,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(minSize / 2),
          child: SizedBox(
            width: minSize,
            height: minSize,
            child: Align(alignment: alignment, child: icon),
          ),
        ),
      ),
    );
  }
}
