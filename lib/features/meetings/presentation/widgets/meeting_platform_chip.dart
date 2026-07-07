import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../domain/models/meeting_platform.dart';

/// Rounded chip identifying the meeting platform (Zoom / Google Meet /
/// Microsoft Teams). Meet uses the brand SVG; other platforms fall back to
/// Material glyphs until dedicated SVGs land.
class MeetingPlatformChip extends StatelessWidget {
  const MeetingPlatformChip({super.key, required this.platform});

  final MeetingPlatform platform;

  Widget _iconWidget() {
    switch (platform) {
      case MeetingPlatform.meet:
        return SvgPicture.asset(
          AppAssets.icGoogleMeet,
          width: 14,
          height: 14,
          fit: BoxFit.contain,
        );
      case MeetingPlatform.zoom:
        return const Icon(
          Icons.videocam_outlined,
          size: 14,
          color: AppColors.primary,
        );
      case MeetingPlatform.teams:
        return const Icon(
          Icons.groups_outlined,
          size: 14,
          color: AppColors.primary,
        );
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
          _iconWidget(),
          const SizedBox(width: AppSpacing.xs),
          Text(
            platform.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
