import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../app/colors.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';
import '../../../../../shared/widgets/app_avatar.dart';
import '../../../domain/entities/message.dart';

/// Text or system message bubble. Audio + image variants live in
/// `audio_bubble.dart` (M3.03) and the future media bubble.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.showSenderHeader,
  });

  final Message message;
  final bool isMine;
  final bool showSenderHeader;

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.system) {
      return _SystemNotice(text: message.body ?? '');
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMine) ...[
            AppAvatar(name: message.senderName, size: AppAvatarSize.xs),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (showSenderHeader && !isMine)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                    child: Text(
                      message.senderName,
                      style: AppTextStyles.bodySmallMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                Semantics(
                  label: _semanticLabel(),
                  child: _Bubble(message: message, isMine: isMine),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _semanticLabel() {
    final body = message.isDeleted
        ? 'This message was deleted'
        : (message.body ?? 'Attachment message');
    final sender = isMine ? 'You' : message.senderName;
    return '$sender: $body';
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.isMine});

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final bg = isMine ? AppColors.primary : AppColors.surfaceCharcoal;
    final fg = isMine ? AppColors.textDark : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isMine ? 20 : 4),
          bottomRight: Radius.circular(isMine ? 4 : 20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (message.isDeleted)
            Text(
              'This message was deleted',
              style: AppTextStyles.body14.copyWith(
                color: fg.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            )
          else if (message.body != null && message.body!.isNotEmpty)
            Text(
              message.body!,
              style: AppTextStyles.body14.copyWith(color: fg),
            ),
          const SizedBox(height: AppSpacing.xxs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.isEdited) ...[
                Text(
                  'edited',
                  style: AppTextStyles.body10.copyWith(
                    color: fg.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: AppSpacing.xxs),
              ],
              Text(
                DateFormat('hh:mm a').format(message.sentAt),
                style: AppTextStyles.body10.copyWith(
                  color: fg.withValues(alpha: 0.6),
                ),
              ),
              if (isMine) ...[
                const SizedBox(width: AppSpacing.xxs),
                _StatusIcon(status: message.deliveryStatus, color: fg),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status, required this.color});

  final DeliveryStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (status) {
      case DeliveryStatus.sending:
        icon = Icons.schedule;
      case DeliveryStatus.failed:
        icon = Icons.error_outline;
      case DeliveryStatus.sent:
        icon = Icons.check;
      case DeliveryStatus.delivered:
        icon = Icons.done_all;
      case DeliveryStatus.read:
        icon = Icons.done_all;
    }
    final tint = status == DeliveryStatus.read
        ? AppColors.info
        : color.withValues(alpha: 0.6);
    return ExcludeSemantics(child: Icon(icon, size: 12, color: tint));
  }
}

class _SystemNotice extends StatelessWidget {
  const _SystemNotice({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: AppSpacing.sm,
      ),
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.body12.copyWith(color: AppColors.textTertiary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
