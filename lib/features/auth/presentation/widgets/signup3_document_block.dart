import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/common_file_viewer.dart';

class SignUp3DocumentBlock extends StatelessWidget {
  final String label;
  final File? file;
  final VoidCallback onUpload;
  final VoidCallback onDelete;

  const SignUp3DocumentBlock({
    super.key,
    required this.label,
    required this.file,
    required this.onUpload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final file = this.file;
    if (file == null) {
      return GestureDetector(
        onTap: onUpload,
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
                    label,
                    style: AppTextStyles.inherit14
                        .copyWith(color: AppColors.white60),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.white24),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.insert_drive_file,
            color: AppColors.white,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              file.path.split('/').last,
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
            icon: const Icon(Icons.delete, color: AppColors.white),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
