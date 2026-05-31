import 'dart:ui';
import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';
import 'package:flutter/material.dart';

class TopMessage {
  static void show(BuildContext context, String message) {
    final overlay = Overlay.of(context);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          /// 🔹 BLUR BACKGROUND
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 1, //
                sigmaY: 1,
              ),
              child: Container(color: AppColors.black.withValues(alpha: 0.8)),
            ),
          ),

          /// 🔹 TOP MESSAGE
          Positioned(
            top: 110, // 🔥 thoda niche
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
                  color: AppColors.errorSurface,
                  borderRadius: AppRadii.xlAll,
                  border: Border.all(color: AppColors.errorAccent),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.do_not_disturb,
                      color: AppColors.errorAccent,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        message,
                        style: AppTextStyles.body11.copyWith(
                          color: AppColors.errorAccent,
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        overlayEntry.remove();
                      },
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
