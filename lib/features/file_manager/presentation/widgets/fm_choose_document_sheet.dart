import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

enum DocumentSourceType { photoVideo, file }

/// Bottom sheet to pick the source for uploads (Photos/Videos vs Files).
class FmChooseDocumentSheet extends StatelessWidget {
  const FmChooseDocumentSheet({super.key});

  static Future<DocumentSourceType?> show(BuildContext context) {
    return showModalBottomSheet<DocumentSourceType>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.topHuge),
      builder: (context) => const FmChooseDocumentSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Choose Document Source',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(color: AppColors.dividerDark, height: 1),
            ListTile(
              leading: const Icon(Icons.video_library_outlined, color: AppColors.primary),
              title: Text(
                'Choose Photos or Videos',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
              ),
              onTap: () => Navigator.pop(context, DocumentSourceType.photoVideo),
            ),
            const Divider(color: AppColors.dividerDark, height: 1),
            ListTile(
              leading: const Icon(Icons.insert_drive_file_outlined, color: AppColors.primary),
              title: Text(
                'Choose from File',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
              ),
              onTap: () => Navigator.pop(context, DocumentSourceType.file),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
