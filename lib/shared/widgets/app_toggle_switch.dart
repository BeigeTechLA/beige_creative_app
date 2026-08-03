import 'package:flutter/material.dart';

import '../../app/colors.dart';

/// Custom Beige-themed toggle — rounded-rect track with a white rounded-square
/// thumb matching Figma design. Track switches from flat dark grey (off) to a
/// gold gradient (on).
///
/// Stateless wrapper around a bool — caller owns the state, mirrors the
/// Material [Switch] API (`value` + `onChanged`).
class AppToggleSwitch extends StatelessWidget {
  const AppToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 44,
    this.height = 26,
    this.thumbInset = 2.5,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final double width;
  final double height;
  final double thumbInset;

  static const Duration _kDuration = Duration(milliseconds: 180);

  static const LinearGradient _onGradient = LinearGradient(
    begin: Alignment(0.16, 0.19),
    end: Alignment(0.81, 0.83),
    colors: [AppColors.goldGradientLight, AppColors.goldGradientDark],
  );

  static const LinearGradient _offGradient = LinearGradient(
    colors: [AppColors.surfaceFog, AppColors.surfaceFog],
  );

  @override
  Widget build(BuildContext context) {
    final disabled = onChanged == null;
    final scale = height / 26.0;
    final trackRadius = BorderRadius.circular(8.13 * scale);
    final thumbRadius = BorderRadius.circular(5.69 * scale);
    final thumbSize = height - (thumbInset * 2);

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
          decoration: ShapeDecoration(
            gradient: value ? _onGradient : _offGradient,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 0.81,
                color: value ? AppColors.goldGradientLight : AppColors.transparent,
              ),
              borderRadius: trackRadius,
            ),
          ),
          child: AnimatedAlign(
            duration: _kDuration,
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: thumbSize,
              height: thumbSize,
              decoration: ShapeDecoration(
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: thumbRadius,
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x3364646F),
                    blurRadius: 23.56,
                    offset: Offset(0, 5.69),
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
