import 'package:flutter/material.dart';
import '../app/colors.dart';

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

     /* icon: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: SvgPicture.asset(
          "assets/svg/drodown.svg",
          height: 25,

          width: 20,
          colorFilter: const ColorFilter.mode(
            AppColors.white,
            BlendMode.srcIn,
          ),
        ),
      ),*/
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 14,
      ),

      decoration: InputDecoration(
        labelText: "$label*",
        floatingLabelBehavior: FloatingLabelBehavior.always,

        labelStyle: const TextStyle(
          color: AppColors.white30,
          fontSize: 13,
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),

        // 🔥 DEFAULT BORDER
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isSelected
                ?  AppColors.textfieldBorderLegacy// ✅ highlight when selected
                : AppColors.white30,
            width: 0.8,
          ),
        ),

        // 🔥 FOCUS BORDER (CLICK PE)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.goldSandPale, // ✅ gold highlight
            width: 1.2,
          ),
        ),
      ),

      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),

      onChanged: onChanged,
    );
  }
}