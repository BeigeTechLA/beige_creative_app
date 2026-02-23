import 'package:flutter/material.dart';
import '../utility/ColorCode.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final bool isVisible;
  final VoidCallback? onToggle;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.isVisible = false,
    this.onToggle,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !isVisible : false,
      keyboardType: keyboardType,
      cursorColor: ColorCode.kWhiteOpacity70,
      style: const TextStyle(
        color: ColorCode.kWhiteOpacity70,
      ),
      decoration: InputDecoration(
        labelText: "$label*",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(
          color: ColorCode.kWhiteOpacity70,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        suffixIcon: isPassword
            ? IconButton(
          onPressed: onToggle,
          icon: Icon(
            isVisible
                ? Icons.visibility
                : Icons.visibility_off,
            color: ColorCode.kWhiteOpacity70,
            size: 20,
          ),
        )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kWhiteOpacity70,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kWhiteOpacity70,
            width: 0.5,
          ),
        ),
        floatingLabelStyle: const TextStyle(
          color: ColorCode.kWhiteOpacity70,
        ),
      ),
    );
  }
}