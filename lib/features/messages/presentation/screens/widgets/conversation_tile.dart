import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../../../app/assets.dart';
import '../../../../../app/colors.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';
import '../../../../../shared/util/conversation_title.dart';
import '../../../../../shared/widgets/app_avatar.dart';
import '../../../domain/entities/conversation.dart';

const String kConversationNoMessagesPreview = 'No messages yet';

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
    final title = displayConversationTitle(conversation.title);
    final participantCount = conversation.participantIds.length;
    final rawPreview = last?.preview.trim() ?? '';
    final hasMessagePreview = rawPreview.isNotEmpty;
    final previewText = hasMessagePreview
        ? (last!.fromMe ? 'You: $rawPreview' : rawPreview)
        : kConversationNoMessagesPreview;
    final unreadLabel = hasUnread
        ? ', ${conversation.unreadCount} unread message'
              '${conversation.unreadCount == 1 ? '' : 's'}'
        : '';
    final previewLabel = ', $previewText';

    return Semantics(
      button: true,
      label:
          'Open conversation with $title'
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
                name: title,
                imageUrl: conversation.avatarUrl,
                isOnline: conversation.isOnline,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _ConversationMeta(
                          participantCount: participantCount,
                          sentAt: last?.sentAt,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            previewText,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: hasUnread && hasMessagePreview
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: AppSpacing.sm),
                          _UnreadBadge(count: conversation.unreadCount),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String formatStamp(DateTime sentAt) => _formatStamp(sentAt);

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

class _ConversationMeta extends StatelessWidget {
  const _ConversationMeta({
    required this.participantCount,
    required this.sentAt,
  });

  final int participantCount;
  final DateTime? sentAt;

  @override
  Widget build(BuildContext context) {
    final count = participantCount.toString().padLeft(2, '0');
    final stamp = sentAt == null ? null : ConversationTile.formatStamp(sentAt!);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          AppAssets.icGroupChat,
          width: 13,
          height: 13,
          colorFilter: const ColorFilter.mode(
            AppColors.textDarkGolden,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          stamp == null ? count : '$count / $stamp',
          style: AppTextStyles.caption.copyWith(color: AppColors.textDarkGolden),
        ),
      ],
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
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
