import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/assets.dart';
import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/routes.dart';
import '../../app/shadows.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';
import '../../core/firebase/analytics_service.dart';

/// Hosts the 5 root branches (Dashboard, Shoots, Files, Messages, Manage
/// Availability) under a `StatefulShellRoute.indexedStack`. Tabs preserve
/// their `Navigator` state across switches.
///
/// Replaces the legacy `Mainscreen` (also drops the per-frame
/// `BackdropFilter(sigmaX: 80, sigmaY: 70)` which was costing 4-6 ms/frame
/// per `AUDIT_PERF.md` D-1).
class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;

  const AppShell({super.key, required this.shell});

  void _goBranch(int index) {
    shell.goBranch(
      index,
      initialLocation: index == shell.currentIndex,
    );
    // Phase F — StatefulShellRoute branch switches don't push on the root
    // Navigator, so AppAnalyticsObserver doesn't see them. Log explicitly.
    if (index != shell.currentIndex && index >= 0 && index < _branchRoutes.length) {
      AnalyticsService.logScreenView(screenName: _branchRoutes[index].name);
    }
  }

  /// Branch index → `RouteSpec`. Mirrors the `StatefulShellRoute.branches`
  /// order in `lib/app/router.dart`.
  static const List<RouteSpec> _branchRoutes = [
    Routes.home,
    Routes.shoots,
    Routes.files,
    Routes.messages,
    Routes.manageAvailability,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _AppShellDrawer(
        currentIndex: shell.currentIndex,
        onSelect: (i) {
          Navigator.of(context).pop();
          _goBranch(i);
        },
      ),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.3,
      body: shell,
      // Branch 4 (Manage Availability) is drawer-only — hiding the bar on
      // that branch tells the truth instead of clamping to Dashboard.
      bottomNavigationBar: shell.currentIndex >= 4
          ? null
          : _AppShellBottomBar(
              currentIndex: shell.currentIndex,
              onTap: _goBranch,
            ),
    );
  }
}

class _AppShellBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AppShellBottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.white,
      unselectedItemColor: AppColors.white30,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      iconSize: 26,
      elevation: 0,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: _InactiveNavIcon(AppAssets.inactiveDashboard),
          activeIcon: _ActiveNavIcon(AppAssets.activeDashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: _InactiveNavIcon(AppAssets.inactiveShoots),
          activeIcon: _ActiveNavIcon(AppAssets.activeShoots, width: 46),
          label: 'Shoots',
        ),
        BottomNavigationBarItem(
          icon: _InactiveNavIcon(AppAssets.inactiveFileManager),
          activeIcon: _ActiveNavIcon(AppAssets.activeFileManager, width: 48),
          label: 'Files',
        ),
        BottomNavigationBarItem(
          icon: _InactiveNavIcon(AppAssets.inactiveMessages),
          activeIcon: _ActiveNavIcon(AppAssets.activeMessages),
          label: 'Messages',
        ),
      ],
    );
  }
}

class _InactiveNavIcon extends StatelessWidget {
  final String path;
  const _InactiveNavIcon(this.path);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: SizedBox(
        width: 44,
        height: 26,
        child: Center(
          child: SvgPicture.asset(
            path,
            height: 26,
            width: 26,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _ActiveNavIcon extends StatelessWidget {
  final String path;
  final double? width;

  const _ActiveNavIcon(this.path, {this.width});

  @override
  Widget build(BuildContext context) {
    final artWidth = width ?? 44;
    final artHeight = 44.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: SizedBox(
        width: artWidth,
        height: 26,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: AppShadows.activeNavGlow,
              ),
            ),
            SvgPicture.asset(
              path,
              width: artWidth,
              height: artHeight,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

class _AppShellDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const _AppShellDrawer({
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surfaceAbyss,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(AppAssets.groupLogo),
                      IconButton(
                        icon:
                            const Icon(Icons.close, color: AppColors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  AppSpacing.verticalXl,
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      context.pushNamed(Routes.myProfile.name);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.goldSandLight,
                        borderRadius: AppRadii.xxlAll,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            child: SvgPicture.asset(AppAssets.userCircle),
                          ),
                          AppSpacing.gapHMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Profile',
                                  style: AppTextStyles.bodyLargeStrong
                                      .copyWith(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                AppSpacing.verticalXxs,
                                Text(
                                  'View account details',
                                  style: AppTextStyles.bodySmallMedium
                                      .copyWith(color: AppColors.black),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.neutralGrey),
            Expanded(
              child: ListView(
                children: [
                  _DrawerItem(
                    label: 'Dashboard',
                    activeIcon: AppAssets.activeDashboard,
                    inactiveIcon: AppAssets.inactiveDashboard,
                    index: 0,
                    currentIndex: currentIndex,
                    onTap: onSelect,
                  ),
                  _DrawerItem(
                    label: 'shoots',
                    activeIcon: AppAssets.activeShoots,
                    inactiveIcon: AppAssets.inactiveShoots,
                    index: 1,
                    currentIndex: currentIndex,
                    onTap: onSelect,
                  ),
                  _DrawerItem(
                    label: 'File Manager',
                    activeIcon: AppAssets.activeFileManager,
                    inactiveIcon: AppAssets.inactiveFileManager,
                    index: 2,
                    currentIndex: currentIndex,
                    onTap: onSelect,
                  ),
                  _DrawerItem(
                    label: 'messages',
                    activeIcon: AppAssets.activeMessages,
                    inactiveIcon: AppAssets.inactiveMessages,
                    index: 3,
                    currentIndex: currentIndex,
                    onTap: onSelect,
                  ),
                  _DrawerItem(
                    label: 'Manage Availability',
                    activeIcon: AppAssets.activeManageAvailability,
                    inactiveIcon: AppAssets.inactiveManageAvailability,
                    index: 4,
                    currentIndex: currentIndex,
                    onTap: onSelect,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String label;
  final String activeIcon;
  final String inactiveIcon;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _DrawerItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    return ListTile(
      leading: SizedBox(
        width: 32,
        height: 32,
        child: Center(
          child: SvgPicture.asset(
            isActive ? activeIcon : inactiveIcon,
            width: isActive ? 28 : 24,
            height: isActive ? 28 : 24,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(
              isActive ? AppColors.white : AppColors.white30,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
      ),
      onTap: () => onTap(index),
    );
  }
}
