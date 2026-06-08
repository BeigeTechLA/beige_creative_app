import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart';

class SignUp3Header extends StatelessWidget {
  const SignUp3Header({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.28,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.rectangle, fit: BoxFit.fill),
          ),
          Positioned(
            top: AppSpacing.sm,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => context.pop(),
                  child: SvgPicture.asset(
                    AppAssets.back,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Text(
                  '3/3',
                  style: AppTextStyles.body14Medium
                      .copyWith(color: AppColors.white),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Social Engagement',
                  style: AppTextStyles.displayStrong16
                      .copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  'Complete your profile and connect with \ntop studios and filmmakers.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body14
                      .copyWith(color: AppColors.white30),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadii.hugeAll,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
