import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../domain/models/fm_linked_project.dart';

/// "L#1 Corporate_Lana_#123456 — Project Code: 3926" row shown above the
/// folder contents listing when a folder carries a linked project. Falls
/// back to initials when [FmLinkedProject.thumbnailUrl] is null.
class FmProjectBadgeCard extends StatelessWidget {
  final FmLinkedProject project;

  const FmProjectBadgeCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.dividerDark),
      ),
      child: Row(
        children: [
          _Thumb(project: project),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (project.projectCode != null) ...[
                  const SizedBox(height: AppSpacing.xxxs),
                  Text.rich(
                    TextSpan(
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      children: [
                        const TextSpan(text: 'Project Code: '),
                        TextSpan(
                          text: project.projectCode,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final FmLinkedProject project;

  const _Thumb({required this.project});

  String get _labelText {
    final label = project.badgeLabel;
    if (label != null && label.isNotEmpty) return label;

    final raw = project.displayName;
    if (raw.isEmpty) return '?';
    final cleaned = raw.replaceAll(RegExp(r'[#_]'), ' ').trim();
    if (cleaned.isEmpty) return raw[0].toUpperCase();
    final parts = cleaned.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final url = project.thumbnailUrl;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: url != null ? AppColors.surfaceMid : AppColors.softLightBlue,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        image: url != null
            ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: url != null
          ? null
          : Text(
              _labelText,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
