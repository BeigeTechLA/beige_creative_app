import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/assets.dart';
import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/routes.dart';
import '../../app/shadows.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';
import '../../config/env.dart';
import '../../core/firebase/analytics_service.dart';
import '../../features/home/presentation/providers/home_notifier.dart';
import '../../features/profile/presentation/providers/my_profile_providers.dart'
    show profileImageBustProvider;
import '../../model_class/myprofile_model.dart';

/// Hosts the root branches (Dashboard, Shoots, Files, Messages, future
/// drawer-only entries, Manage Availability) under a
/// `StatefulShellRoute.indexedStack`. Tabs preserve their `Navigator` state
/// across switches.
///
/// Replaces the legacy `Mainscreen` (also drops the per-frame
/// `BackdropFilter(sigmaX: 80, sigmaY: 70)` which was costing 4-6 ms/frame
/// per `AUDIT_PERF.md` D-1).
class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;

  const AppShell({super.key, required this.shell});

  void _goBranch(int index) {
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
    // Phase F — StatefulShellRoute branch switches don't push on the root
    // Navigator, so AppAnalyticsObserver doesn't see them. Log explicitly.
    if (index != shell.currentIndex &&
        index >= 0 &&
        index < _branchRoutes.length) {
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
    Routes.meetings,
    Routes.manageAvailability,
    Routes.affiliate,
    Routes.payouts,
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
      // Branches 4+ are drawer-only — hiding the bar on those branches tells
      // the truth instead of clamping to Dashboard.
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

  const _AppShellBottomBar({required this.currentIndex, required this.onTap});

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

class _AppShellDrawer extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const _AppShellDrawer({required this.currentIndex, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileData = ref.watch(
      homeNotifierProvider.select((s) => s.profileData),
    );
    final profileImageUrl = profileData?.profileImageUrl ?? '';
    final bust = ref.watch(profileImageBustProvider);
    final avatarUrl = profileImageUrl.isEmpty
        ? ''
        : '${Env.imageUrl}$profileImageUrl${bust > 0 ? '?v=$bust' : ''}';

    final userName = profileData != null
        ? ('${profileData.firstName} ${profileData.lastName}'.trim().isNotEmpty
            ? '${profileData.firstName} ${profileData.lastName}'.trim()
            : profileData.user.name.isNotEmpty
                ? profileData.user.name
                : 'No Name')
        : 'Loading...';
    final userEmail = profileData != null
        ? (profileData.email.isNotEmpty
            ? profileData.email
            : profileData.user.email.isNotEmpty
                ? profileData.user.email
                : 'No Email')
        : 'Loading...';
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
                        icon: const Icon(Icons.close, color: AppColors.white),
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
                        color: AppColors.primary,
                        borderRadius: AppRadii.xxlAll,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.surfaceVariant,
                            backgroundImage: avatarUrl.isNotEmpty
                                ? CachedNetworkImageProvider(avatarUrl)
                                : null,
                            child: avatarUrl.isEmpty
                                ? SvgPicture.asset(AppAssets.userCircle)
                                : null,
                          ),
                          AppSpacing.gapHMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: AppTextStyles.bodyMediumStrong.copyWith(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  userEmail,
                                  style: AppTextStyles.bodySmallMedium.copyWith(
                                    color: AppColors.black,
                                  ),
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
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _drawerItems.length,
                separatorBuilder: (_, _) => const Divider(
                  height: 1,
                  thickness: 0.8,
                  color: AppColors.dividerDark,
                ),
                itemBuilder: (context, index) {
                  final item = _drawerItems[index];
                  return _DrawerItem(
                    label: item.label,
                    activeIcon: item.activeIcon,
                    inactiveIcon: item.inactiveIcon,
                    index: index,
                    currentIndex: currentIndex,
                    onTap: onSelect,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<_DrawerMenuItemData> _drawerItems = [
    _DrawerMenuItemData(
      label: 'Dashboard',
      activeIcon: AppAssets.activeDashboard,
      inactiveIcon: AppAssets.inactiveDashboard,
    ),
    _DrawerMenuItemData(
      label: 'Shoots',
      activeIcon: AppAssets.activeShoots,
      inactiveIcon: AppAssets.inactiveShoots,
    ),
    _DrawerMenuItemData(
      label: 'File Manager',
      activeIcon: AppAssets.activeFileManager,
      inactiveIcon: AppAssets.inactiveFileManager,
    ),
    _DrawerMenuItemData(
      label: 'Messages',
      activeIcon: AppAssets.activeMessages,
      inactiveIcon: AppAssets.inactiveMessages,
    ),
    _DrawerMenuItemData(
      label: 'Meetings',
      activeIcon: AppAssets.activeMeetings,
      inactiveIcon: AppAssets.inactiveMeetings,
    ),
    _DrawerMenuItemData(
      label: 'Manage Availability',
      activeIcon: AppAssets.activeManageAvailability,
      inactiveIcon: AppAssets.inactiveManageAvailability,
    ),
    _DrawerMenuItemData(
      label: 'Affiliate',
      activeIcon: AppAssets.activeAffiliate,
      inactiveIcon: AppAssets.inactiveAffiliate,
    ),
    _DrawerMenuItemData(
      label: 'Payouts',
      activeIcon: AppAssets.activePayouts,
      inactiveIcon: AppAssets.inactivePayouts,
    ),
  ];
}

class _DrawerMenuItemData {
  final String label;
  final String activeIcon;
  final String inactiveIcon;

  const _DrawerMenuItemData({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
  });
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
      minLeadingWidth: 32,
      minVerticalPadding: AppSpacing.base,
      leading: SizedBox(
        width: 32,
        height: 32,
        child: Center(
          child: SvgPicture.asset(
            isActive ? activeIcon : inactiveIcon,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyLargeMedium.copyWith(
          color: isActive ? AppColors.white : AppColors.white38,
        ),
      ),
      onTap: () => onTap(index),
    );
  }
}
