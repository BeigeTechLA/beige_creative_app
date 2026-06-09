import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
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
            child: Text(
              participant.name,
              style: AppTextStyles.body14.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
