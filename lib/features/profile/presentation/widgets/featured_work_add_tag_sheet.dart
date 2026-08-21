import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_cta_button.dart';

/// Bottom-sheet body for adding / editing tags on the featured-work form.
/// Lifted from the orchestrator's `_openAddTagSheet` method (lines ~1467-1684)
/// during 4.08 split.
///
/// Internal `tempTags` list tracks pending edits; `onSave` fires on confirm
/// with the final list, letting the parent push it into shared state.
class FeaturedWorkAddTagSheet extends StatefulWidget {
  final List<String> initialTags;
  final void Function(List<String> tags) onSave;

  const FeaturedWorkAddTagSheet({
    super.key,
    required this.initialTags,
    required this.onSave,
  });

  @override
  State<FeaturedWorkAddTagSheet> createState() =>
      _FeaturedWorkAddTagSheetState();
}

class _FeaturedWorkAddTagSheetState extends State<FeaturedWorkAddTagSheet> {
  late final TextEditingController _tagController;
  late final List<String> _tempTags;

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController();
    _tempTags = List.of(widget.initialTags);
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: const BoxDecoration(
          color: AppColors.surfaceStats,
          borderRadius: AppRadii.topMassive,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white24,
                  borderRadius: AppRadii.xsAll,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Add Tag', style: AppTextStyles.displayStrong16),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Help people find your work',
              style: AppTextStyles.bodyCompact.copyWith(
                color: AppColors.white24,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type tag and press + or Enter',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white24,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base,
                        vertical: AppSpacing.smd,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadii.lgAll,
                        borderSide: const BorderSide(color: AppColors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadii.lgAll,
                        borderSide: const BorderSide(color: AppColors.white),
                      ),
                    ),
                    onSubmitted: (value) {
                      final tag = value.trim();
                      if (tag.isNotEmpty && !_tempTags.contains(tag)) {
                        setState(() {
                          _tempTags.add(tag);
                          _tagController.clear();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_tempTags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tempTags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: AppRadii.hugeAll,
                      border: Border.all(color: AppColors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tag,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _tempTags.remove(tag)),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: AppColors.white24,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),
            AppCtaButton(
              label: 'Save',
              height: 50,
              onPressed: () {
                final current = _tagController.text.trim();
                if (current.isNotEmpty && !_tempTags.contains(current)) {
                  _tempTags.add(current);
                  _tagController.clear();
                }
                widget.onSave(List<String>.of(_tempTags));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
