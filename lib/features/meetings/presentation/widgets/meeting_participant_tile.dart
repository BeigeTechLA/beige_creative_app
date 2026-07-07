import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/util/role_label.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../domain/models/meeting_participant.dart';

class MeetingParticipantTile extends StatelessWidget {
  const MeetingParticipantTile({super.key, required this.participant});

  final MeetingParticipant participant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          AppAvatar(
            imageUrl: participant.avatarUrl,
            name: participant.name,
            size: AppAvatarSize.sm,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  participant.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (roleLabel(participant.role).isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    roleLabel(participant.role),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
