import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import 'package:beige_creative_app/shared/widgets/app_icon_tap_target.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart';

class SignUp2Header extends StatelessWidget {
  const SignUp2Header({
    super.key,
    this.currentStep = 2,
    this.totalSteps = 3,
    this.showBack = true,
  });

  /// 1-based index of this step within the flow shown to the user.
  final int currentStep;

  /// Total number of steps the user will see. Normal signup = 3; the
  /// login-resume flow starts at step 2 and shows only 2 remaining steps.
  final int totalSteps;

  /// Whether to render the back icon. Hidden on the login-resume entry step
  /// (1/2) where there is no step 1 to go back to.
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (MediaQuery.of(context).size.height * 0.28).clamp(180.0, 240.0),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showBack)
                  AppIconTapTarget(
                    semanticLabel: 'Back',
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.goNamed(Routes.signupStep1.name);
                      }
                    },
                    alignment: Alignment.topLeft,
                    icon: SvgPicture.asset(
                      AppAssets.back,
                      height: 24,
                      width: 24,
                      fit: BoxFit.fill,
                    ),
                  )
                else
                  const SizedBox(width: 24, height: 24),
                SizedBox(
                  height: 24,
                  child: Align(
                    widthFactor: 1,
                    child: Text(
                      '$currentStep/$totalSteps',
                      style: AppTextStyles.body14Medium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
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
                  style: AppTextStyles.displayStrong16.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Create your profile to get discovered by \nproduction teams.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body14.copyWith(
                    color: AppColors.white30,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    totalSteps,
                    (index) => Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: index < currentStep
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
