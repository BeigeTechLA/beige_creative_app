import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
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
      backgroundColor: const Color(0xFF282828),
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
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
    FilterOption(id: 'All', label: 'All', count: 10),
    FilterOption(id: 'Unread', label: 'Unread', count: 2),
    FilterOption(id: 'Mentions', label: 'Mentions', count: 1),
    FilterOption(id: 'Payments', label: 'Payments', count: 2),
    FilterOption(id: 'Projects', label: 'Projects', count: 2),
    FilterOption(id: 'Files', label: 'Files', count: 2),
  ];

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF282828),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0C110C2E),
              blurRadius: 50,
              offset: Offset(20, 0),
            ),
          ],
        ),
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
            AppSpacing.verticalBase,

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
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 0.50,
                          color: Color(0xB2DDDDDD),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xB2DDDDDD),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.verticalBase,

            // Options List Container (Frame 2087328894)
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  itemCount: _options.length,
                  separatorBuilder: (context, index) => const SizedBox.shrink(),
                  itemBuilder: (context, index) {
                    final opt = _options[index];
                    final isSelected = _currentCategory.toLowerCase() == opt.id.toLowerCase();

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        setState(() {
                          _currentCategory = opt.id;
                        });
                      },
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
                                    style: AppTextStyles.body14.copyWith(
                                      color: isSelected ? AppColors.white : AppColors.white70,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
                                        opt.count! < 10 ? '0${opt.count}' : '${opt.count}',
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
                            // Radio indicator matching Figma
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.white30,
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF1E1E1E),
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
            AppSpacing.verticalXl,

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
                      backgroundColor: const Color(0xFF1E1E1E),
                      side: const BorderSide(color: Color(0x33FFFFFF)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
                AppSpacing.gapHMd,

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
                        borderRadius: BorderRadius.circular(16),
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
