import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../domain/models/fm_node.dart';
import '../util/relative_time.dart';
import 'fm_linked_badge.dart';
import 'fm_tag_chip.dart';

/// Folder row — same widget at every depth. Tap surfaces the whole card;
/// `⋮` opens the action sheet via [onMore].
class FmFolderCard extends StatelessWidget {
  final FmFolder folder;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  const FmFolderCard({
    super.key,
    required this.folder,
    this.onTap,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final tag = folder.tagLabel;
    final link = folder.linkState;
    final hasChips = (tag != null && tag.isNotEmpty) || link != null;

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadii.xxlAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.xxlAll,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    AppAssets.icFolder,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          folder.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxs),
                        Text(
                          '${folder.fileCount.toString().padLeft(2, '0')} Files',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.goldGradientLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,

                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'More actions',
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                    onPressed: onMore,
                  ),
                ],
              ),
              if (hasChips) ...[
                const SizedBox(height: AppSpacing.base),
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xs),
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    children: [
                      if (tag != null && tag.isNotEmpty) FmTagChip(label: tag),
                      FmLinkedBadge(state: link),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.base),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.dividerDark,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.md,
                ),
                child: Text(
                  formatOpenedAgo(folder.openedAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.lightGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
