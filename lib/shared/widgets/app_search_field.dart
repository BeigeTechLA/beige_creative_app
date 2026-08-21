import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app/assets.dart';
import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';

/// Canonical search input widget for the application.
///
/// Guarantees exact vertical alignment of prefix icon, hint text, typing cursor,
/// and clear button within a design-token styled container.
class AppSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final double height;
  final Color? fillColor;
  final Color? borderColor;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final bool autofocus;

  const AppSearchField({
    super.key,
    this.controller,
    this.initialValue,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.height = 48,
    this.fillColor,
    this.borderColor,
    this.style,
    this.hintStyle,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    this.autofocus = false,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _internalController;
  late final FocusNode _internalFocusNode;
  bool _isInternalController = false;
  bool _isInternalFocusNode = false;

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController;
  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController(text: widget.initialValue);
      _isInternalController = true;
    }
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
      _isInternalFocusNode = true;
    }
    _effectiveController.addListener(_onTextChanged);
    _effectiveFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_onTextChanged);
    _effectiveFocusNode.removeListener(_onFocusChanged);
    if (_isInternalController) {
      _internalController.dispose();
    }
    if (_isInternalFocusNode) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _handleClear() {
    _effectiveController.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _effectiveController.text.isNotEmpty;
    final isFocused = _effectiveFocusNode.hasFocus;

    final effectiveFill = widget.fillColor ?? AppColors.surfaceMid;
    final effectiveBorderColor = widget.borderColor ??
        (isFocused ? AppColors.primary : AppColors.transparent);
    final effectiveRadius = widget.borderRadius ?? AppRadii.xlAll;
    final effectiveTextStyle =
        widget.style ?? AppTextStyles.body14.copyWith(color: AppColors.white);
    final effectiveHintStyle = widget.hintStyle ??
        AppTextStyles.bodyMedium.copyWith(color: AppColors.white50);

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: effectiveFill,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: effectiveBorderColor,
          width: isFocused ? 1.0 : 0.5,
        ),
      ),
      padding: widget.padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.prefixIcon ??
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: SvgPicture.asset(
                  AppAssets.searchIcon,
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white50,
                    BlendMode.srcIn,
                  ),
                ),
              ),
          Expanded(
            child: TextField(
              controller: _effectiveController,
              focusNode: _effectiveFocusNode,
              autofocus: widget.autofocus,
              style: effectiveTextStyle,
              cursorColor: AppColors.primary,
              textAlignVertical: TextAlignVertical.center,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: effectiveHintStyle,
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (widget.suffixIcon != null)
            widget.suffixIcon!
          else if (hasText)
            GestureDetector(
              onTap: _handleClear,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.only(left: AppSpacing.xs),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.white50,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
