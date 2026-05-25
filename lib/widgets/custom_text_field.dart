import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/colors.dart';

import '../app/radii.dart';
import '../app/spacing.dart';
import '../app/text_styles.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool isPassword;
  final bool isVisible;
  final VoidCallback? onToggle;
  final TextInputType keyboardType;
  final int maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final VoidCallback? onTap;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.focusNode,
    this.isPassword = false,
    this.isVisible = false,
    this.onToggle,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.onTap,
    this.autofillHints,
    this.inputFormatters,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _internalFocusNode;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();

    _internalFocusNode = FocusNode();

    _effectiveFocusNode.addListener(_refresh);
    widget.controller?.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode).removeListener(_refresh);

      _effectiveFocusNode.addListener(_refresh);
    }

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_refresh);
      widget.controller?.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_refresh);
    widget.controller?.removeListener(_refresh);

    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }

    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _effectiveFocusNode.hasFocus;
    final bool hasText = widget.controller?.text.isNotEmpty ?? false;

    final bool highlight = isFocused || hasText;

    return TextFormField(
      controller: widget.controller,
      focusNode: _effectiveFocusNode,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      onTap: widget.onTap,
      obscureText: widget.isPassword ? !widget.isVisible : false,
      keyboardType: widget.keyboardType,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatters,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
      cursorColor: AppColors.primary,

      enableSuggestions: !widget.isPassword,
      autocorrect: !widget.isPassword,

      style: AppTextStyles.body15.copyWith(color: AppColors.white),

      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,

        floatingLabelBehavior: FloatingLabelBehavior.always,

        labelStyle: AppTextStyles.body14.copyWith(
          color: highlight ? AppColors.primary : AppColors.white60,
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputHorizontal,
          vertical: AppSpacing.lg,
        ),

        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,

        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgAll,
          borderSide: BorderSide(
            color: highlight ? AppColors.borderGold : AppColors.white30,
            width: 0.5,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgAll,
          borderSide: const BorderSide(color: AppColors.borderGold, width: 0.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgAll,
          borderSide: const BorderSide(color: AppColors.error, width: 0.8),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgAll,
          borderSide: const BorderSide(color: AppColors.error, width: 0.8),
        ),
      ),
    );
  }
}
