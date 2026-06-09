import 'package:flutter/material.dart';

import '../../../../../app/colors.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';
import '../../../../../shared/widgets/app_avatar.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({
    super.key,
    required this.contactName,
    this.avatarUrl,
    this.isOnline = false,
    this.isTyping = false,
    this.onBack,
    this.onVideoCall,
    this.onOpenDetails,
  });

  final String contactName;
  final String? avatarUrl;
  final bool isOnline;
  final bool isTyping;
  final VoidCallback? onBack;
  final VoidCallback? onVideoCall;
  final VoidCallback? onOpenDetails;

  static const double _height = 64;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final subtitle = isTyping
        ? 'typing...'
        : (isOnline ? 'Active now' : 'Offline');

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
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
            AppAvatar(
              name: contactName,
              imageUrl: avatarUrl,
              size: AppAvatarSize.sm,
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
                  Text(
                    subtitle,
                    style: AppTextStyles.body12.copyWith(
                      color: isOnline || isTyping
                          ? AppColors.online
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Video call',
              onPressed: onVideoCall,
              icon: const Icon(
                Icons.videocam_outlined,
                color: AppColors.textPrimary,
              ),
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
