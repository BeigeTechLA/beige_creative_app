import 'dart:ui';
import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';
import 'package:flutter/material.dart';

enum TopMessageType { error, success }

class TopMessage {
  /// Default variant — red error banner. Existing call sites keep working
  /// unchanged. Pass [type] = [TopMessageType.success] for the green variant.
  static void show(
    BuildContext context,
    String message, {
    TopMessageType type = TopMessageType.error,
  }) {
    final overlay = Overlay.of(context);
    final isSuccess = type == TopMessageType.success;
    final accent = isSuccess ? AppColors.greenBright : AppColors.errorAccent;
    final surface = isSuccess
        ? AppColors.greenBright.withValues(alpha: 0.12)
        : AppColors.errorSurface;
    final icon = isSuccess ? Icons.check_circle_outline : Icons.do_not_disturb;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: Container(color: AppColors.black.withValues(alpha: 0.8)),
            ),
          ),
          Positioned(
            top: 110,
            left: 16,
            right: 16,
            child: Material(
              color: AppColors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.mld,
                ),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: AppRadii.xlAll,
                  border: Border.all(color: accent),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message,
                        style: AppTextStyles.body11.copyWith(color: accent),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => overlayEntry.remove(),
                      child: const Icon(Icons.close, color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
