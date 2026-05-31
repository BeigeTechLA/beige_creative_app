import 'dart:io';

import 'package:flutter/material.dart';

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
        child: Container(
          height: 110,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: AppRadii.lgAll,
            border: Border.all(
              color: AppColors.white24,
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.upload, color: AppColors.white24),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.inherit14
                      .copyWith(color: AppColors.white24),
                ),
              ],
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
