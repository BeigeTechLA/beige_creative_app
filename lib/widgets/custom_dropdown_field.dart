import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../utility/ColorCode.dart';

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
      dropdownColor: const Color(0xFF1E1E1E),

      icon: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: SvgPicture.asset(
          "assets/svg/DROPdown.svg",
          height: 25,

          width: 20,
          colorFilter: const ColorFilter.mode(
            ColorCode.white,
            BlendMode.srcIn,
          ),
        ),
      ),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),

      decoration: InputDecoration(
        labelText: "$label*",
        floatingLabelBehavior: FloatingLabelBehavior.always,

        labelStyle: const TextStyle(
          color: ColorCode.kWhiteOpacity70,
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
                ?  ColorCode.textfieldbordercollor// ✅ highlight when selected
                : ColorCode.kWhiteOpacity70,
            width: 0.8,
          ),
        ),

        // 🔥 FOCUS BORDER (CLICK PE)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFD6C3A3), // ✅ gold highlight
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