import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../app/assets.dart';
import '../../app/colors.dart';

/// Inline Material spinner. Drop-in replacement for
/// `CircularProgressIndicator` across the app so every raw usage funnels
/// through one widget.
///
/// - [size] optionally wraps the indicator in a [SizedBox] to force a
///   square dimension. Omit for the framework's intrinsic size.
/// - [color] / [valueColor] / [strokeWidth] pass through unchanged, so
///   existing call sites keep their exact rendering.
class AppCircularLoader extends StatelessWidget {
  const AppCircularLoader({
    super.key,
    this.size,
    this.color,
    this.strokeWidth,
    this.valueColor,
  });

  final double? size;
  final Color? color;
  final double? strokeWidth;
  final Animation<Color?>? valueColor;

  @override
  Widget build(BuildContext context) {
    final indicator = CircularProgressIndicator(
      color: color,
      strokeWidth: strokeWidth ?? 4.0,
      valueColor: valueColor,
    );
    if (size == null) return indicator;
    return SizedBox(
      height: size,
      width: size,
      child: indicator,
    );
  }
}

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: AppColors.background,
        child: Center(
          child: Lottie.asset(
            AppAssets.lottieCircleLoader,
            height: 70,
            width: 70,
          ),
        ),
      ),
    );
  }
}

/// Bare centered Lottie loader for screen-body / sheet-body / list-empty
/// loading states. No background paint — parent controls surface. Default
/// 70px matches [AppLoader] and [AppLoadingOverlay] for consistent visual
/// language.
class AppScreenLoader extends StatelessWidget {
  const AppScreenLoader({super.key, this.size = 70});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        AppAssets.lottieCircleLoader,
        height: size,
        width: size,
      ),
    );
  }
}

/// Lottie success animation used across success/confirmation screens.
/// `repeat: false` so it plays once and holds the final frame.
class AppSuccessAnimation extends StatelessWidget {
  const AppSuccessAnimation({
    super.key,
    this.height,
    this.fit,
    this.repeat = false,
  });

  final double? height;
  final BoxFit? fit;
  final bool repeat;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      AppAssets.lottieSuccess,
      height: height,
      fit: fit,
      repeat: repeat,
    );
  }
}

/// Lottie spinner sized for CachedNetworkImage placeholders / avatar
/// loading states. Centers the animation inside its parent.
class AppImageLoader extends StatelessWidget {
  const AppImageLoader({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        AppAssets.lottieCircleLoader,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    this.size = 70,
    this.dimOpacity = 0.5,
    this.asset = AppAssets.lottieCircleLoader,
  });

  final double size;
  final double dimOpacity;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: AppColors.black.withAlpha((dimOpacity * 255).round()),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Center(
              child: Lottie.asset(
                asset,
                height: size,
                width: size,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
