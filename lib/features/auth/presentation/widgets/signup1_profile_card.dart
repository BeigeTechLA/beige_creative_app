import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart';

class SignUp1ProfileCard extends StatelessWidget {
  final File? profileImage;
  final VoidCallback onPickImage;

  const SignUp1ProfileCard({
    super.key,
    required this.profileImage,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        borderRadius: AppRadii.xxlAll,
        border: Border.all(color: AppColors.white60, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Profile Picture",
            style: AppTextStyles.bodyLargeMedium.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Add photo to build connection and trust",
            style: AppTextStyles.body12.copyWith(color: AppColors.white30),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.surfaceMid,
                backgroundImage: profileImage != null
                    ? FileImage(profileImage!)
                    : const AssetImage(AppAssets.imageProfilePlaceholder)
                        as ImageProvider,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: InkWell(
                  onTap: onPickImage,
                  borderRadius: AppRadii.roundAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                      horizontal: AppSpacing.smd,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadii.roundAll,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          profileImage == null
                              ? Icons.camera_alt_outlined
                              : Icons.refresh,
                          size: 18,
                          color: AppColors.black,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          profileImage == null
                              ? "Upload Profile Picture"
                              : "ReUpload Profile Picture",
                          style: AppTextStyles.bodySmallMedium.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
