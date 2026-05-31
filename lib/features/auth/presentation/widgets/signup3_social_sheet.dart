import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/shadows.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import 'signup3_constants.dart';

/// Parameters shared between the bottom-sheet body and its parent state.
/// Mutating handlers commit changes back to the parent via callbacks.
class Signup3SocialSheetController {
  final List<Map<String, dynamic>> savedLinks;
  final TextEditingController nameLinkController;
  final TextEditingController linkController;
  int selectedSocialIndex;
  int? editingIndex;
  final void Function(List<Map<String, dynamic>> next) commitLinks;
  final void Function(String message) onError;

  Signup3SocialSheetController({
    required this.savedLinks,
    required this.nameLinkController,
    required this.linkController,
    required this.selectedSocialIndex,
    required this.editingIndex,
    required this.commitLinks,
    required this.onError,
  });
}

Future<void> showSignup3SocialSheet({
  required BuildContext context,
  required Signup3SocialSheetController controller,
}) {
  bool showForm = controller.savedLinks.isEmpty;

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setInnerState) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 100),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppRadii.topMassive,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 5,
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
                        Text(
                          'Add Social Links',
                          style: AppTextStyles.displayLabel16
                              .copyWith(color: AppColors.white),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon:
                              const Icon(Icons.close, color: AppColors.white),
                        ),
                      ],
                    ),
                    Text(
                      'Add links that showcase your work, recognition,personality and more!',
                      style: AppTextStyles.body12
                          .copyWith(color: AppColors.white30),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: AppColors.dividerDark),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        kSignup3SocialIcons.length,
                        (i) => _SocialIconTile(
                          index: i,
                          imagePath: kSignup3SocialIcons[i],
                          isSelected: controller.selectedSocialIndex == i,
                          onTap: () {
                            setInnerState(() {
                              controller.selectedSocialIndex = i;
                              controller.nameLinkController.text =
                                  kSignup3SocialNames[i];
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (controller.savedLinks.isNotEmpty) ...[
                      Text(
                        '${controller.savedLinks.length}/6',
                        style: AppTextStyles.body12
                            .copyWith(color: AppColors.white24),
                      ),
                      const SizedBox(height: 10),
                      ...controller.savedLinks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return _SavedSocialRow(
                          item: item,
                          onEdit: () {
                            setInnerState(() {
                              showForm = true;
                              controller.editingIndex = index;
                              controller.selectedSocialIndex =
                                  kSignup3SocialNames.indexOf(item['name']);
                              controller.nameLinkController.text =
                                  item['name'];
                              controller.linkController.text = item['url'];
                            });
                          },
                          onDelete: () {
                            final next = [...controller.savedLinks]
                              ..removeAt(index);
                            controller.commitLinks(next);
                            setInnerState(() {});
                          },
                        );
                      }),
                      const SizedBox(height: 10),
                    ],
                    if (showForm) ...[
                      CustomTextField(
                        label: 'Name of the Link*',
                        controller: controller.nameLinkController,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Behance / X, Instagram, etc.',
                        controller: controller.linkController,
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.xlAll,
                            ),
                          ),
                          onPressed: () {
                            if (controller.selectedSocialIndex == -1 ||
                                controller.linkController.text
                                    .trim()
                                    .isEmpty) {
                              controller.onError(
                                'Please select platform and enter link',
                              );
                              return;
                            }
                            final platformName = kSignup3SocialNames[
                                controller.selectedSocialIndex];
                            final iconPath = kSignup3SocialIcons[
                                controller.selectedSocialIndex];
                            final url = controller.linkController.text.trim();
                            final next = [...controller.savedLinks];
                            if (controller.editingIndex != null) {
                              next[controller.editingIndex!] = {
                                'name': platformName,
                                'url': url,
                                'icon': iconPath,
                              };
                            } else {
                              next.add({
                                'name': platformName,
                                'url': url,
                                'icon': iconPath,
                              });
                            }
                            controller.commitLinks(next);
                            setInnerState(() {
                              showForm = false;
                              controller.editingIndex = null;
                              controller.selectedSocialIndex = -1;
                              controller.nameLinkController.clear();
                              controller.linkController.clear();
                            });
                          },
                          child: Text(
                            'Save Link',
                            style: AppTextStyles.inheritSemiBold
                                .copyWith(color: AppColors.black),
                          ),
                        ),
                      ),
                    ],
                    if (!showForm) ...[
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          setInnerState(() {
                            showForm = true;
                            controller.selectedSocialIndex = -1;
                            controller.nameLinkController.clear();
                            controller.linkController.clear();
                          });
                        },
                        child: Row(
                          children: [
                            Container(
                              height: 30,
                              width: 30,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.white,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: AppColors.black,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Add another link',
                              style: AppTextStyles.body14
                                  .copyWith(color: AppColors.white30),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.xlAll,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Save',
                            style: AppTextStyles.inheritSemiBold
                                .copyWith(color: AppColors.black),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class _SocialIconTile extends StatelessWidget {
  final int index;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _SocialIconTile({
    required this.index,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadii.xxlAll,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.transparent,
          borderRadius: AppRadii.xxlAll,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.white24,
            width: isSelected ? 1.5 : 0.8,
          ),
          boxShadow: isSelected ? AppShadows.goldCta : const [],
        ),
        child: Center(
          child: imagePath.endsWith('.svg')
              ? SvgPicture.asset(
                  imagePath,
                  height: 22,
                  width: 22,
                  colorFilter: ColorFilter.mode(
                    isSelected ? AppColors.primary : AppColors.white,
                    BlendMode.srcIn,
                  ),
                )
              : Image.asset(
                  imagePath,
                  height: 22,
                  width: 22,
                  color: isSelected ? AppColors.primary : AppColors.white,
                ),
        ),
      ),
    );
  }
}

class _SavedSocialRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SavedSocialRow({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final iconStr = item['icon'].toString();
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.white24),
        color: AppColors.black10,
      ),
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.09,
            height: MediaQuery.of(context).size.width * 0.09,
            decoration: BoxDecoration(
              borderRadius: AppRadii.lgAll,
              color: AppColors.surfaceMid,
            ),
            child: Transform.rotate(
              angle: pi / 2,
              child: const Icon(
                Icons.drag_indicator,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          iconStr.endsWith('.svg')
              ? SvgPicture.asset(
                  iconStr,
                  height: 20,
                  width: 20,
                  colorFilter: const ColorFilter.mode(
                    AppColors.borderGold,
                    BlendMode.srcIn,
                  ),
                )
              : Image.asset(
                  iconStr,
                  height: 20,
                  width: 20,
                  color: AppColors.white,
                ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item['name'],
              style: AppTextStyles.inherit.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
                fontFamily: AppTextStyles.fontFamilyBody,
              ),
            ),
          ),
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: AppRadii.lgAll,
              color: AppColors.surfaceMid,
            ),
            child: IconButton(
              icon: SvgPicture.asset(AppAssets.Pencil),
              onPressed: onEdit,
            ),
          ),
          const SizedBox(width: 7),
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: AppRadii.lgAll,
              color: AppColors.surfaceMid,
            ),
            child: IconButton(
              icon: SvgPicture.asset(AppAssets.delete),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
