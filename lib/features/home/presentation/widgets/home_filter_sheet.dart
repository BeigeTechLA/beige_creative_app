import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/durations.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

/// "Filter" bottom sheet — collapsible Date / Status / Category / Type
/// sections + Clear All / Apply CTAs.
///
/// Lifted verbatim from `_showFilterBottomSheet`, `_filterSection`, and
/// `_radioOption` on `_HomeScreenState`.
///
/// NOTE (Task 4.15 decompose): this code is currently UNREACHABLE in the
/// legacy `home_screen.dart` — the only call site (`_showFilterBottomSheet()`)
/// lives inside a large commented-out block in the Upcoming Shoots header.
/// Preserved verbatim for the migrate task (4.16) to either wire it up or
/// formally strip it.
void showHomeFilterBottomSheet({
  required BuildContext context,
  required String? initialDate,
  required String? initialStatus,
  required String? initialCategory,
  required String? initialType,
  required Function(String? date, String? status, String? category, String? type) onApply,
  required VoidCallback onClearAll,
}) {
  String? selectedDate = (initialDate == null || initialDate.isEmpty) ? null : initialDate;
  String? selectedStatus = (initialStatus == null || initialStatus.isEmpty) ? null : initialStatus;
  String? selectedCategory = (initialCategory == null || initialCategory.isEmpty) ? null : initialCategory;
  String? selectedType = (initialType == null || initialType.isEmpty) ? null : initialType;

  bool isDateExpanded = selectedDate != null;
  bool isStatusExpanded = selectedStatus != null;
  bool isCategoryExpanded = selectedCategory != null;
  bool isTypeExpanded = selectedType != null;

  // Default to Date expanded if nothing else is selected
  if (!isDateExpanded && !isStatusExpanded && !isCategoryExpanded && !isTypeExpanded) {
    isDateExpanded = true;
  }

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
  final List<String> categoryOptions = [];
  final List<String> typeOptions = ["All", "shoots", "Rental"];

  showModalBottomSheet(
    useRootNavigator: true,
    isScrollControlled: true,
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return DraggableScrollableSheet(
            controller: sheetController,
            initialChildSize: 0.6,
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
                                      ? dateOptions
                                          .map(
                                            (label) => _radioOption(
                                              label: label,
                                              selected: selectedDate == label,
                                              onTap: () => setState(
                                                () => selectedDate = selectedDate == label ? null : label,
                                              ),
                                            ),
                                          )
                                          .toList()
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
                                  title: "Filter By Category",
                                  isExpanded: isCategoryExpanded,
                                  onTap: () => setState(() {
                                    isCategoryExpanded = !isCategoryExpanded;
                                    if (isCategoryExpanded) {
                                      sheetController.animateTo(
                                        0.95,
                                        duration: AppDurations.normal,
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  }),
                                  children: isCategoryExpanded
                                      ? categoryOptions
                                          .map(
                                            (label) => _radioOption(
                                              label: label,
                                              selected:
                                                  selectedCategory == label,
                                              onTap: () => setState(
                                                () =>
                                                    selectedCategory = selectedCategory == label ? null : label,
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
                                  height: AppSpacing.inlineNudge,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedType = null;
                                            selectedCategory = null;
                                            selectedStatus = null;
                                            selectedDate = null;
                                            isDateExpanded = false;
                                            isStatusExpanded = false;
                                            isCategoryExpanded = false;
                                            isTypeExpanded = false;
                                          });
                                          onClearAll();
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            left: AppSpacing.md,
                                          ),
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
                                            selectedStatus,
                                            selectedCategory,
                                            selectedType,
                                          );
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            right: AppSpacing.md,
                                          ),
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
                                AppSpacing.verticalXl,
                              ],
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.verticalMd,
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
