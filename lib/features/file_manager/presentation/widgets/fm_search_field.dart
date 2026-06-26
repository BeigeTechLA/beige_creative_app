import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

/// Search input shared by root + folder-details screens. Client-side filter
/// only — emits raw text via [onChanged]; the notifier holds debounce
/// semantics if/when needed.
class FmSearchField extends StatefulWidget {
  final String hintText;
  final String initialValue;
  final ValueChanged<String> onChanged;

  const FmSearchField({
    super.key,
    required this.onChanged,
    this.hintText = 'Search',
    this.initialValue = '',
  });

  @override
  State<FmSearchField> createState() => _FmSearchFieldState();
}

class _FmSearchFieldState extends State<FmSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onClear() {
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;
    return TextField(
      controller: _controller,
      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
      cursorColor: AppColors.primary,
      onChanged: (v) {
        widget.onChanged(v);
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textTertiary,
          size: 20,
        ),
        suffixIcon: hasText
            ? IconButton(
                tooltip: 'Clear search',
                icon: const Icon(
                  Icons.close,
                  color: AppColors.textTertiary,
                  size: 18,
                ),
                onPressed: _onClear,
              )
            : null,
        filled: true,
        fillColor: AppColors.surfaceInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputHorizontal,
          vertical: AppSpacing.inputVertical,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.fullAll,
          borderSide: const BorderSide(color: AppColors.dividerDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.fullAll,
          borderSide: const BorderSide(color: AppColors.dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.fullAll,
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
