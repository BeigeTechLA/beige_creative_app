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
import '../../core/providers/guest_mode_provider.dart';
import '../../shared/widgets/login_dialog.dart';
import '../../features/availability/presentation/providers/availability_providers.dart'
    show manageAvailabilityNotifierProvider;
import '../../features/file_manager/presentation/providers/file_manager_root_notifier.dart'
    show fileManagerRootNotifierProvider;
import '../../features/home/presentation/providers/home_notifier.dart';
import '../../features/meetings/presentation/providers/meetings_list_notifier.dart'
    show meetingsListNotifierProvider;
import '../../features/messages/presentation/providers/conversation_list_providers.dart'
    show conversationListProvider;
import '../../features/profile/presentation/providers/my_profile_providers.dart'
    show profileImageBustProvider;
import '../../features/shoots/presentation/providers/shoots_providers.dart'
    show shootsListProvider;

/// Hosts the root branches (Dashboard, Shoots, Files, Messages, future
/// drawer-only entries, Manage Availability) under a
/// `StatefulShellRoute.indexedStack`. Tabs preserve their `Navigator` state
/// across switches.
///
/// Replaces the legacy `Mainscreen` (also drops the per-frame
/// `BackdropFilter(sigmaX: 80, sigmaY: 70)` which was costing 4-6 ms/frame
/// per `AUDIT_PERF.md` D-1).
class AppShell extends ConsumerWidget {
  final StatefulNavigationShell shell;

  const AppShell({super.key, required this.shell});

  void _goBranch(BuildContext context, WidgetRef ref, int index) {
    final isGuest = ref.read(guestModeProvider);
    if (isGuest && index != 0) {
      showLoginDialog(context);
      return;
    }
    final isBranchSwitch = index != shell.currentIndex;
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
    if (isBranchSwitch && index >= 0 && index < _branchRoutes.length) {
      // Phase F — StatefulShellRoute branch switches don't push on the root
      // Navigator, so AppAnalyticsObserver doesn't see them. Log explicitly.
      AnalyticsService.logScreenView(screenName: _branchRoutes[index].name);
      // IndexedStack keeps branch widgets (and their notifiers) alive, so a
      // switch alone never re-runs build(). Invalidate the destination
      // branch's notifier to force a fresh API load on every menu change.
      _invalidateBranchData(ref, index);
    }
  }

  /// Branch index → root data notifier. Each listed notifier self-fetches in
  /// `build()`, so invalidation triggers a full reload. Branches 6/7 are
  /// static placeholders with no data.
  static void _invalidateBranchData(WidgetRef ref, int index) {
    switch (index) {
      case 0:
        ref.invalidate(homeNotifierProvider);
      case 1:
        ref.invalidate(shootsListProvider);
      case 2:
        ref.invalidate(fileManagerRootNotifierProvider);
      case 3:
        ref.invalidate(conversationListProvider);
      case 4:
        ref.invalidate(meetingsListNotifierProvider);
      case 5:
        ref.invalidate(manageAvailabilityNotifierProvider);
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
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _AppShellDrawer(
        currentIndex: shell.currentIndex,
        onSelect: (i) {
          Navigator.of(context).pop();
          _goBranch(context, ref, i);
        },
      ),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.3,
      body: ClipRect(child: shell),
      // File Manager (branch 2) hidden from bottom bar pre-release; branches
      // 4+ are drawer-only. Hide the bar when current branch isn't in the
      // visible set instead of clamping to Dashboard.
      bottomNavigationBar: _bottomBarBranches.contains(shell.currentIndex)
          ? _AppShellBottomBar(
              currentBranchIndex: shell.currentIndex,
              onSelectBranch: (i) => _goBranch(context, ref, i),
            )
          : null,
    );
  }
}

/// Branch indices surfaced in the bottom bar, in visual order. File Manager
/// (branch 2) is intentionally omitted for release; code and route remain.
const List<int> _bottomBarBranches = [0, 1, 3];

class _AppShellBottomBar extends StatelessWidget {
  final int currentBranchIndex;
  final ValueChanged<int> onSelectBranch;

  const _AppShellBottomBar({
    required this.currentBranchIndex,
    required this.onSelectBranch,
  });

  @override
  Widget build(BuildContext context) {
    const items = <_BottomBarItemData>[
      _BottomBarItemData(
        branchIndex: 0,
        label: 'Dashboard',
        activeIcon: AppAssets.activeDashboard,
        inactiveIcon: AppAssets.inactiveDashboard,
      ),
      _BottomBarItemData(
        branchIndex: 1,
        label: 'Shoots',
        activeIcon: AppAssets.activeShoots,
        inactiveIcon: AppAssets.inactiveShoots,
        activeWidth: 46,
      ),
      _BottomBarItemData(
        branchIndex: 3,
        label: 'Messages',
        activeIcon: AppAssets.activeMessages,
        inactiveIcon: AppAssets.inactiveMessages,
      ),
    ];
    final currentPosition = items.indexWhere(
      (i) => i.branchIndex == currentBranchIndex,
    );
    return BottomNavigationBar(
      currentIndex: currentPosition >= 0 ? currentPosition : 0,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.white,
      unselectedItemColor: AppColors.white30,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      iconSize: 26,
      elevation: 0,
      onTap: (position) => onSelectBranch(items[position].branchIndex),
      items: [
        for (final item in items)
          BottomNavigationBarItem(
            icon: _InactiveNavIcon(item.inactiveIcon),
            activeIcon: _ActiveNavIcon(
              item.activeIcon,
              width: item.activeWidth,
            ),
            label: item.label,
          ),
      ],
    );
  }
}

class _BottomBarItemData {
  final int branchIndex;
  final String label;
  final String activeIcon;
  final String inactiveIcon;
  final double? activeWidth;

  const _BottomBarItemData({
    required this.branchIndex,
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    this.activeWidth,
  });
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
    final isGuest = ref.watch(guestModeProvider);
    final profileData = ref.watch(
      homeNotifierProvider.select((s) => s.profileData),
    );
    final profileImageUrl = profileData?.profileImageUrl ?? '';
    final bust = ref.watch(profileImageBustProvider);
    final avatarUrl = profileImageUrl.isEmpty
        ? ''
        : '${Env.imageUrl}$profileImageUrl${bust > 0 ? '?v=$bust' : ''}';

    final userName = isGuest
        ? 'Guest'
        : (profileData != null
            ? ('${profileData.firstName} ${profileData.lastName}'.trim().isNotEmpty
                  ? '${profileData.firstName} ${profileData.lastName}'.trim()
                  : profileData.user.name.isNotEmpty
                  ? profileData.user.name
                  : 'No Name')
            : 'Loading...');
    final userEmail = isGuest
        ? 'Tap to login'
        : (profileData != null
            ? (profileData.email.isNotEmpty
                  ? profileData.email
                  : profileData.user.email.isNotEmpty
                  ? profileData.user.email
                  : 'No Email')
            : 'Loading...');
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
                      if (ref.read(guestModeProvider)) {
                        showLoginDialog(context);
                      } else {
                        context.pushNamed(Routes.myProfile.name);
                      }
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
                                  style: AppTextStyles.bodyMediumStrong
                                      .copyWith(
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
                    branchIndex: item.branchIndex,
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

  // File Manager (branch 2), Affiliate (branch 6), Payouts (branch 7)
  // intentionally omitted for release; code and routes stay wired.
  static const List<_DrawerMenuItemData> _drawerItems = [
    _DrawerMenuItemData(
      branchIndex: 0,
      label: 'Dashboard',
      activeIcon: AppAssets.activeDashboard,
      inactiveIcon: AppAssets.inactiveDashboard,
    ),
    _DrawerMenuItemData(
      branchIndex: 1,
      label: 'Shoots',
      activeIcon: AppAssets.activeShoots,
      inactiveIcon: AppAssets.inactiveShoots,
    ),
    _DrawerMenuItemData(
      branchIndex: 3,
      label: 'Messages',
      activeIcon: AppAssets.activeMessages,
      inactiveIcon: AppAssets.inactiveMessages,
    ),
    _DrawerMenuItemData(
      branchIndex: 4,
      label: 'Meetings',
      activeIcon: AppAssets.activeMeetings,
      inactiveIcon: AppAssets.inactiveMeetings,
    ),
    _DrawerMenuItemData(
      branchIndex: 5,
      label: 'Manage Availability',
      activeIcon: AppAssets.activeManageAvailability,
      inactiveIcon: AppAssets.inactiveManageAvailability,
    ),
  ];
}

class _DrawerMenuItemData {
  final int branchIndex;
  final String label;
  final String activeIcon;
  final String inactiveIcon;

  const _DrawerMenuItemData({
    required this.branchIndex,
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
  });
}

class _DrawerItem extends StatelessWidget {
  final String label;
  final String activeIcon;
  final String inactiveIcon;
  final int branchIndex;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _DrawerItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.branchIndex,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == branchIndex;
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
      onTap: () => onTap(branchIndex),
    );
  }
}
