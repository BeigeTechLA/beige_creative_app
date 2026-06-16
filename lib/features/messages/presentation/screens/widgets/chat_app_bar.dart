import 'package:flutter/material.dart';

import '../../../../../app/colors.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';
import '../../../../../shared/widgets/app_avatar.dart';
import '../../../domain/role_label.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({
    super.key,
    required this.contactName,
    this.avatarUrl,
    this.isOnline = false,
    this.isTyping = false,
    this.peerRole,
    this.onBack,
    this.onVideoCall,
    this.onOpenDetails,
  });

  final String contactName;
  final String? avatarUrl;
  final bool isOnline;
  final bool isTyping;
  final String? peerRole;
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          contactName,
                          style: AppTextStyles.headingOutfitLg.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (peerRole != null && peerRole!.isNotEmpty) ...[
                        const SizedBox(width: AppSpacing.xs),
                        _RoleBadge(role: peerRole!, fgColor: AppColors.primary),
                      ],
                    ],
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

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role, required this.fgColor});

  final String role;
  final Color fgColor;

  @override
  Widget build(BuildContext context) {
    final formatted = roleLabel(role);
    if (formatted.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: fgColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fgColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        formatted,
        style: AppTextStyles.body10.copyWith(
          color: fgColor.withValues(alpha: 0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
