import 'package:flutter/material.dart';

import '../../../../../app/colors.dart';
import '../../../../../app/radii.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';
import '../../../domain/entities/message.dart';
import 'emoji_picker_sheet.dart';

/// Quick-reaction emoji strip surfaced above the action list. Matches the
/// WhatsApp long-press sheet — tap picks that emoji, the sheet dismisses,
/// and the caller emits the reaction.
const List<String> _quickReactions = ['👍', '❤️', '😂', '😮', '😢', '🎉'];

/// WhatsApp-style long-press action sheet — quick emoji row + Reply row.
class MessageActionResult {
  final _ActionType _type;
  final String? emoji;
  const MessageActionResult._(this._type, {this.emoji});

  factory MessageActionResult.reply() =>
      const MessageActionResult._(_ActionType.reply);
  factory MessageActionResult.reaction(String emoji) =>
      MessageActionResult._(_ActionType.reaction, emoji: emoji);

  bool get isReply => _type == _ActionType.reply;
  bool get isReaction => _type == _ActionType.reaction;
}

enum _ActionType { reply, reaction }

Future<MessageActionResult?> showMessageActionsSheet(
  BuildContext context, {
  required Message message,
  required bool isMine,
}) {
  return showModalBottomSheet<MessageActionResult>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: false,
    builder: (_) => _MessageActionsSheet(message: message, isMine: isMine),
  );
}

class _MessageActionsSheet extends StatelessWidget {
  const _MessageActionsSheet({required this.message, required this.isMine});

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ReactionsStrip(
              onPick: (emoji) => Navigator.of(context).pop(
                MessageActionResult.reaction(emoji),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ActionCard(
              children: [
                _ActionTile(
                  icon: Icons.reply_rounded,
                  label: 'Reply',
                  onTap: () => Navigator.of(context).pop(
                    MessageActionResult.reply(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _ReactionsStrip extends StatelessWidget {
  const _ReactionsStrip({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final emoji in _quickReactions)
            _ReactionButton(emoji: emoji, onTap: () => onPick(emoji)),
          _AddReactionButton(onPick: onPick),
        ],
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({required this.emoji, required this.onTap});

  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'React with $emoji',
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Text(emoji, style: const TextStyle(fontSize: 28)),
        ),
      ),
    );
  }
}

class _AddReactionButton extends StatelessWidget {
  const _AddReactionButton({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add custom reaction',
      child: InkResponse(
        onTap: () async {
          final selectedEmoji = await showEmojiPickerSheet(context);
          if (selectedEmoji != null) {
            onPick(selectedEmoji);
          }
        },
        radius: 24,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceInput,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.dividerDark),
            ),
            child: const Icon(
              Icons.add,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.xxl),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 22),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
