import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';
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
      key: ValueKey(widget.value),
      initialValue: widget.value,
      dropdownColor: AppColors.surfaceCropSheet,
      icon: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.dropdownIconInset),
        child:
            widget.icon ??
            SvgPicture.asset(
              AppAssets.dropdown,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
              width: 24,
              height: 24,
            ),
      ),
      style: AppTextStyles.body15.copyWith(color: AppColors.white),
      decoration: InputDecoration(
        labelText: widget.label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: AppTextStyles.body14.copyWith(
          color: highlight ? AppColors.primary : AppColors.white60,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputHorizontal,
          vertical: AppSpacing.lg,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.xlAll,
          borderSide: BorderSide(
            color: highlight
                ? AppColors.textfieldBorderLegacy
                : AppColors.white60,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.xlAll,
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
