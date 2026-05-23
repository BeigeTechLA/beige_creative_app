import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../app/colors.dart';
import 'package:beige_creative_app/app/assets.dart';

class CustomDropdown<T> extends StatefulWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final Widget? icon;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.icon,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {

  @override
  Widget build(BuildContext context) {
    bool highlight = widget.value != null;

    return DropdownButtonFormField<T>(
      value: widget.value,
      dropdownColor: AppColors.surfaceCropSheet,
      icon: Padding(
        padding: const EdgeInsets.only(right: 9),
        child: widget.icon ??
            SvgPicture.asset(
              AppAssets.dropdown, //  your svg path
              color: AppColors.white,
              width: 24,
              height: 24,
            ),
      ),
      style: const TextStyle(
        color: AppColors.white,
        fontFamily: "Outfit",
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: TextStyle(
          fontSize: 14,
          fontFamily: "Outfit",
          color: highlight
              ? AppColors.primary
              : AppColors.white60,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: highlight
                ? AppColors.textfieldBorderLegacy
                : AppColors.white60,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: highlight
                ? AppColors.textfieldBorderLegacy
                : AppColors.white30,
            width: 0.5,
          ),
        ),
      ),
      items: widget.items,
      onChanged: (val) {
        setState(() {});
        widget.onChanged?.call(val);
      },
    );
  }
}