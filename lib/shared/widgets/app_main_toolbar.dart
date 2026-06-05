import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app/assets.dart';
import '../../app/colors.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';

/// Shared top toolbar for `AppShell` branch screens (Shoots, Files, Messages,
/// Manage Availability). Drawer menu icon on the left, centered title.
///
/// Place above the scrollable body so it stays pinned. Home keeps its
/// bespoke `HomeWelcomeHeader` because it carries welcome text, bell, and
/// avatar — see `lib/features/home/presentation/widgets/home_welcome_header.dart`.
class AppMainToolbar extends StatelessWidget {
  static const double _navigationTargetSize = 48;
  static const double _menuIconSize = 26;

  final String title;

  const AppMainToolbar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              tooltip: 'Open menu',
              onPressed: Scaffold.of(ctx).openDrawer,
              constraints: const BoxConstraints.tightFor(
                width: _navigationTargetSize,
                height: _navigationTargetSize,
              ),
              padding: EdgeInsets.zero,
              icon: SvgPicture.asset(
                AppAssets.menu,
                width: _menuIconSize,
                height: _menuIconSize,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const Spacer(),
          Text(title, style: AppTextStyles.displayLabel16),
          const Spacer(),
          const SizedBox.square(dimension: _navigationTargetSize),
        ],
      ),
    );
  }
}
