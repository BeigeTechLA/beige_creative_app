import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';

/// Generic checkbox-list bottom sheet used by SignUp2 for Roles + Skills.
/// Caller toggles selections via [onToggle]; sheet drives an internal
/// [StatefulBuilder] so the checkbox state animates immediately without
/// round-tripping to the parent.
Future<void> showSignUp2LookupSheet({
  required BuildContext context,
  required String title,
  required List<String> options,
  required List<String> initiallySelected,
  required void Function(String name, bool selected) onToggle,
}) {
  FocusScope.of(context).unfocus();
  final selected = {...initiallySelected};

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surfaceCropSheet,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: AppRadii.topHuge),
    builder: (sheetCtx) {
      return StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.base,
              AppSpacing.base,
              AppSpacing.xxl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.white24,
                    borderRadius: AppRadii.xsAll,
                  ),
                ),
                Text(
                  title,
                  style: AppTextStyles.bodyLargeMedium
                      .copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (_, index) {
                      final name = options[index];
                      final isSelected = selected.contains(name);
                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(
                          name,
                          style: AppTextStyles.body14Medium
                              .copyWith(color: AppColors.white),
                        ),
                        activeColor: AppColors.primary,
                        checkColor: AppColors.black,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.lavenderGrey,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.smAll,
                        ),
                        onChanged: (val) {
                          final next = val ?? false;
                          setSheetState(() {
                            if (next) {
                              selected.add(name);
                            } else {
                              selected.remove(name);
                            }
                          });
                          onToggle(name, next);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(sheetCtx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.lgAll,
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: AppTextStyles.body15
                          .copyWith(color: AppColors.textHeading),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
