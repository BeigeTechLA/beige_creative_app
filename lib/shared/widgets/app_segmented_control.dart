import 'package:flutter/material.dart';

import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/text_styles.dart';

/// Custom Beige-themed segmented control widget.
///
/// Features a dark surface track with a gold gradient active tab pill.
class AppSegmentedControl extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onValueChanged;
  final double height;

  const AppSegmentedControl({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onValueChanged,
    this.height = 50,
  });

  static const LinearGradient _activeGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFF7EAD0),
      Color(0xFFE8D1AB),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: AppRadii.xlAll,
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onValueChanged(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: isSelected ? _activeGradient : null,
                  borderRadius: AppRadii.lgAll,
                ),
                child: Text(
                  items[index],
                  style: isSelected
                      ? AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w600,
                        )
                      : AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
