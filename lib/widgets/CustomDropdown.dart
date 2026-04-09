import 'package:flutter/material.dart';
import '../utility/ColorCode.dart';

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
      dropdownColor: const Color(0xFF1C1C1C),
      icon: Padding(
        padding: const EdgeInsets.only(right: 9),
        child: widget.icon ??
            Icon(
              size: 29,
              Icons.keyboard_arrow_down,
              color: highlight
                  ? ColorCode.kButtonColor
                  : ColorCode.kWhiteOpacity70,
            ),
      ),
      style: const TextStyle(
        color: ColorCode.white,
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
              ? ColorCode.kButtonColor
              : ColorCode.kWhiteOpacity70,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: highlight
                ? ColorCode.textfieldbordercollor
                : ColorCode.kWhiteOpacity70,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: highlight
                ? ColorCode.textfieldbordercollor
                : ColorCode.kWhiteOpacity70,
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