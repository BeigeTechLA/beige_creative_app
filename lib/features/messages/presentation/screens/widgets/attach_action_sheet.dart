import 'package:flutter/material.dart';

import '../../../../../app/colors.dart';
import '../../../../../app/radii.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';

enum AttachKind { camera, gallery, file, linkShoot }

Future<AttachKind?> showAttachActionSheet(BuildContext context) {
  return showModalBottomSheet<AttachKind>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: AppRadii.topHuge),
    builder: (ctx) => const _AttachActionSheet(),
  );
}

class _AttachActionSheet extends StatelessWidget {
  const _AttachActionSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.dividerDark,
                  borderRadius: AppRadii.fullAll,
                ),
              ),
            ),
            Text(
              'Attach',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Row(
              icon: Icons.camera_alt_outlined,
              label: 'Camera',
              onTap: () => Navigator.of(context).pop(AttachKind.camera),
            ),
            _Row(
              icon: Icons.photo_library_outlined,
              label: 'Photo / video',
              onTap: () => Navigator.of(context).pop(AttachKind.gallery),
            ),
            _Row(
              icon: Icons.insert_drive_file_outlined,
              label: 'File',
              onTap: () => Navigator.of(context).pop(AttachKind.file),
            ),
            _Row(
              icon: Icons.link_outlined,
              label: 'Link shoot',
              onTap: () => Navigator.of(context).pop(AttachKind.linkShoot),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceInput,
                  borderRadius: AppRadii.mldAll,
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
