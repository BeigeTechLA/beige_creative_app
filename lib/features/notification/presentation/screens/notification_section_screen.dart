import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../core/notifications/notification_payload.dart';
import '../../../../core/notifications/push_notification_service.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/app_icon_tap_target.dart';
import '../../../../shared/widgets/loading.dart';
import '../../domain/models/notification_counts.dart';
import '../providers/notification_list_providers.dart';
import '../widgets/empty_notification_widget.dart';
import '../widgets/notification_filter_bottom_sheet.dart';
import '../widgets/notification_item_card.dart';

class NotificationSectionScreenArgs {
  const NotificationSectionScreenArgs({
    required this.sectionTitle,
    required this.isTodaySection,
  });

  final String sectionTitle;
  final bool isTodaySection;

  static NotificationSectionScreenArgs fromExtra(Object? extra) {
    if (extra is NotificationSectionScreenArgs) {
      return extra;
    }
    if (extra is Map<String, dynamic>) {
      return NotificationSectionScreenArgs(
        sectionTitle: extra['sectionTitle']?.toString() ?? 'Today',
        isTodaySection: extra['isTodaySection'] == true,
      );
    }
    return const NotificationSectionScreenArgs(
      sectionTitle: 'Today',
      isTodaySection: true,
    );
  }
}

class NotificationSectionScreen extends ConsumerStatefulWidget {
  const NotificationSectionScreen({
    super.key,
    required this.args,
  });

  final NotificationSectionScreenArgs args;

  @override
  ConsumerState<NotificationSectionScreen> createState() =>
      _NotificationSectionScreenState();
}

class _NotificationSectionScreenState
    extends ConsumerState<NotificationSectionScreen> {
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationListProvider);
    final notifier = ref.read(notificationListProvider.notifier);
    final countsAsync = ref.watch(notificationCountProvider);
    final counts = countsAsync.value ?? const NotificationCounts();
    final filtered = state.filteredNotifications;

    final items = filtered.where((item) {
      final isT = _isToday(item.createdAt);
      return widget.args.isTodaySection ? isT : !isT;
    }).toList();

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
              child: Column(
                children: [
                  // Fixed Header (Section Title + Filter)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSpacing.verticalSm,
                        // Section Title & Filter Button Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${widget.args.sectionTitle} (${items.length})',
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
                        AppSpacing.verticalXl,
                      ],
                    ),
                  ),

                  // Scrollable List Area
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
                            // Notification List or Empty State
                            if (state.isLoading && items.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: AppSpacing.massive),
                                child: AppScreenLoader(),
                              )
                            else if (items.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: AppSpacing.massive),
                                child: EmptyNotificationWidget(),
                              )
                            else
                              ...items.map(
                                (item) => NotificationItemCard(
                                  item: item,
                                  onTap: () {
                                    notifier.markAsRead(item.id);
                                    if (item.payload != null) {
                                      final payload = NotificationPayload.fromMap(item.payload!);
                                      PushNotificationService.instance.handleNotificationClick(payload);
                                    }
                                  },
                                ),
                              ),

                            // Extra bottom padding so last card never overlaps bottom button
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
              onPressed: (items.isEmpty || state.isMarkingAllAsRead) ? null : () => notifier.markAllAsRead(),
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
                      color: items.isEmpty ? AppColors.white38 : AppColors.onPrimary,
                    ),
                  AppSpacing.gapHSm,
                  Text(
                    'Mark all as read',
                    style: AppTextStyles.body15Strong.copyWith(
                      color: items.isEmpty ? AppColors.white38 : AppColors.onPrimary,
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
