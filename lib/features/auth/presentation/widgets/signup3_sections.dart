import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart';
import '../../../../shared/widgets/common_file_viewer.dart';
import 'signup3_constants.dart';

class SignUp3AddTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const SignUp3AddTile({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 30,
            width: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
            ),
            child: const Icon(Icons.add, color: AppColors.black, size: 16),
          ),
          const SizedBox(width: 14),
          Text(
            title,
            style: AppTextStyles.body15.copyWith(color: AppColors.white30),
          ),
        ],
      ),
    );
  }
}

class SignUp3SavedLinkRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color backgroundColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SignUp3SavedLinkRow({
    super.key,
    required this.item,
    required this.backgroundColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final iconStr = signup3ResolveLinkIcon(
      item['icon']?.toString(),
      item['name']?.toString(),
    );
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.microInset),
      decoration: BoxDecoration(
        borderRadius: AppRadii.xxlAll,
        border: Border.all(
          color: const Color(0xE8D1AB80).withValues(alpha: 0.5),
          width: 0.5,
        ),
        color: backgroundColor,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: iconStr.endsWith('.svg')
                ? SvgPicture.asset(
                    iconStr,
                    height: 20,
                    width: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  )
                : Image.asset(
                    iconStr,
                    height: 15,
                    width: 15,
                    color: AppColors.white,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item['name'],
              style: AppTextStyles.inheritSemiBold
                  .copyWith(color: AppColors.white),
            ),
          ),
          IconButton(
            icon: SvgPicture.asset(AppAssets.pencil, width: 18, height: 18),
            onPressed: onEdit,
          ),
          IconButton(
            icon: SvgPicture.asset(AppAssets.delete, width: 18, height: 18),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class SignUp3CheckmarkBadge extends StatelessWidget {
  const SignUp3CheckmarkBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: 20,
      decoration: const BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        size: 13,
        color: AppColors.white,
      ),
    );
  }
}

class SignUp3FeaturedSection extends StatelessWidget {
  final List<List<File>> featuredProjects;
  final List<String> featuredProjectsTitles;
  final VoidCallback onAdd;
  final void Function(int projectIndex) onEdit;
  final void Function(int projectIndex) onDelete;
  final bool isUploaded;

  const SignUp3FeaturedSection({
    super.key,
    required this.featuredProjects,
    required this.featuredProjectsTitles,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    this.isUploaded = false,
  });

  @override
  Widget build(BuildContext context) {
    final showTick = isUploaded || featuredProjects.isNotEmpty;
    return Container(
      constraints: const BoxConstraints(minHeight: 220),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadii.xxlAll,
        border: Border.all(color: AppColors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Featured Work*',
                    style: AppTextStyles.bodyMediumStrong
                        .copyWith(color: AppColors.white),
                  ),
                  if (showTick) ...[
                    const SizedBox(width: 8),
                    const SignUp3CheckmarkBadge(),
                  ],
                ],
              ),
              if (featuredProjects.isNotEmpty)
                InkWell(
                  onTap: onAdd,
                  child: Row(
                    children: [
                      Container(
                        height: 28,
                        width: 28,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.goldPaleCream,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Add another',
                        style: AppTextStyles.body13
                            .copyWith(color: AppColors.white30),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (featuredProjects.isEmpty)
            GestureDetector(
              onTap: onAdd,
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  radius: AppRadii.radiusXxl,
                  color: AppColors.white24,
                  strokeWidth: 1,
                  dashPattern: const [4, 4],
                ),
                child: Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.xxlAll,
                    color: AppColors.transparent,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppAssets.upload,
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white60,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add',
                          style: AppTextStyles.inherit14
                              .copyWith(color: AppColors.white60),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (featuredProjects.isNotEmpty)
            Column(
              children:
                  featuredProjects.asMap().entries.map((entry) {
                final projectIndex = entry.key;
                final images = entry.value;
                final title = projectIndex < featuredProjectsTitles.length
                    ? featuredProjectsTitles[projectIndex]
                    : '';
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.sm,
                          right: AppSpacing.sm,
                          bottom: AppSpacing.xs,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                textAlign: TextAlign.left,
                                style: AppTextStyles.inherit14Strong
                                    .copyWith(color: AppColors.white),
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => onEdit(projectIndex),
                                  child: Container(
                                    height: 28,
                                    width: 28,
                                    decoration: BoxDecoration(
                                      color: AppColors.black
                                          .withValues(alpha: 0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 14,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => onDelete(projectIndex),
                                  child: Container(
                                    height: 28,
                                    width: 28,
                                    decoration: BoxDecoration(
                                      color: AppColors.error
                                          .withValues(alpha: 0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      size: 14,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 190,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: images.length,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          itemBuilder: (context, index) {
                            return Container(
                              width: MediaQuery.of(context).size.width *
                                  0.75,
                              margin: const EdgeInsets.only(
                                right: AppSpacing.md,
                              ),
                              child: ClipRRect(
                                borderRadius: AppRadii.xxlAll,
                                child: Image.file(
                                  images[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class SignUp3CertificatesSection extends StatelessWidget {
  final List<File> certificateFiles;
  final VoidCallback onPick;
  final void Function(int index) onDelete;
  final bool isUploaded;

  const SignUp3CertificatesSection({
    super.key,
    required this.certificateFiles,
    required this.onPick,
    required this.onDelete,
    this.isUploaded = false,
  });

  @override
  Widget build(BuildContext context) {
    final showTick = isUploaded || certificateFiles.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadii.xxlAll,
        border: Border.all(color: AppColors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Upload Certifications',
                    style: AppTextStyles.inherit14Strong
                        .copyWith(color: AppColors.white),
                  ),
                  if (showTick) ...[
                    const SizedBox(width: 8),
                    const SignUp3CheckmarkBadge(),
                  ],
                ],
              ),
              if (certificateFiles.isNotEmpty)
                InkWell(
                  onTap: onPick,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.add,
                        size: 18,
                        color: AppColors.goldPaleCream,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Add another',
                        style: AppTextStyles.bodyCompactMedium
                            .copyWith(color: AppColors.goldPaleCream),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (certificateFiles.isEmpty)
            GestureDetector(
              onTap: onPick,
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  radius: AppRadii.radiusXxl,
                  color: AppColors.white24,
                  strokeWidth: 1,
                  dashPattern: const [4, 4],
                ),
                child: Container(
                  height: 90,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.xxlAll,
                    color: AppColors.transparent,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppAssets.upload,
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white60,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Upload',
                          style: AppTextStyles.inherit14
                              .copyWith(color: AppColors.white60),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (certificateFiles.isNotEmpty)
            Column(
              children: List.generate(certificateFiles.length, (index) {
                final file = certificateFiles[index];
                final fileName = file.path.split('/').last;
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.smd),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.smd,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMid,
                    borderRadius: AppRadii.lgAll,
                    border: Border.all(color: AppColors.white24),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link, color: AppColors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.inherit
                              .copyWith(color: AppColors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_red_eye,
                          color: AppColors.white,
                        ),
                        onPressed: () => CommonFileViewer.open(
                          context: context,
                          filePath: file.path,
                          isNetwork: false,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: AppColors.white,
                        ),
                        onPressed: () => onDelete(index),
                      ),
                    ],
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}
