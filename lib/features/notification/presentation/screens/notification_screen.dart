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

  @override
  void dispose() {
    _searchController.dispose();
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
    final filtered = state.filteredNotifications;

    final todayItems = filtered.where((item) => _isToday(item.createdAt)).toList();
    final olderItems = filtered.where((item) => !_isToday(item.createdAt)).toList();

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
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
                      height: 24,
                      width: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      AppIconTapTarget(
                        semanticLabel: 'Notification Settings',
                        onTap: () => context.pushNamed(Routes.notifications.name),
                        icon: SvgPicture.asset(
                          AppAssets.notificationSetting,
                          height: 22,
                          width: 22,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                          height: 22,
                          width: 22,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
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
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Title & Subtitle Header
                      Text(
                        'Notification',
                        style: AppTextStyles.displayStrong16w600.copyWith(
                          color: AppColors.white,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stay updated with real-time alerts about your bookings, requests, and important account activity.',
                        style: AppTextStyles.body13.copyWith(
                          color: AppColors.white60,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Search Bar
                      Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppRadii.lgAll,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.searchIcon,
                              width: 18,
                              height: 18,
                              colorFilter: const ColorFilter.mode(
                                AppColors.white54,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 10),
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
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Notification Sections or Empty State
                      if (filtered.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: EmptyNotificationWidget(),
                        )
                      else ...[
                        // Today Section
                        if (todayItems.isNotEmpty) ...[
                          _SectionHeader(
                            title: 'Today',
                            count: todayItems.length,
                            onViewAll: () => _navigateToSection('Today', true),
                          ),
                          NotificationStackedCards(
                            items: todayItems,
                            onTap: () => _navigateToSection('Today', true),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Yesterday / Older Section
                        if (olderItems.isNotEmpty) ...[
                          _SectionHeader(
                            title: 'Yesterday',
                            count: olderItems.length,
                            onViewAll: () => _navigateToSection('Yesterday', false),
                          ),
                          NotificationStackedCards(
                            items: olderItems,
                            onTap: () => _navigateToSection('Yesterday', false),
                          ),
                          const SizedBox(height: 24),
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
                    Icons.check,
                    size: 20,
                    color: filtered.isEmpty ? AppColors.white38 : AppColors.onPrimary,
                  ),
                  const SizedBox(width: 8),
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
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
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
