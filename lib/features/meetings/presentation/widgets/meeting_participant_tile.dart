import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../domain/models/meeting_participant.dart';

class MeetingParticipantTile extends StatelessWidget {
  const MeetingParticipantTile({
    super.key,
    required this.participant,
    this.role,
    this.onMessage,
  });

  final MeetingParticipant participant;
  final String? role;
  final VoidCallback? onMessage;

  void _onMessageTap(BuildContext context) {
    if (onMessage != null) {
      onMessage!();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Messaging coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.xlAll,
      ),
      child: Row(
        children: [
          AppAvatar(
            imageUrl: participant.avatarUrl,
            name: participant.name,
            size: AppAvatarSize.md,
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
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (role != null && role!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    role!,
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
          Semantics(
            button: true,
            label: 'Message ${participant.name}',
            child: InkWell(
              onTap: () => _onMessageTap(context),
              borderRadius: AppRadii.mdAll,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMid,
                  borderRadius: AppRadii.mdAll,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}