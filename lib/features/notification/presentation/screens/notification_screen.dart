import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/app_icon_tap_target.dart';
import '../providers/notification_list_providers.dart';
import '../widgets/empty_notification_widget.dart';
import '../widgets/notification_filter_bottom_sheet.dart';
import '../widgets/notification_stacked_cards.dart';
import 'notification_section_screen.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _todaySectionKey = GlobalKey();
  final GlobalKey _yesterdaySectionKey = GlobalKey();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  void _scrollToSection(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToSection(String title, bool isToday) {
    context.pushNamed(
      Routes.notificationSectionList.name,
      extra: NotificationSectionScreenArgs(
        sectionTitle: title,
        isTodaySection: isToday,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationListProvider);
    final notifier = ref.read(notificationListProvider.notifier);
    final filtered = state.filteredNotifications;

    final todayItems = filtered.where((item) => _isToday(item.createdAt)).toList();
    final olderItems = filtered.where((item) => !_isToday(item.createdAt)).toList();

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar matching Figma
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppIconTapTarget(
                    semanticLabel: 'Back',
                    onTap: () => context.pop(),
                    icon: SvgPicture.asset(
                      AppAssets.back,
                      height: AppSpacing.xxl,
                      width: AppSpacing.xxl,
                      colorFilter: const ColorFilter.mode(
                        AppColors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  AppIconTapTarget(
                    semanticLabel: 'Filter',
                    onTap: () {
                      NotificationFilterBottomSheet.show(
                        context: context,
                        selectedCategory: state.selectedCategory,
                        onApply: notifier.applyCategoryFilter,
                        onClearAll: () => notifier.applyCategoryFilter('All'),
                      );
                    },
                    icon: SvgPicture.asset(
                      AppAssets.iconFilter,
                      height: AppSpacing.folderCardInset,
                      width: AppSpacing.folderCardInset,
                      colorFilter: const ColorFilter.mode(
                        AppColors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surfaceMid,
                onRefresh: () => notifier.fetchNotifications(),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSpacing.verticalSm,

                      // Title & Subtitle Header
                      Text(
                        'Notification',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.verticalXxs,
                      Text(
                        'Stay updated with real-time alerts about your bookings, requests, and important account activity.',
                        style: AppTextStyles.body13.copyWith(
                          color: AppColors.white60,
                          height: 1.3,
                        ),
                      ),
                      AppSpacing.verticalBase,

                      // Segmented Tab Selector (Unread / Read)
                      Container(
                        height: AppSpacing.jumbo,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppRadii.lgAll,
                        ),
                        padding: const EdgeInsets.all(AppSpacing.xxs),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => notifier.selectTab(NotificationTab.unread),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: state.selectedTab == NotificationTab.unread
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: AppRadii.lgAll,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Unread',
                                    style: AppTextStyles.body14.copyWith(
                                      color: state.selectedTab == NotificationTab.unread
                                          ? AppColors.onPrimary
                                          : AppColors.white70,
                                      fontWeight: state.selectedTab == NotificationTab.unread
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => notifier.selectTab(NotificationTab.all),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: state.selectedTab == NotificationTab.all
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: AppRadii.lgAll,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Read',
                                    style: AppTextStyles.body14.copyWith(
                                      color: state.selectedTab == NotificationTab.all
                                          ? AppColors.onPrimary
                                          : AppColors.white70,
                                      fontWeight: state.selectedTab == NotificationTab.all
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.verticalBase,

                      // Notification Sections or Empty State
                      if (filtered.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.massive),
                          child: EmptyNotificationWidget(),
                        )
                      else ...[
                        // Today Section
                        if (todayItems.isNotEmpty) ...[
                          _SectionHeader(
                            key: _todaySectionKey,
                            title: 'Today',
                            count: todayItems.length,
                            onViewAll: () => _navigateToSection('Today', true),
                          ),
                          NotificationStackedCards(
                            items: todayItems,
                            onTap: () => _scrollToSection(_todaySectionKey),
                          ),
                          AppSpacing.verticalXxl,
                        ],

                        // Yesterday / Older Section
                        if (olderItems.isNotEmpty) ...[
                          _SectionHeader(
                            key: _yesterdaySectionKey,
                            title: 'Yesterday',
                            count: olderItems.length,
                            onViewAll: () => _navigateToSection('Yesterday', false),
                          ),
                          NotificationStackedCards(
                            items: olderItems,
                            onTap: () => _scrollToSection(_yesterdaySectionKey),
                          ),
                          AppSpacing.verticalXxl,
                        ],
                      ],

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom CTA Button: Mark all as read
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: filtered.isEmpty ? null : () => notifier.markAllAsRead(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.surfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.lgAll,
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.done_all,
                    size: AppSpacing.xl,
                    color: filtered.isEmpty ? AppColors.white38 : AppColors.onPrimary,
                  ),
                  AppSpacing.gapHSm,
                  Text(
                    'Mark all as read',
                    style: AppTextStyles.body15Strong.copyWith(
                      color: filtered.isEmpty ? AppColors.white38 : AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    super.key,
    required this.title,
    required this.count,
    required this.onViewAll,
  });

  final String title;
  final int count;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: AppTextStyles.body15Strong.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.gapHSm,
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadii.lgAll,
              ),
              child: Text(
                '$count',
                style: AppTextStyles.body12.copyWith(
                  color: AppColors.white70,
                ),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onViewAll,
          child: Text(
            'View All',
            style: AppTextStyles.body13.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
