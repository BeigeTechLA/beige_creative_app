import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utility/colorcode.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final bool isVisible;
  final VoidCallback? onToggle;
  final TextInputType keyboardType;
  final int maxLines;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.isVisible = false,
    this.onToggle,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.autofillHints,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
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
  void didUpdateWidget(CustomTextField oldWidget) {


    super.didUpdateWidget(oldWidget);
    if (oldWidget.isVisible != widget.isVisible) {
      setState(() {});
    }
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
      cursorColor: ColorCode.kButtonColor,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      maxLines: widget.maxLines,
      inputFormatters: widget.inputFormatters,
      enableSuggestions: false,   // ✅ ADD THIS
      autocorrect: false,
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
          color: highlight
              ? ColorCode.kButtonColor
              : ColorCode.kWhiteOpacity_60,
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
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color:ColorCode.kGoldBorder50,
            width: 0.5,
          ),
        ),
        suffixIcon: widget.suffixIcon,


      ),
    );
  }
}