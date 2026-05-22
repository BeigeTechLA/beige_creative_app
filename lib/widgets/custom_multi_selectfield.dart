import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;

import '../utility/colorcode.dart';
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
  State<CustomMultiSelectField> createState() =>
      _CustomMultiSelectFieldState();
}

class _CustomMultiSelectFieldState
    extends State<CustomMultiSelectField> {

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

    bool highlight =
        _focusNode.hasFocus || widget.hasValue;

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

          style: const TextStyle(
            color: ColorCode.white,
            fontFamily: "Outfit",
            fontSize: 15,
          ),

          decoration: InputDecoration(

            labelText: widget.label,

            floatingLabelBehavior:
            FloatingLabelBehavior.always,

            labelStyle: TextStyle(
              fontSize: 14,
              fontFamily: "Outfit",
              color: highlight
                  ? ColorCode.kButtonColor
                  : ColorCode.kWhiteOpacity_60,
            ),

            hintText:
            widget.hasValue
                ? widget.value
                : "Select",

            hintStyle: TextStyle(
              color: widget.hasValue
                  ? ColorCode.white
                  : ColorCode.kWhiteOpacity_60,
            ),

            /// ✅ PREFIX ICON
            prefixIcon: widget.prefixIcon,

            contentPadding:
            const EdgeInsets.symmetric(
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
              borderSide: const BorderSide(
                color: ColorCode.textfieldbordercollor,
                width: 1,
              ),
            ),

            suffixIcon: Padding(
              padding: const EdgeInsets.all(18.0),

              child: SvgPicture.asset(
                AppAssets.dropdown,
                color: ColorCode.white,
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