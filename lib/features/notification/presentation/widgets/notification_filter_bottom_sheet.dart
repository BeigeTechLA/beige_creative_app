import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

class FilterOption {
  const FilterOption({
    required this.id,
    required this.label,
    this.count,
  });

  final String id;
  final String label;
  final int? count;
}

class NotificationFilterBottomSheet extends StatefulWidget {
  const NotificationFilterBottomSheet({
    super.key,
    required this.selectedCategory,
    required this.onApply,
    required this.onClearAll,
  });

  final String selectedCategory;
  final ValueChanged<String> onApply;
  final VoidCallback onClearAll;

  static Future<void> show({
    required BuildContext context,
    required String selectedCategory,
    required ValueChanged<String> onApply,
    required VoidCallback onClearAll,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => NotificationFilterBottomSheet(
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

  static const List<FilterOption> _options = [
    FilterOption(id: 'All', label: 'All', count: 12),
    FilterOption(id: 'Unread', label: 'Unread', count: 2),
    FilterOption(id: 'Mentions', label: 'Mentions', count: 1),
    FilterOption(id: 'Payments', label: 'Payments', count: 2),
    FilterOption(id: 'Projects', label: 'Projects', count: 2),
    FilterOption(id: 'Files', label: 'Files', count: 2),
    FilterOption(id: 'Date', label: 'Date'),
    FilterOption(id: 'Members', label: 'Members'),
    FilterOption(id: 'Properties', label: 'Properties'),
    FilterOption(id: 'Status', label: 'Status'),
  ];

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.base,
          AppSpacing.md,
          AppSpacing.base,
          AppSpacing.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header: Filter By title & Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter By',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.white70,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Options List Container
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadii.lgAll,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _options.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    color: AppColors.dividerDark,
                  ),
                  itemBuilder: (context, index) {
                    final opt = _options[index];
                    final isSelected = _currentCategory.toLowerCase() == opt.id.toLowerCase();

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _currentCategory = opt.id;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.base,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    opt.label,
                                    style: AppTextStyles.body14.copyWith(
                                      color: isSelected ? AppColors.white : AppColors.white70,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                  if (opt.count != null) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      opt.count! < 10 ? '0${opt.count}' : '${opt.count}',
                                      style: AppTextStyles.body12.copyWith(
                                        color: AppColors.white54,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Radio indicator
                            Container(
                              width: 20,
                              height: 20,
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
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Footer Buttons Row (Clear All & Apply)
            Row(
              children: [
                // Clear All Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentCategory = 'All';
                      });
                      widget.onClearAll();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surfaceVariant,
                      side: const BorderSide(color: AppColors.dividerDark),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.lgAll,
                      ),
                    ),
                    child: Text(
                      'Clear All',
                      style: AppTextStyles.body14.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Apply Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_currentCategory);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.lgAll,
                      ),
                    ),
                    child: Text(
                      'Apply',
                      style: AppTextStyles.body14.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
