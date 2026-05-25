import 'package:flutter/material.dart';
import '../app/colors.dart';

import '../app/radii.dart';
import '../app/spacing.dart';
import '../app/text_styles.dart';

class CustomDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 CHECK if value selected
    final bool isSelected = value != null && value!.isNotEmpty;

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      dropdownColor: AppColors.surfaceStats,

      style: AppTextStyles.system14.copyWith(color: AppColors.white),

      decoration: InputDecoration(
        labelText: "$label*",
        floatingLabelBehavior: FloatingLabelBehavior.always,

        labelStyle: AppTextStyles.system13.copyWith(color: AppColors.white30),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),

        // 🔥 DEFAULT BORDER
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgAll,
          borderSide: BorderSide(
            color: isSelected
                ? AppColors
                      .textfieldBorderLegacy // ✅ highlight when selected
                : AppColors.white30,
            width: 0.8,
          ),
        ),

        // 🔥 FOCUS BORDER (CLICK PE)
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgAll,
          borderSide: const BorderSide(
            color: AppColors.goldSandPale, // ✅ gold highlight
            width: 1.2,
          ),
        ),
      ),

      items: items.map((item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),

      onChanged: onChanged,
    );
  }
}
