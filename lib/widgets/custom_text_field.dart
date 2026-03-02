import 'package:flutter/material.dart';
import '../utility/ColorCode.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final bool isVisible;
  final VoidCallback? onToggle;
  final TextInputType keyboardType;
  final int maxLines;
  final Widget? suffixIcon;

  /// ✅ Add these properly
  final bool readOnly;
  final VoidCallback? onTap;

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
    this.readOnly = false,   // ✅ default false
    this.onTap,              // ✅ optional
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      obscureText: isPassword ? !isVisible : false,
      keyboardType: keyboardType,
      readOnly: readOnly,     // ✅ apply here
      onTap: onTap,           // ✅ apply here
      cursorColor: ColorCode.kWhiteOpacity70,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(
          color: ColorCode.kWhiteOpacity70,
          fontSize: 13,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kWhiteOpacity70,
            width: 0.6,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kWhiteOpacity70,
            width: 0.6,
          ),
        ),
      ),
    );
  }
}