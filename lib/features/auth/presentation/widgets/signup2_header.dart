import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart';

class SignUp2Header extends StatelessWidget {
  const SignUp2Header({super.key});

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
            top: 50,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => context.pop(),
                  child: SvgPicture.asset(AppAssets.back, fit: BoxFit.fill),
                ),
                Text(
                  '2/3',
                  style: AppTextStyles.body14Medium.copyWith(
                    color: AppColors.white,
                  ),
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
                  'Professional Details',
                  style: AppTextStyles.displayStrong16
                      .copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  'Create your profile to get discovered by \nproduction teams.',
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
                        color: index <= 1
                            ? AppColors.primary
                            : AppColors.textSubtle,
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
