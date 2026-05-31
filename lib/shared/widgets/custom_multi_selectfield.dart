import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;

import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart' show AppAssets;

class CustomMultiSelectField extends StatefulWidget {
  final String label;
  final String value;
  final bool hasValue;

  /// ✅ SVG / ICON SUPPORT
  final Widget? prefixIcon;

  /// ✅ Future callback
  final Future<void> Function() onTap;

  const CustomMultiSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.hasValue,
    required this.onTap,
    this.prefixIcon,
  });

  @override
  State<CustomMultiSelectField> createState() => _CustomMultiSelectFieldState();
}

class _CustomMultiSelectFieldState extends State<CustomMultiSelectField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool highlight = _focusNode.hasFocus || widget.hasValue;

    return GestureDetector(
      onTap: () async {
        _focusNode.requestFocus();

        /// ✅ wait until bottomsheet closes
        await widget.onTap();

        _focusNode.unfocus();
      },

      child: AbsorbPointer(
        child: TextField(
          focusNode: _focusNode,

          style: AppTextStyles.body15.copyWith(color: AppColors.white),

          decoration: InputDecoration(
            labelText: widget.label,

            floatingLabelBehavior: FloatingLabelBehavior.always,

            labelStyle: AppTextStyles.body14.copyWith(
              color: highlight ? AppColors.primary : AppColors.white60,
            ),

            hintText: widget.hasValue ? widget.value : "Select",

            hintStyle: AppTextStyles.inherit.copyWith(
              color: widget.hasValue ? AppColors.white : AppColors.white60,
            ),

            /// ✅ PREFIX ICON
            prefixIcon: widget.prefixIcon,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.inputHorizontal,
              vertical: AppSpacing.lg,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadii.xlAll,
              borderSide: BorderSide(
                color: highlight
                    ? AppColors.textfieldBorderLegacy
                    : AppColors.white30,
                width: 0.5,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadii.xlAll,
              borderSide: const BorderSide(
                color: AppColors.textfieldBorderLegacy,
                width: 1,
              ),
            ),

            suffixIcon: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),

              child: SvgPicture.asset(
                AppAssets.dropdown,
                color: AppColors.white,
                width: 24,
                height: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
