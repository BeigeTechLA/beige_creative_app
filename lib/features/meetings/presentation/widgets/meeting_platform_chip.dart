import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../domain/models/meeting_platform.dart';

/// Rounded chip identifying the meeting platform (Zoom / Google Meet /
/// Microsoft Teams). Material icon fallbacks are used until brand SVGs
/// land in `lib/assets/`.
class MeetingPlatformChip extends StatelessWidget {
  const MeetingPlatformChip({super.key, required this.platform});

  final MeetingPlatform platform;

  IconData get _icon {
    switch (platform) {
      case MeetingPlatform.zoom:
        return Icons.videocam_outlined;
      case MeetingPlatform.meet:
        return Icons.duo_outlined;
      case MeetingPlatform.teams:
        return Icons.groups_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.chipPaddingH,
        vertical: AppSpacing.chipPaddingV,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: AppRadii.smAll,
        border: Border.all(color: AppColors.dividerDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            platform.label,
            style: AppTextStyles.body11.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
