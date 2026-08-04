import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../config/env.dart';
import '../../../profile/presentation/providers/my_profile_providers.dart'
    show profileImageBustProvider;

/// Top welcome banner — drawer menu icon, welcome copy, bell, and avatar.
/// Pure presentation. Orchestrator owns the profile + tap callback.
class HomeWelcomeHeader extends ConsumerWidget {
  static const double _actionSize = 44;
  static const double _actionIconSize = 24;
  static const double _avatarRadius = 22;

  final String? firstName;
  final String subtitle;
  final String profileImageUrl;
  final VoidCallback onAvatarTap;
  final VoidCallback? onNotificationTap;

  const HomeWelcomeHeader({
    super.key,
    required this.firstName,
    this.subtitle = 'Creative Pro',
    required this.profileImageUrl,
    required this.onAvatarTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = firstName?.trim();
    final displayName = name == null || name.isEmpty ? 'User..' : name;
    final subtitleText = subtitle.trim();
    final bust = ref.watch(profileImageBustProvider);
    final avatarUrl = profileImageUrl.isEmpty
        ? ''
        : '${Env.imageUrl}$profileImageUrl${bust > 0 ? '?v=$bust' : ''}';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: AppRadii.bottomPillSm,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.md,
            AppSpacing.xxl,
            AppSpacing.xxl,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Builder(
                builder: (context) => IconButton(
                  tooltip: 'Open menu',
                  onPressed: Scaffold.of(context).openDrawer,
                  constraints: const BoxConstraints.tightFor(
                    width: _actionSize,
                    height: _actionSize,
                  ),
                  padding: EdgeInsets.zero,
                  icon: SvgPicture.asset(
                    AppAssets.menu,
                    width: _actionIconSize,
                    height: _actionIconSize,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              AppSpacing.gapHMd,
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back, $displayName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLargeStrong.copyWith(
                        color: AppColors.white,
                        height: 1.2,
                      ),
                    ),
                    if (subtitleText.isNotEmpty) ...[
                      AppSpacing.verticalXxs,
                      Text(
                        subtitleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body14.copyWith(
                          color: AppColors.white60,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AppSpacing.gapHMd,
              Semantics(
                button: true,
                label: 'Notifications',
                child: InkResponse(
                  onTap: onNotificationTap,
                  radius: _actionSize / 2,
                  customBorder: const CircleBorder(),
                  child: SizedBox.square(
                    dimension: _actionSize,
                    child: Center(
                      child: SvgPicture.asset(
                        AppAssets.notificationBell,
                        width: _actionIconSize,
                        height: _actionIconSize,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AppSpacing.gapHSm,
              Semantics(
                button: true,
                label: 'Open profile',
                child: InkResponse(
                  onTap: onAvatarTap,
                  radius: _actionSize / 2,
                  customBorder: const CircleBorder(),
                  child: SizedBox.square(
                    dimension: _actionSize,
                    child: Center(
                      child: CircleAvatar(
                        radius: _avatarRadius,
                        backgroundColor: AppColors.surfaceVariant,
                        backgroundImage: avatarUrl.isNotEmpty
                            ? CachedNetworkImageProvider(avatarUrl)
                            : null,
                        child: avatarUrl.isEmpty
                            ? SvgPicture.asset(
                                AppAssets.userCircle,
                                width: _actionIconSize,
                                height: _actionIconSize,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
