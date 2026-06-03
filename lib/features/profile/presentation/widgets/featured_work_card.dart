import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../config/env.dart';

/// Single grouped-by-title featured-work card with edit / delete / arrow CTAs.
///
/// Pure presentation — no state, no API calls. Parent holds `setState` + API
/// methods and passes callbacks. Lifted verbatim from
/// `lib/profile/featured_work_list.dart` (lines ~360-562) during 4.08 split.
class FeaturedWorkCard extends StatelessWidget {
  final String title;
  final List<dynamic> images;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const FeaturedWorkCard({
    super.key,
    required this.title,
    required this.images,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 250,
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceShadow,
              borderRadius: AppRadii.hugeAll,
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: AppRadii.xxxlAll,
                  child: CachedNetworkImage(
                    imageUrl: '${Env.imageUrl}${images.first.filePath}',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) {
                      return Container(
                        color: AppColors.border,
                        child: const Center(
                          child: Icon(Icons.image, color: AppColors.white),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: AppColors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: GestureDetector(
                          onTap: onDelete,
                          child: const Icon(
                            Icons.delete,
                            color: AppColors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 15,
                  bottom: 15,
                  right: 15,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.headingOutfitLg.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: onTap,
                            child: SvgPicture.asset(
                              AppAssets.circleArrow,
                              height: 30,
                              width: 30,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
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
