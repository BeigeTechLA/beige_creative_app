import 'package:beige_creative_app/app/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../app/colors.dart';
import '../app/text_styles.dart';
import '../app/spacing.dart';
import '../app/radii.dart';
import '../app/shadows.dart';
class ViewDetailsScreen extends StatefulWidget {
  const ViewDetailsScreen({super.key});

  @override
  State<ViewDetailsScreen> createState() => _ViewDetailsScreenState();
}

class _ViewDetailsScreenState extends State<ViewDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
        
                /// 🔹 BACKGROUND HEADER
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: AppRadii.bottomHeader,
                    child: Image.asset(
                      AppAssets.rectangle,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
        
                /// 🔹 BACK BUTTON
                Positioned(
                  top: 90,
                  left: AppSpacing.base,
                  child:  InkWell(
                    onTap: () => Navigator.pop(context),

                    child: SvgPicture.asset(
                      AppAssets.back, // change extension
                      height: 24,
                    ),
                  ),
                ),
                /// 🔹 TITLE (CENTERED)
                const Positioned(
                  top:90 ,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "Shoot Details",
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ),
        
                /// 🔹 PROFILE IMAGE (CUT INTO CURVE)
                Positioned(
                  bottom: -48,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Stack(
                      children: [
        
                        /// 🔵 Main Circle
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xxs),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary, // gold light
                                AppColors.circleGradientBottom, // dark
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.onPrimary, // inside dark
                            ),
                            child: const Center(
                              child: Text(
                                "L#1",
                                style: AppTextStyles.displayMedium,
                              ),
                            ),
                          ),
                        ),
        
                      /*  /// ✏ Edit Icon
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: AppColors.black,
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ),
              ],
            ),
        
            const SizedBox(height: AppSpacing.bottomNavHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("Lana #123456",
                  style: AppTextStyles.body20Medium,
                )
              ],
            ),
        
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s30),
              child: Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
            ),
        
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: AppRadii.hugeAll,
              ),
              child: const Text(
                "Post Production",
                style: AppTextStyles.bodyCompactMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(
              color: AppColors.dividerDark,
              thickness: 0.8,
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadii.massiveAll,
                border: Border.all(color: AppColors.dividerDark),
                boxShadow: AppShadows.viewerSheet,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
        
                  /// 🔥 TITLE
                  Container(
        
                    child: const Text(
                      "Shoot Details",
                      style: AppTextStyles.body15Strong,
                    ),
                  ),
        
                  const SizedBox(height: AppSpacing.lg),
        
                  _buildDetailRow("Shoot Date", "Jan 16, 2026"),
                  _buildDetailRow("Time", "11:30 PM · 11 Hours"),
                  _buildDetailRow("Total Value", "\$14,400"),
                  _buildDetailRow("Payment Status", "Paid", isGreen: true),
                  _buildDetailRow("Folder Link", "http://fijejpfkmdjfief", isLink: true),
                  _buildDetailRow("Shoot Files", "200 Images & 50 Videos"),
                  _buildDetailRow("Location", "1234 Mockingbird Lane, CA 90000"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget _buildDetailRow(
      String title,
      String value, {
        bool isGreen = false,
        bool isLink = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.mld),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Left Title
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: AppTextStyles.bodyCompact,
            ),
          ),

          const Text(
            ":  ",
            style: AppTextStyles.systemDefault,
          ),

          /// Right Value
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.system13.copyWith(
                color: isGreen
                    ? AppColors.greenAccent
                    : isLink
                    ? AppColors.borderGold
                    : AppColors.white,
                fontWeight: FontWeight.w500,
                decoration:
                isLink ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }}
