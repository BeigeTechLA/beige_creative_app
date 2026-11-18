import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../config/env.dart';
import '../../../../model_class/upcoming_shootview_model.dart';
import '../../../../shared/widgets/app_icon_tap_target.dart';
import '../../../../shared/widgets/loading.dart';

String? _resolveImageUrl(dynamic rawUrl) {
  if (rawUrl == null) return null;
  final str = rawUrl.toString().trim();
  if (str.isEmpty) return null;
  if (str.startsWith('http://') || str.startsWith('https://')) return str;
  final cleanPath = str.startsWith('/') ? str.substring(1) : str;
  final base = Env.imageUrl.endsWith('/') ? Env.imageUrl : '${Env.imageUrl}/';
  return '$base$cleanPath';
}

Widget _buildHeaderImage(dynamic rawUrl) {
  final resolvedUrl = _resolveImageUrl(rawUrl);
  if (resolvedUrl == null) {
    return Container(
      height: 362,
      width: double.infinity,
      color: AppColors.surfaceDark,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        AppAssets.imageHolder,
        height: 56,
        colorFilter: const ColorFilter.mode(AppColors.white38, BlendMode.srcIn),
      ),
    );
  }

  return CachedNetworkImage(
    imageUrl: resolvedUrl,
    fit: BoxFit.cover,
    width: double.infinity,
    height: 362,
    placeholder: (context, url) => Container(
      height: 362,
      width: double.infinity,
      color: AppColors.surfaceDark,
      alignment: Alignment.center,
      child: const AppCircularLoader(size: 28),
    ),
    errorWidget: (context, url, error) {
      return Container(
        height: 362,
        width: double.infinity,
        color: AppColors.surfaceDark,
        alignment: Alignment.center,
        child: SvgPicture.asset(
          AppAssets.imageHolder,
          height: 56,
          colorFilter: const ColorFilter.mode(
            AppColors.white38,
            BlendMode.srcIn,
          ),
        ),
      );
    },
  );
}

/// Photo hero that collapses into an opaque, accessible navigation toolbar.
class ShootDetailsHeader extends StatelessWidget {
  const ShootDetailsHeader({super.key, required this.project});

  final Project? project;

  @override
  Widget build(BuildContext context) {
    final project = this.project;
    final topInset = MediaQuery.paddingOf(context).top;
    final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
    final heroHeight = math.max(
      362 + math.max(0, textScale - 1) * 160,
      topInset + kToolbarHeight + 200,
    );
    final collapseDistance = heroHeight - topInset - kToolbarHeight;
    final name = project?.projectName.trim() ?? '';
    final status = project?.status ?? '';
    final statusText = status.isEmpty
        ? 'Active'
        : '${status[0].toUpperCase()}${status.substring(1).toLowerCase()}';

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final progress = (constraints.scrollOffset / collapseDistance).clamp(
          0.0,
          1.0,
        );
        final titleOpacity = ((progress - 0.75) / 0.25).clamp(0.0, 1.0);
        return SliverAppBar(
          pinned: true,
          automaticallyImplyLeading: false,
          expandedHeight: heroHeight - topInset,
          backgroundColor: AppColors.background,
          surfaceTintColor: AppColors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leadingWidth: AppSpacing.lg + 48,
          leading: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.lg),
            child: Center(
              child: Tooltip(
                message: 'Back',
                child: AppIconTapTarget(
                  minSize: 48,
                  semanticLabel: 'Back',
                  onTap: () {
                    // Ignore a second tap while this route is already popping.
                    if (ModalRoute.of(context)?.isCurrent != true) return;
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed(Routes.shoots.name);
                    }
                  },
                  icon: SvgPicture.asset(
                    AppAssets.back,
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
          title: titleOpacity == 0
              ? null
              : Opacity(
                  opacity: titleOpacity,
                  child: Text(
                    name.isEmpty ? 'Shoot Details' : name,
                    key: const ValueKey('shoot-details-toolbar-title'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.displayLabel16.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
          centerTitle: false,
          flexibleSpace: Stack(
            fit: StackFit.expand,
            children: [
              FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildHeaderImage(project?.imageUrl),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 160 * math.max(1, textScale),
                      child: const IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.black87,
                                AppColors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: AppSpacing.md,
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      child: Opacity(
                        opacity: (1 - progress / 0.65).clamp(0.0, 1.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B4D2E),
                                borderRadius: AppRadii.portfolioAll,
                                border: Border.all(
                                  color: const Color(
                                    0xFF22C55E,
                                  ).withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF22C55E),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    statusText,
                                    style: AppTextStyles.body12.copyWith(
                                      color: const Color(0xFF22C55E),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Text(
                                    project?.projectName.isNotEmpty == true
                                        ? project!.projectName
                                        : 'Project Details',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.displayLabel16
                                        .copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                if (project?.idLabel.isNotEmpty == true)
                                  Text(
                                    project!.idLabel.startsWith('#')
                                        ? 'ID: ${project.idLabel}'
                                        : 'ID: #${project.idLabel}',
                                    style: AppTextStyles.bodyMediumStrong
                                        .copyWith(color: AppColors.primary),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: topInset + kToolbarHeight + 64,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [
                          0,
                          (topInset + kToolbarHeight) /
                              (topInset + kToolbarHeight + 64),
                          1,
                        ],
                        colors: [
                          Color.lerp(
                            AppColors.black70,
                            AppColors.background,
                            progress,
                          )!,
                          Color.lerp(
                            AppColors.black70,
                            AppColors.background,
                            progress,
                          )!,
                          AppColors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
