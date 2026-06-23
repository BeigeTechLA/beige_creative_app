import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../app/assets.dart';
import '../../../../../app/colors.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({
    super.key,
    required this.contactName,
    required this.participantCount,
    this.isTyping = false,
    this.onBack,
    this.onSearch,
    this.onOpenDetails,
  });

  final String contactName;
  final int participantCount;
  final bool isTyping;
  final VoidCallback? onBack;
  final VoidCallback? onSearch;
  final VoidCallback? onOpenDetails;

  static const double _height = 72;
  static const double _avatarDiameter = 44;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: _height,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        color: AppColors.background,
        child: Row(
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              icon: SvgPicture.asset(
                AppAssets.back,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Container(
              width: _avatarDiameter,
              height: _avatarDiameter,
              decoration: const BoxDecoration(
                color: AppColors.surfaceWarm,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.groups_outlined,
                size: 24,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    contactName,
                    style: AppTextStyles.headingOutfitLg.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  _Subtitle(
                    participantCount: participantCount,
                    isTyping: isTyping,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Search messages',
              onPressed: onSearch,
              icon: const Icon(Icons.search, color: AppColors.textPrimary),
            ),
            IconButton(
              tooltip: 'Conversation details',
              onPressed: onOpenDetails,
              icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.participantCount, required this.isTyping});

  final int participantCount;
  final bool isTyping;

  @override
  Widget build(BuildContext context) {
    if (isTyping) {
      return Text(
        'typing...',
        style: AppTextStyles.body12.copyWith(color: AppColors.online),
      );
    }
    final label = participantCount == 1 ? 'Participant' : 'Participants';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.groups_outlined,
          size: 14,
          color: AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          '$participantCount $label',
          style: AppTextStyles.body12.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
