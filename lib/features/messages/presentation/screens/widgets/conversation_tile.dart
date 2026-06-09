import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../app/colors.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';
import '../../../../../shared/widgets/app_avatar.dart';
import '../../../domain/entities/conversation.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final last = conversation.lastMessage;
    final hasUnread = conversation.unreadCount > 0;
    final unreadLabel = hasUnread
        ? ', ${conversation.unreadCount} unread message'
              '${conversation.unreadCount == 1 ? '' : 's'}'
        : '';
    final previewLabel = last == null ? '' : ', ${last.preview}';

    return Semantics(
      button: true,
      label:
          'Open conversation with ${conversation.title}'
          '$previewLabel$unreadLabel',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenH,
            vertical: AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AvatarWithPresence(
                name: conversation.title,
                imageUrl: conversation.avatarUrl,
                isOnline: conversation.isOnline,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      conversation.title,
                      style: AppTextStyles.bodyLargeStrong.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    if (last != null)
                      Text(
                        last.preview,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: hasUnread
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (last != null)
                    Text(
                      _formatStamp(last.sentAt),
                      style: AppTextStyles.body11.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xs),
                  if (hasUnread)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatStamp(DateTime sentAt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sentDay = DateTime(sentAt.year, sentAt.month, sentAt.day);
    final diff = today.difference(sentDay).inDays;
    if (diff == 0) return DateFormat('hh:mm a').format(sentAt);
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(sentAt);
    return DateFormat('dd MMM').format(sentAt);
  }
}

class _AvatarWithPresence extends StatelessWidget {
  const _AvatarWithPresence({
    required this.name,
    required this.imageUrl,
    required this.isOnline,
  });

  final String name;
  final String? imageUrl;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppAvatar(name: name, imageUrl: imageUrl, size: AppAvatarSize.md),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.online,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
