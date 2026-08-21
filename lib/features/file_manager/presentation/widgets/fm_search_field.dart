import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../shared/widgets/app_search_field.dart';

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
    return AppSearchField(
      controller: _controller,
      hintText: widget.hintText,
      onChanged: (val) {
        widget.onChanged(val);
        setState(() {});
      },
      onClear: _onClear,
      fillColor: AppColors.surfaceInput,
      borderColor: AppColors.dividerDark,
      borderRadius: AppRadii.fullAll,
    );
  }
}

