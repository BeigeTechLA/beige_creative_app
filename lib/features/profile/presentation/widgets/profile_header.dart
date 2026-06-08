import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../config/env.dart';

/// Header strip + circular avatar with edit pencil.
/// Pure presentation; parent owns `_profileImage` + `profileImageUrl` + tap
/// callback.
class ProfileHeader extends StatelessWidget {
  final File? localImage;
  final String profileImageUrl;
  final VoidCallback onEditTap;

  const ProfileHeader({
    super.key,
    required this.localImage,
    required this.profileImageUrl,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: double.infinity,
          height: 200,
          child: ClipRRect(
            borderRadius: AppRadii.bottomHeader,
            child: SvgPicture.asset(
              AppAssets.rectangleProfile,
              fit: BoxFit.fill,
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + AppSpacing.lg,
          left: 16,
          child: InkWell(
            onTap: () => context.pop(true),
            child: SvgPicture.asset(
              AppAssets.back,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.textHeading,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + AppSpacing.lg,
          left: 0,
          right: 0,
          child: const Center(
            child: Text(
              'My Profile',
              style: AppTextStyles.displayLabel16,
            ),
          ),
        ),
        Positioned(
          bottom: -20,
          left: 0,
          right: 0,
          child: Center(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xxs),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.border,
                    child: ClipOval(
                      child: localImage != null
                          ? Image.file(
                              localImage!,
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                            )
                          : profileImageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl:
                                      '${Env.imageUrl}$profileImageUrl',
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                )
                              : SvgPicture.asset(
                                  AppAssets.userCircle,
                                  width: 96,
                                  height: 96,
                                ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 2,
                  child: Material(
                    color: AppColors.transparent,
                    child: GestureDetector(
                      onTap: onEditTap,
                      child: Container(
                        width: 35,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.white),
                          color: AppColors.borderGold,
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          AppAssets.editCircle,
                          height: 18,
                          width: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
