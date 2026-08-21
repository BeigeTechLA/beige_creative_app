import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../app/assets.dart';
import '../../../../../app/colors.dart';
import '../../../../../app/radii.dart';
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
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: AppRadii.bottomHeader,
      ),
      child: Padding(
        padding: EdgeInsets.only(top: statusBarHeight),
        child: Container(
          height: _height,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
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
              Expanded(
                child: InkWell(
                  onTap: onOpenDetails,
                  borderRadius: BorderRadius.circular(_avatarDiameter),
                  child: Row(
                    children: [
                      Container(
                        width: _avatarDiameter,
                        height: _avatarDiameter,
                        decoration: const BoxDecoration(
                          color: AppColors.primary20,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          AppAssets.icGroupChat,
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
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
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
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
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Search messages',
                onPressed: onSearch,
                icon: const Icon(Icons.search, color: AppColors.textPrimary),
              ),
            ],
          ),
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
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.online),
      );
    }
    final label = participantCount == 1 ? 'Participant' : 'Participants';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          AppAssets.icGroupChat,
          width: 10,
          height: 10,
          colorFilter: const ColorFilter.mode(
            AppColors.white60,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          '$participantCount $label',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.white60,
          ),
        ),
      ],
    );
  }
}
