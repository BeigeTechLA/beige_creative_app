import 'package:flutter/material.dart';

import '../../../../../app/colors.dart';
import '../../../../../app/radii.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';
import '../../../domain/entities/message.dart';

/// Row shown above the composer when the user is replying to a message.
class ReplyComposerStrip extends StatelessWidget {
  const ReplyComposerStrip({
    super.key,
    required this.target,
    required this.isTargetMine,
    required this.onClose,
  });

  final Message target;
  final bool isTargetMine;
  final VoidCallback onClose;

  String get _previewText {
    if (target.body != null && target.body!.trim().isNotEmpty) {
      return target.body!.trim();
    }
    switch (target.type) {
      case MessageType.image:
        return 'Photo';
      case MessageType.file:
        return target.file?.name ?? 'Attachment';
      case MessageType.system:
      case MessageType.text:
        return '';
    }
  }

  String get _authorLabel {
    if (isTargetMine) return 'You';
    return target.senderName.isNotEmpty ? target.senderName : 'Message';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.xs,
        AppSpacing.screenH,
        AppSpacing.xxs,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceInput,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: const Border(
            left: BorderSide(color: AppColors.primary, width: 3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Replying to $_authorLabel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body12.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _previewText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body12.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Cancel reply',
              onPressed: onClose,
              iconSize: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              icon: const Icon(Icons.close, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
