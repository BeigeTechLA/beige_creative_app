import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utility/colorcode.dart';

class CustomInputField extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final bool isPassword;
  final bool isVisible;
  final VoidCallback? onToggle;
  final TextInputType keyboardType;
  final Iterable<String>? autofillHints;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;

  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  const CustomInputField({
    super.key,
    required this.title,
    required this.controller,
    this.isPassword = false,
    this.isVisible = false,
    this.onToggle,
    this.keyboardType = TextInputType.text,
    this.autofillHints, this.suffixIcon, this.onTap,  this.readOnly =false,   this.maxLines = 1, this.inputFormatters,
    this.onChanged,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      setState(() {});
    });

    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {

    bool isFocused = _focusNode.hasFocus;
    bool hasText = widget.controller.text.isNotEmpty;

    bool highlight = isFocused || hasText;

    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      obscureText: widget.isPassword ? !widget.isVisible : false,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,        // ✅
      onSubmitted: widget.onFieldSubmitted,           // ✅
      cursorColor: ColorCode.kButtonColor,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.maxLines,


      style: const TextStyle(
        color: ColorCode.white,
        fontFamily: "Outfit",
        fontSize: 15,
      ),

      decoration: InputDecoration(
        labelText: widget.title,
        floatingLabelBehavior: FloatingLabelBehavior.always,


        labelStyle: TextStyle(
          fontSize: 14,
          color: highlight
              ? ColorCode.kButtonColor
              : ColorCode.kWhiteOpacity60,
          fontFamily: "Outfit",
        ),

        contentPadding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 18),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: highlight
                ? ColorCode.kGoldBorder50
                : ColorCode.kWhiteOpacity30,
            width: 0.5,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kGoldBorder50,
            width: 0.5,
          ),
        ),

        suffixIcon: widget.suffixIcon,
      ),
    );
  }
}


