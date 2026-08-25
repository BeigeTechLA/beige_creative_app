import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../domain/models/notification_counts.dart';

class FilterOption {
  const FilterOption({required this.id, required this.label, this.count});

  final String id;
  final String label;
  final int? count;
}

class NotificationFilterBottomSheet extends StatefulWidget {
  const NotificationFilterBottomSheet({
    super.key,
    required this.counts,
    required this.selectedCategory,
    required this.onApply,
    required this.onClearAll,
  });

  final NotificationCounts counts;
  final String selectedCategory;
  final ValueChanged<String> onApply;
  final VoidCallback onClearAll;

  static Future<void> show({
    required BuildContext context,
    required NotificationCounts counts,
    required String selectedCategory,
    required ValueChanged<String> onApply,
    required VoidCallback onClearAll,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationFilterBottomSheet(
        counts: counts,
        selectedCategory: selectedCategory,
        onApply: onApply,
        onClearAll: onClearAll,
      ),
    );
  }

  @override
  State<NotificationFilterBottomSheet> createState() =>
      _NotificationFilterBottomSheetState();
}

class _NotificationFilterBottomSheetState
    extends State<NotificationFilterBottomSheet> {
  late String _currentCategory;

  List<FilterOption> get _options => [
    FilterOption(id: 'All', label: 'All', count: widget.counts.all),
    FilterOption(id: 'Unread', label: 'Unread', count: widget.counts.unread),
    FilterOption(id: 'Mentions', label: 'Mentions', count: widget.counts.mentions),
    FilterOption(id: 'Payments', label: 'Payments', count: widget.counts.payments),
    FilterOption(id: 'Projects', label: 'Projects', count: widget.counts.projects),
    FilterOption(id: 'Files', label: 'Files', count: widget.counts.files),
  ];

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// Top Drag Handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          /// Title Header + Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter By',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppColors.white),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),

          const Divider(color: AppColors.surfaceVariant, height: 1),
          const SizedBox(height: AppSpacing.xl),

          /// Card Container
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceInput,
              borderRadius: AppRadii.lgAll,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Options
                ..._options.map((opt) {
                  final isSelected =
                      _currentCategory.toLowerCase() == opt.id.toLowerCase();
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _currentCategory = opt.id;
                      });
                    },
                    borderRadius: AppRadii.lgAll,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  opt.label,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: isSelected
                                        ? AppColors.white
                                        : AppColors.white70,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                                if (opt.count != null) ...[
                                  AppSpacing.gapHSm,
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF282828),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      opt.count! < 10
                                          ? '0${opt.count}'
                                          : '${opt.count}',
                                      style: AppTextStyles.body12.copyWith(
                                        color: AppColors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          _CustomRadioButton(isSelected: isSelected),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          /// Action Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentCategory = 'All';
                      });
                      widget.onClearAll();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.white30),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.lgAll,
                      ),
                    ),
                    child: Text(
                      'Clear All',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_currentCategory);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.lgAll,
                      ),
                    ),
                    child: Text(
                      'Apply',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomRadioButton extends StatelessWidget {
  final bool isSelected;

  const _CustomRadioButton({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.white30,
          width: 2,
        ),
      ),
      child: isSelected
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
    );
  }
}
