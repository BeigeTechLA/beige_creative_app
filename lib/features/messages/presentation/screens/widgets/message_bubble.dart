import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../app/colors.dart';
import '../../../../../app/radii.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';
import '../../../../../shared/widgets/app_avatar.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/role_label.dart';

const double _avatarDiameter = 24;
const double _bubbleRadius = 16;

/// Text or system message bubble. Audio + image variants live in
/// `audio_bubble.dart` (M3.03) and the future media bubble.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.showSenderHeader,
    this.senderRole,
    this.senderName,
  });

  final Message message;
  final bool isMine;
  final bool showSenderHeader;
  final String? senderRole;
  /// Resolved from chat-details `participants.items` via id match. Falls back
  /// to `message.senderName` when null/empty.
  final String? senderName;

  String get _displayName {
    if (senderName != null && senderName!.isNotEmpty) return senderName!;
    if (message.senderName.isNotEmpty) return message.senderName;
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.system) {
      return _SystemNotice(text: message.body ?? '');
    }
    final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.72;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMine) ...[
            if (showSenderHeader)
              AppAvatar(
                name: _displayName,
                size: AppAvatarSize.xs,
              )
            else
              const SizedBox(width: _avatarDiameter),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isMine && showSenderHeader) ...[
                  _SenderHeader(name: _displayName, role: senderRole),
                  const SizedBox(height: AppSpacing.xxs),
                ],
                Semantics(
                  label: _semanticLabel(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                    child: _Bubble(message: message, isMine: isMine),
                  ),
                ),
                if (message.reactions.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  _ReactionsRow(reactions: message.reactions),
                ],
                const SizedBox(height: AppSpacing.xxs),
                _BubbleMeta(message: message, isMine: isMine),
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
    final sender = isMine ? 'You' : _displayName;
    return '$sender: $body';
  }
}

class _SenderHeader extends StatelessWidget {
  const _SenderHeader({required this.name, this.role});

  final String name;
  final String? role;

  @override
  Widget build(BuildContext context) {
    final formattedRole = roleLabel(role);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          name,
          style: AppTextStyles.bodySmallStrong.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        if (formattedRole.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            formattedRole,
            style: AppTextStyles.body10.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.isMine});

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final bg = isMine ? AppColors.primary : AppColors.surfaceMid;
    final fg = isMine ? AppColors.onPrimary : AppColors.textPrimary;

    if (message.isDeleted) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smd,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isMine ? _bubbleRadius : 0),
            topRight: Radius.circular(isMine ? 0 : _bubbleRadius),
            bottomLeft: const Radius.circular(_bubbleRadius),
            bottomRight: const Radius.circular(_bubbleRadius),
          ),
        ),
        child: Text(
          'This message was deleted',
          style: AppTextStyles.body14.copyWith(
            color: fg.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    if (message.type == MessageType.image && message.file != null) {
      return _ImageContent(file: message.file!);
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isMine ? _bubbleRadius : 0),
          topRight: Radius.circular(isMine ? 0 : _bubbleRadius),
          bottomLeft: const Radius.circular(_bubbleRadius),
          bottomRight: const Radius.circular(_bubbleRadius),
        ),
      ),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.replyTo != null) ...[
              _ReplyPreview(preview: message.replyTo!, isMine: isMine),
              const SizedBox(height: AppSpacing.xs),
            ],
            Text(
              message.body ?? '',
              style: AppTextStyles.body14.copyWith(color: fg),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quoted-message strip rendered above the bubble body when the current
/// message is a reply. Author name + one-line body preview; image/file
/// replies get a type-appropriate placeholder label.
class _ReplyPreview extends StatelessWidget {
  const _ReplyPreview({required this.preview, required this.isMine});

  final MessageReplyPreview preview;
  final bool isMine;

  String get _previewText {
    final body = preview.body?.trim();
    if (body != null && body.isNotEmpty) return body;
    switch (preview.type) {
      case MessageType.image:
        return 'Photo';
      case MessageType.file:
        return preview.fileName ?? 'Attachment';
      case MessageType.system:
      case MessageType.text:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = isMine
        ? AppColors.onPrimary.withValues(alpha: 0.85)
        : AppColors.primary;
    final bg = isMine
        ? AppColors.onPrimary.withValues(alpha: 0.12)
        : AppColors.surfaceMid.withValues(alpha: 0.55);
    final nameColor = isMine ? AppColors.onPrimary : AppColors.textPrimary;
    final bodyColor = isMine
        ? AppColors.onPrimary.withValues(alpha: 0.8)
        : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            preview.senderName.isNotEmpty ? preview.senderName : 'Message',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmallStrong.copyWith(color: nameColor),
          ),
          const SizedBox(height: 2),
          Text(
            _previewText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body12.copyWith(color: bodyColor),
          ),
        ],
      ),
    );
  }
}

/// Compact reaction strip below the bubble body — one pill per unique emoji
/// with a small count when >1 reactor.
class _ReactionsRow extends StatelessWidget {
  const _ReactionsRow({required this.reactions});

  final Map<String, Set<String>> reactions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xxs,
      runSpacing: AppSpacing.xxs,
      children: [
        for (final entry in reactions.entries)
          if (entry.value.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceMid,
                borderRadius: BorderRadius.circular(AppRadii.pillSm),
                border: Border.all(
                  color: AppColors.dividerDark,
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(entry.key, style: const TextStyle(fontSize: 12)),
                  if (entry.value.length > 1) ...[
                    const SizedBox(width: 2),
                    Text(
                      '${entry.value.length}',
                      style: AppTextStyles.body10.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
      ],
    );
  }
}

class _BubbleMeta extends StatelessWidget {
  const _BubbleMeta({required this.message, required this.isMine});

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.textTertiary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.isEdited) ...[
          Text(
            'edited',
            style: AppTextStyles.body10.copyWith(color: color),
          ),
          const SizedBox(width: AppSpacing.xxs),
        ],
        Text(
          DateFormat('hh:mm a').format(message.sentAt),
          style: AppTextStyles.body10.copyWith(color: color),
        ),
        if (isMine) ...[
          const SizedBox(width: AppSpacing.xxs),
          _StatusIcon(status: message.deliveryStatus, color: color),
        ],
      ],
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
    final tint = status == DeliveryStatus.read ? AppColors.info : color;
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

/// Image message bubble content — full-bleed cached image with rounded
/// corners. Falls back to file-system path when the URL is a local optimistic
/// preview, otherwise streams via `CachedNetworkImage`.
class _ImageContent extends StatelessWidget {
  const _ImageContent({required this.file});

  final MessageFile file;

  bool get _isLocal => !file.url.startsWith('http');

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.mdAll,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220, minWidth: 160),
        child: _isLocal
            ? Image.file(File(file.url), fit: BoxFit.cover)
            : CachedNetworkImage(
                imageUrl: file.url,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: AppColors.surfaceMid,
                  height: 160,
                ),
                errorWidget: (_, _, _) => Container(
                  color: AppColors.surfaceMid,
                  height: 160,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
      ),
    );
  }
}
