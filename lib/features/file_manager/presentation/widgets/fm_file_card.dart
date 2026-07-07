import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../domain/models/file_type.dart';
import '../../domain/models/fm_node.dart';
import '../util/relative_time.dart';
import 'fm_file_type_icon.dart';

/// File row with header (small icon + name + ⋮), large preview block
/// (icon-only per FM4 scope), and footer (opened ago).
class FmFileCard extends StatelessWidget {
  final FmFile file;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  const FmFileCard({super.key, required this.file, this.onTap, this.onMore});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadii.lgAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.lgAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FmFileTypeIcon(type: file.type, size: 28),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'More actions',
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    onPressed: onMore,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMid,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  alignment: Alignment.center,
                  child: _DocumentPreview(type: file.type),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.dividerDark,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                formatOpenedAgo(file.openedAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentPreview extends StatelessWidget {
  final FileType type;

  const _DocumentPreview({required this.type});

  @override
  Widget build(BuildContext context) {
    final info = _getInfo(type);
    return Container(
      width: 52,
      height: 70,
      decoration: BoxDecoration(
        color: info.bg,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: info.icon != null
          ? Icon(info.icon, color: info.fg, size: 28)
          : Text(
              info.label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: info.fg,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
    );
  }

  ({Color bg, Color fg, String label, IconData? icon}) _getInfo(FileType t) {
    switch (t) {
      case FileType.pdf:
        return (
          bg: const Color(0xFFF87171),
          fg: AppColors.white,
          label: 'Pdf',
          icon: null,
        );
      case FileType.doc:
        return (
          bg: const Color(0xFF60A5FA),
          fg: AppColors.white,
          label: '',
          icon: Icons.description_outlined,
        );
      case FileType.sheet:
        return (
          bg: const Color(0xFF34D399),
          fg: AppColors.white,
          label: '',
          icon: Icons.table_chart_outlined,
        );
      case FileType.image:
        return (
          bg: const Color(0xFFFBBF24),
          fg: AppColors.white,
          label: '',
          icon: Icons.image_outlined,
        );
      case FileType.video:
        return (
          bg: const Color(0xFFA78BFA),
          fg: AppColors.white,
          label: '',
          icon: Icons.play_circle_outline,
        );
      case FileType.audio:
        return (
          bg: const Color(0xFFF472B6),
          fg: AppColors.white,
          label: '',
          icon: Icons.audiotrack_outlined,
        );
      case FileType.zip:
        return (
          bg: const Color(0xFF94A3B8),
          fg: AppColors.white,
          label: 'Zip',
          icon: null,
        );
      case FileType.other:
        return (
          bg: AppColors.surfaceVariant,
          fg: AppColors.textSecondary,
          label: 'File',
          icon: null,
        );
    }
  }
}
