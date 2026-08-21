import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/shadows.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';

enum AppCountCardVariant {
  classic,
  goldAccent,
  charcoalFlat,
}

class AppCountCard extends StatelessWidget {
  final String number;
  final String title;
  final String iconPath;
  final AppCountCardVariant variant;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const AppCountCard({
    super.key,
    required this.number,
    required this.title,
    required this.iconPath,
    this.variant = AppCountCardVariant.classic,
    this.onTap,
    this.width = 174,
    this.height = 74,
  });

  @override
  Widget build(BuildContext context) {
    // Determine styles based on variant
    final Decoration decoration;
    final TextStyle countStyle;
    final TextStyle titleStyle;
    final BorderRadius borderRadius;
    final bool showGlow = variant == AppCountCardVariant.classic;

    switch (variant) {
      case AppCountCardVariant.goldAccent:
        borderRadius = AppRadii.xlAll;
        decoration = BoxDecoration(
          color: AppColors.primary,
          borderRadius: borderRadius,
          boxShadow: AppShadows.cardBlack12,
        );
        countStyle = AppTextStyles.bodyMedium.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.onPrimary,
        );
        titleStyle = AppTextStyles.bodyCompactMedium.copyWith(
          height: 1.1,
          color: AppColors.textDark,
        );
        break;

      case AppCountCardVariant.charcoalFlat:
        borderRadius = AppRadii.xlAll;
        decoration = BoxDecoration(
          color: AppColors.surfaceMid,
          borderRadius: borderRadius,
          border: Border.all(color: AppColors.dividerDark, width: 0.8),
        );
        countStyle = AppTextStyles.bodyMedium.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 0.95,
          color: AppColors.white,
        );
        titleStyle = AppTextStyles.bodyCompactMedium.copyWith(
          height: 1.1,
          color: AppColors.textSecondary,
        );
        break;

      case AppCountCardVariant.classic:
        borderRadius = AppRadii.portfolioCompactAll;
        decoration = BoxDecoration(
          color: AppColors.surfaceMid,
          borderRadius: borderRadius,
          boxShadow: AppShadows.cardBlack12,
        );
        countStyle = AppTextStyles.bodyMedium.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 0.95,
          color: AppColors.primary,
        );
        titleStyle = AppTextStyles.bodyCompactMedium.copyWith(
          height: 1.1,
          color: AppColors.white,
        );
        break;
    }

    final cardContent = Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      decoration: decoration,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            if (showGlow)
              Positioned(
                bottom: -height * 0.7,
                left: 0,
                right: 0,
                height: height * 1.4,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.5,
                      colors: [
                        Color(0x24E9BE78), // #E9BE7824
                        Color(0x00E9BE78),
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 7,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          number.padLeft(2, '0'),
                          style: countStyle,
                        ),
                        SvgPicture.asset(
                          iconPath,
                          width: 24,
                          height: 24,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: titleStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) {
      return cardContent;
    }

    return GestureDetector(
      onTap: onTap,
      child: cardContent,
    );
  }
}
