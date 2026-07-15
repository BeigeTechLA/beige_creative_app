import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../domain/models/fm_node.dart';

/// Actions surfaced from the `⋮` menu on a folder or file. Same 4 items
/// for both — files use `POST /file-download-url`, folders use
/// `POST /folder-download-url` (server-generated ZIP).
enum FmNodeAction { open, share, download, delete }

Future<FmNodeAction?> showFmActionsSheet(
  BuildContext context, {
  required FmNodeKind kind,
}) {
  return showModalBottomSheet<FmNodeAction>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: AppRadii.topHuge),
    builder: (ctx) => _Sheet(kind: kind),
  );
}

class _Sheet extends StatelessWidget {
  final FmNodeKind kind;
  const _Sheet({required this.kind});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Row(
              icon: Icons.folder_open_outlined,
              label: 'Open',
              onTap: () => Navigator.of(context).pop(FmNodeAction.open),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.dividerDark),
            _Row(
              icon: Icons.share_outlined,
              label: 'Share',
              onTap: () => Navigator.of(context).pop(FmNodeAction.share),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.dividerDark),
            _Row(
              icon: Icons.file_download_outlined,
              label: 'Download',
              onTap: () => Navigator.of(context).pop(FmNodeAction.download),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.dividerDark),
            _Row(
              icon: Icons.delete_outline,
              label: 'Delete',
              destructive: true,
              onTap: () => Navigator.of(context).pop(FmNodeAction.delete),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _Row({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: AppSpacing.base),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
