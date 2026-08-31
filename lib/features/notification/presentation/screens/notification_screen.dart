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
import '../../../../shared/widgets/loading.dart';
import '../../domain/models/notification_counts.dart';
import '../providers/notification_list_providers.dart';
import '../widgets/empty_notification_widget.dart';
import '../widgets/notification_filter_bottom_sheet.dart';
import '../widgets/notification_stacked_cards.dart';
import '../../../../shared/widgets/app_segmented_control.dart';
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
    final countsAsync = ref.watch(notificationCountProvider);
    final counts = countsAsync.value ?? const NotificationCounts();
    final filtered = state.filteredNotifications;

    final todayItems = filtered.where((item) => _isToday(item.createdAt)).toList();
    final olderItems = filtered.where((item) => !_isToday(item.createdAt)).toList();

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar (Back Button)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.sm,
              ),
              child: Row(
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

                      // Title & Filter Icon Row (Matching Figma Image 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Notification',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          AppIconTapTarget(
                            semanticLabel: 'Filter',
                            onTap: () {
                              NotificationFilterBottomSheet.show(
                                context: context,
                                counts: counts,
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
                      AppSpacing.verticalXxs,
                      Text(
                        'Stay updated with real-time alerts about your bookings, requests, and important account activity.',
                        style: AppTextStyles.body13.copyWith(
                          color: AppColors.white60,
                          height: 1.35,
                        ),
                      ),
                      AppSpacing.verticalBase,

                      // Search Bar Input Container
                      Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppRadii.lgAll,
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mld),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.searchIcon,
                              width: AppSpacing.lg,
                              height: AppSpacing.lg,
                              colorFilter: const ColorFilter.mode(
                                AppColors.white54,
                                BlendMode.srcIn,
                              ),
                            ),
                            AppSpacing.gapHSmd,
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: notifier.setSearchQuery,
                                style: AppTextStyles.body14.copyWith(
                                  color: AppColors.white,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search Notifications...',
                                  hintStyle: AppTextStyles.body14.copyWith(
                                    color: AppColors.white38,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  notifier.setSearchQuery('');
                                },
                                child: const Icon(
                                  Icons.clear,
                                  color: AppColors.white54,
                                  size: AppSpacing.lg,
                                ),
                              ),
                          ],
                        ),
                      ),
                      AppSpacing.verticalBase,

                      // Segmented Tab Selector (Unread / Read)
                      AppSegmentedControl(
                        items: const ['Unread', 'Read'],
                        selectedIndex: state.selectedTab == NotificationTab.unread ? 0 : 1,
                        onValueChanged: (index) {
                          notifier.selectTab(
                            index == 0 ? NotificationTab.unread : NotificationTab.Read,
                          );
                        },
                      ),
                      AppSpacing.verticalBase,

                      // Notification Sections or Empty State ('No data')
                      if (state.isLoading && state.notifications.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.massive),
                          child: AppScreenLoader(),
                        )
                      else if (filtered.isEmpty)
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
                          AppSpacing.verticalBase,
                          NotificationStackedCards(
                            items: todayItems,
                            onTap: () => _navigateToSection('Today', true),
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
                          AppSpacing.verticalBase,
                          NotificationStackedCards(
                            items: olderItems,
                            onTap: () => _navigateToSection('Yesterday', false),
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
      bottomNavigationBar: state.selectedTab == NotificationTab.Read 
        ? const SizedBox.shrink()
        : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: (filtered.isEmpty || state.isMarkingAllAsRead) ? null : () => notifier.markAllAsRead(),
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
                  if (state.isMarkingAllAsRead)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  else
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
              style: const TextStyle(
                color: Color(0xFF797A7E),
                fontSize: 12,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w400,
                height: 1.75,
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
                borderRadius: AppRadii.smAll,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Color(0xFF797A7E),
                  fontSize: 12,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w400,
                  height: 1.75,
                ),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onViewAll,
          child: Text(
            'View All',
            style: AppTextStyles.body12.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
