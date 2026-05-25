import 'package:beige_creative_app/app/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../app/route_names.dart';
import '../app/colors.dart';
import '../app/text_styles.dart';
import '../app/spacing.dart';
import '../app/radii.dart';

class PostProductionScreen extends StatefulWidget {
  const PostProductionScreen({super.key});

  @override
  State<PostProductionScreen> createState() => _PostProductionScreenState();
}

class _PostProductionScreenState extends State<PostProductionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            /// 🔝 HEADER
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    child: SvgPicture.asset(AppAssets.back),
                  ),
                  const Spacer(),
                  const Text(
                    "Lana #123456",
                    style: AppTextStyles.displayLabel16,
                  ),
                  const Spacer(),
                ],
              ),
            ),

            AppSpacing.verticalBase,

            /// 🔍 SEARCH
            Padding(
              padding: AppSpacing.insetsHBase,
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mld),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMid,
                  borderRadius: AppRadii.lgAll,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: AppColors.white54),
                    AppSpacing.gapHSmd,
                    Expanded(
                      child: TextField(
                        style: AppTextStyles.systemDefault,
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: AppTextStyles.systemDefault,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            AppSpacing.verticalBase,

            /// 📄 LIST
            Expanded(
              child: ListView.builder(
                padding: AppSpacing.insetsHBase,
                itemCount: 20,
                itemBuilder: (context, index) {
                  return InkWell(
                    borderRadius: AppRadii.portfolioCompactAll,
                    onTap: () {
                      context.pushNamed(RouteNames.preProduction);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.mld),
                      padding: const EdgeInsets.all(AppSpacing.s22),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMid,
                        borderRadius: AppRadii.portfolioCompactAll,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.folder, color: AppColors.primary),
                              AppSpacing.gapHSm,
                              Text(
                                "Lana #123456",
                                style: AppTextStyles.bodyCompactStrong,
                              ),
                              Spacer(),
                              Icon(Icons.more_vert, color: AppColors.white),
                            ],
                          ),

                          AppSpacing.verticalSm,

                          const Text(
                            "02 Files",
                            style: AppTextStyles.bodySmall,
                          ),

                          AppSpacing.verticalSm,

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.smd,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.circleGradientTop,
                              borderRadius: AppRadii.hugeAll,
                            ),
                            child: const Text(
                              "Corporate Event",
                              style: AppTextStyles.bodySmall,
                            ),
                          ),

                          const Divider(
                            color: AppColors.dividerDark,
                            thickness: 0.8,
                          ),

                          const Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.softLightBlue,
                                child: Text(
                                  "DP",
                                  style: AppTextStyles.systemDefault,
                                ),
                              ),
                              AppSpacing.gapHSmd,
                              Text(
                                "Opened 2 hours ago",
                                style: AppTextStyles.system14,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
