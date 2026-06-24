import 'package:flutter/material.dart';

import '../../app/colors.dart';

/// Custom Beige-themed toggle — rounded-rect track with a white rounded-square
/// thumb. Track switches from a flat dark grey (off) to a gold gradient (on).
///
/// Stateless wrapper around a bool — caller owns the state, mirrors the
/// Material [Switch] API (`value` + `onChanged`).
class AppToggleSwitch extends StatelessWidget {
  const AppToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 52,
    this.height = 30,
    this.thumbInset = 4,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final double width;
  final double height;
  final double thumbInset;

  static const Duration _kDuration = Duration(milliseconds: 180);

  static const LinearGradient _onGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.goldGradientCream, AppColors.goldGradientLight],
  );

  @override
  Widget build(BuildContext context) {
    final disabled = onChanged == null;
    final trackRadius = BorderRadius.circular(height / 2.2);
    final thumbSize = height - thumbInset * 2;
    final thumbRadius = BorderRadius.circular(thumbSize / 2.5);

    return Semantics(
      toggled: value,
      enabled: !disabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: disabled ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: _kDuration,
          width: width,
          height: height,
          padding: EdgeInsets.all(thumbInset),
          decoration: BoxDecoration(
            gradient: value ? _onGradient : null,
            color: value ? null : AppColors.surfaceFog,
            borderRadius: trackRadius,
          ),
          child: AnimatedAlign(
            duration: _kDuration,
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: thumbSize,
              height: thumbSize,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: thumbRadius,
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.black20,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
