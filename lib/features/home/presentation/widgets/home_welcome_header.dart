import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../config/env.dart';

/// Top welcome banner — drawer menu icon, "Welcome Back, [name]", bell, avatar.
/// Pure presentation. Orchestrator owns the profile + tap callback.
class HomeWelcomeHeader extends StatelessWidget {
  final String? firstName;
  final String profileImageUrl;
  final VoidCallback onAvatarTap;

  const HomeWelcomeHeader({
    super.key,
    required this.firstName,
    required this.profileImageUrl,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
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
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => InkWell(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: SvgPicture.asset(
                        AppAssets.menu,
                        width: 26,
                        colorFilter: ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Welcome Back, ${firstName ?? 'User..'}",
                      style: AppTextStyles.bodyLargeMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  SvgPicture.asset(
                    AppAssets.notificationBell,
                    width: 22,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 15),
                  InkWell(
                    onTap: onAvatarTap,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? CachedNetworkImageProvider(
                              "${Env.imageUrl}$profileImageUrl",
                            )
                          : null,
                      child: profileImageUrl.isEmpty
                          ? SvgPicture.asset(
                              AppAssets.userCircle,
                              width: 20,
                              height: 20,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
