import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/colors.dart';
import '../../../../app/durations.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

/// "Filter" bottom sheet — collapsible Date / Status / Category / Type
/// sections + Clear All / Apply CTAs.
void showHomeFilterBottomSheet({
  required BuildContext context,
  required String? initialDate,
  DateTime? initialCustomStartDate,
  DateTime? initialCustomEndDate,
  required String? initialStatus,
  required String? initialCategory,
  required String? initialType,
  required Function(
    String? date,
    DateTime? customStartDate,
    DateTime? customEndDate,
    String? status,
    String? category,
    String? type,
  ) onApply,
  required VoidCallback onClearAll,
}) {
  String? selectedDate = (initialDate == null || initialDate.isEmpty) ? null : initialDate;
  DateTime? selectedCustomStartDate = initialCustomStartDate;
  DateTime? selectedCustomEndDate = initialCustomEndDate;
  String? selectedStatus = (initialStatus == null || initialStatus.isEmpty) ? null : initialStatus;
  String? selectedCategory = (initialCategory == null || initialCategory.isEmpty) ? null : initialCategory;
  String? selectedType = (initialType == null || initialType.isEmpty) ? null : initialType;

  bool isDateExpanded = true;
  bool isStatusExpanded = selectedStatus != null;
  bool isTypeExpanded = selectedType != null;

  final DraggableScrollableController sheetController =
      DraggableScrollableController();

  final List<String> dateOptions = [
    "Today",
    "This Week",
    "Marketing Analytics",
    "This Month",
    "Custom Range",
  ];
  final List<String> statusOptions = [
    "Upcoming",
    "Active",
    "Completed",
    "Cancelled",
  ];
  final List<String> typeOptions = ["All", "shoots", "Rental"];

  Future<void> pickCustomDateRange(BuildContext ctx, StateSetter setModalState) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initialRange = (selectedCustomStartDate != null && selectedCustomEndDate != null)
        ? DateTimeRange(start: selectedCustomStartDate!, end: selectedCustomEndDate!)
        : null;

    final picked = await showDateRangePicker(
      context: ctx,
      firstDate: today,
      lastDate: DateTime(now.year + 2),
      initialDateRange: initialRange,
      helpText: 'Select date range',
      builder: (context, child) => Theme(
        data: ThemeData.dark(useMaterial3: true).copyWith(
          dialogTheme: const DialogThemeData(
            backgroundColor: AppColors.surfaceGradientDark,
          ),
          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            secondary: AppColors.primary,
            onSecondary: AppColors.onPrimary,
            secondaryContainer: AppColors.primary.withValues(alpha: 0.25),
            onSecondaryContainer: AppColors.textPrimary,
            surface: AppColors.surfaceGradientDark,
            onSurface: AppColors.white,
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );

    if (picked != null) {
      setModalState(() {
        selectedDate = "Custom Range";
        selectedCustomStartDate = picked.start;
        selectedCustomEndDate = picked.end;
      });
    }
  }

  showModalBottomSheet(
    useRootNavigator: true,
    isScrollControlled: true,
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return DraggableScrollableSheet(
            controller: sheetController,
            initialChildSize: 0.9,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return GestureDetector(
                onVerticalDragUpdate: (details) {
                  final currentSize = sheetController.size;
                  final newSize = currentSize -
                      (details.delta.dy / MediaQuery.of(context).size.height);
                  sheetController.jumpTo(newSize.clamp(0.4, 0.95));
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceMid,
                    borderRadius: AppRadii.topMassive,
                  ),
                  child: Column(
                    children: [
                      AppSpacing.verticalMd,
                      Container(
                        height: 4,
                        width: 40,
                        margin:
                            const EdgeInsets.only(bottom: AppSpacing.base),
                        decoration: BoxDecoration(
                           color: AppColors.white,
                          borderRadius: AppRadii.xsAll,
                        ),
                      ),
                      Padding(
                        padding: AppSpacing.insetsHXl,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Filter",
                              style: AppTextStyles.displayHeading18.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(
                                Icons.close,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.verticalBase,
                      Divider(
                        thickness: 0.5,
                        color: AppColors.white.withValues(alpha: 0.3),
                      ),
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification is ScrollUpdateNotification &&
                                notification.scrollDelta != null &&
                                notification.scrollDelta! < 0) {
                              if (sheetController.size < 0.95) {
                                sheetController.animateTo(
                                  0.95,
                                  duration: AppDurations.normal,
                                  curve: Curves.easeInOut,
                                );
                              }
                            }
                            return false;
                          },
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                _filterSection(
                                  showDivider: true,
                                  title: "Filter By Date",
                                  isExpanded: isDateExpanded,
                                  onTap: () => setState(() {
                                    isDateExpanded = !isDateExpanded;
                                    if (isDateExpanded) {
                                      sheetController.animateTo(
                                        0.95,
                                        duration: AppDurations.normal,
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  }),
                                  children: isDateExpanded
                                      ? dateOptions.expand((label) {
                                          final isSelected = selectedDate == label;
                                          final isCustomRange = label == "Custom Range";
                                          return [
                                            _radioOption(
                                              label: label,
                                              selected: isSelected,
                                              onTap: () => setState(() {
                                                if (isSelected) {
                                                  selectedDate = null;
                                                } else {
                                                  selectedDate = label;
                                                  if (isCustomRange &&
                                                      (selectedCustomStartDate == null ||
                                                          selectedCustomEndDate == null)) {
                                                    final now = DateTime.now();
                                                    final today = DateTime(now.year, now.month, now.day);
                                                    selectedCustomStartDate = today;
                                                    selectedCustomEndDate = today.add(const Duration(days: 14));
                                                  }
                                                }
                                              }),
                                            ),
                                            if (isCustomRange && isSelected)
                                              _CustomDateRangeSelector(
                                                startDate: selectedCustomStartDate,
                                                endDate: selectedCustomEndDate,
                                                onTap: () => pickCustomDateRange(context, setState),
                                                onClear: () => setState(() {
                                                  selectedCustomStartDate = null;
                                                  selectedCustomEndDate = null;
                                                }),
                                              ),
                                          ];
                                        }).toList()
                                      : [],
                                ),
                                _filterSection(
                                  showDivider: true,
                                  title: "Filter By Status",
                                  isExpanded: isStatusExpanded,
                                  onTap: () => setState(() {
                                    isStatusExpanded = !isStatusExpanded;
                                    if (isStatusExpanded) {
                                      sheetController.animateTo(
                                        0.95,
                                        duration: AppDurations.normal,
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  }),
                                  children: isStatusExpanded
                                      ? statusOptions
                                          .map(
                                            (label) => _radioOption(
                                              label: label,
                                              selected: selectedStatus == label,
                                              onTap: () => setState(
                                                () => selectedStatus = selectedStatus == label ? null : label,
                                              ),
                                            ),
                                          )
                                          .toList()
                                      : [],
                                ),
                                _filterSection(
                                  showDivider: false,
                                  title: "Filter By Type",
                                  isExpanded: isTypeExpanded,
                                  onTap: () => setState(() {
                                    isTypeExpanded = !isTypeExpanded;
                                    if (isTypeExpanded) {
                                      sheetController.animateTo(
                                        0.95,
                                        duration: AppDurations.normal,
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  }),
                                  children: isTypeExpanded
                                      ? typeOptions
                                          .map(
                                            (label) => _radioOption(
                                              label: label,
                                              selected: selectedType == label,
                                              onTap: () => setState(
                                                () => selectedType = selectedType == label ? null : label,
                                              ),
                                            ),
                                          )
                                          .toList()
                                      : [],
                                ),
                                const SizedBox(
                                  height: AppSpacing.md,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: AppSpacing.md,
                          right: AppSpacing.md,
                          top: AppSpacing.md,
                          bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMid,
                          border: Border(
                            top: BorderSide(
                              color: AppColors.white.withValues(alpha: 0.12),
                              width: 0.8,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedType = null;
                                    selectedCategory = null;
                                    selectedStatus = null;
                                    selectedDate = null;
                                    selectedCustomStartDate = null;
                                    selectedCustomEndDate = null;
                                    isDateExpanded = true;
                                    isStatusExpanded = false;
                                    isTypeExpanded = false;
                                  });
                                  onClearAll();
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    AppSpacing.md,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadii.lgAll,
                                    border: Border.all(
                                      width: 0.5,
                                      color: AppColors.white
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Clear All',
                                      style: AppTextStyles
                                          .displayLabelW500
                                          .copyWith(
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            AppSpacing.gapHMd,
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  onApply(
                                    selectedDate,
                                    selectedCustomStartDate,
                                    selectedCustomEndDate,
                                    selectedStatus,
                                    selectedCategory,
                                    selectedType,
                                  );
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    AppSpacing.md,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: AppRadii.lgAll,
                                    border: Border.all(
                                      width: 0.5,
                                      color: AppColors.white
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Apply',
                                      style: AppTextStyles
                                          .displayLabelW500
                                          .copyWith(
                                        color: AppColors.onPrimary,
                                      ),
                                    ),
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
              );
            },
          );
        },
      );
    },
  );
}

Widget _filterSection({
  required String title,
  required bool isExpanded,
  required VoidCallback onTap,
  required List<Widget> children,
  bool showDivider = false,
}) {
  return Padding(
    padding: const EdgeInsets.all(AppSpacing.smd),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: AppRadii.xlAll,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: AppRadii.xlAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.mld,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body14Medium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  Icon(
                    size: 30,
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.white,
                  ),
                ],
              ),
            ),
          ),
          isExpanded && showDivider
              ? Divider(
                  thickness: 0.5,
                  color: AppColors.white.withValues(alpha: 0.3),
                )
              : SizedBox(),
          if (children.isNotEmpty) ...children,
          if (children.isNotEmpty) AppSpacing.verticalXs,
        ],
      ),
    ),
  );
}

Widget _radioOption({
  required String label,
  required bool selected,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.smd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body14.copyWith(
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.border : AppColors.white24,
                width: 2,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    ),
  );
}

class _CustomDateRangeSelector extends StatelessWidget {
  const _CustomDateRangeSelector({
    required this.startDate,
    required this.endDate,
    required this.onTap,
    required this.onClear,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onTap;
  final VoidCallback onClear;

  static final _dateFmt = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final hasRange = startDate != null && endDate != null;
    final text = hasRange
        ? '${_dateFmt.format(startDate!)} – ${_dateFmt.format(endDate!)}'
        : 'Select Start & End Date';

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.base,
        right: AppSpacing.base,
        bottom: AppSpacing.smd,
        top: AppSpacing.xs,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.mdAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.mld,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceInput,
            borderRadius: AppRadii.mdAll,
            border: Border.all(
              color: hasRange ? AppColors.primary : AppColors.white24,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: hasRange ? AppColors.primary : AppColors.white70,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.body14.copyWith(
                    color: hasRange ? AppColors.white : AppColors.white60,
                    fontWeight: hasRange ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
              if (hasRange)
                GestureDetector(
                  onTap: onClear,
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.white70,
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.white70,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
