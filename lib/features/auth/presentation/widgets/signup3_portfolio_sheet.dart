import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import 'package:beige_creative_app/app/assets.dart';
import '../../../../shared/widgets/app_cta_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import 'signup3_constants.dart';

class Signup3PortfolioSheetController {
  final List<Map<String, dynamic>> savedLinks;
  final TextEditingController nameController;
  final TextEditingController linkController;
  int selectedIndex;
  int? editingIndex;
  final void Function(List<Map<String, dynamic>> next) commitLinks;
  final void Function(String message) onError;

  Signup3PortfolioSheetController({
    required this.savedLinks,
    required this.nameController,
    required this.linkController,
    required this.selectedIndex,
    required this.editingIndex,
    required this.commitLinks,
    required this.onError,
  });
}

Future<void> showSignup3PortfolioSheet({
  required BuildContext context,
  required Signup3PortfolioSheetController controller,
}) {
  bool showForm =
      controller.savedLinks.isEmpty || controller.editingIndex != null;
  final localLinks = List<Map<String, dynamic>>.from(controller.savedLinks);

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 100),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceStats,
                  borderRadius: AppRadii.topHeader,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        margin: const EdgeInsets.only(bottom: AppSpacing.mld),
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
                          'Add Portfolio Links',
                          style: AppTextStyles.displayLabel16
                              .copyWith(color: AppColors.white),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: AppColors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add YouTube, Vimeo, or Google Drive links to showcase your portfolio.',
                      style: AppTextStyles.inherit13
                          .copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        kSignup3PortfolioIcons.length,
                        (index) => InkWell(
                          onTap: () {
                            setModalState(() {
                              controller.selectedIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              borderRadius: AppRadii.xlAll,
                              border: Border.all(
                                color: controller.selectedIndex == index
                                    ? AppColors.primary
                                    : AppColors.white24,
                              ),
                              color: controller.selectedIndex == index
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : AppColors.transparent,
                            ),
                            child: Center(
                              child: kSignup3PortfolioIcons[index]
                                      .endsWith('.svg')
                                  ? SvgPicture.asset(
                                      kSignup3PortfolioIcons[index],
                                      height: 22,
                                      width: 22,
                                      colorFilter: ColorFilter.mode(
                                        controller.selectedIndex == index
                                            ? AppColors.primary
                                            : AppColors.white,
                                        BlendMode.srcIn,
                                      ),
                                    )
                                  : Image.asset(
                                      kSignup3PortfolioIcons[index],
                                      height: 22,
                                      width: 22,
                                      color: controller.selectedIndex == index
                                          ? AppColors.primary
                                          : AppColors.white,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (localLinks.isNotEmpty) ...[
                      Text(
                        '${localLinks.length}/3',
                        style: AppTextStyles.body12
                            .copyWith(color: AppColors.white24),
                      ),
                      const SizedBox(height: 10),
                      ...localLinks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return _SavedPortfolioRow(
                          item: item,
                          onEdit: () {
                            setModalState(() {
                              showForm = true;
                              controller.editingIndex = index;
                              controller.selectedIndex =
                                  kSignup3PortfolioNames.indexOf(item['name']);
                              controller.linkController.text = item['url'];
                            });
                          },
                          onDelete: () {
                            final next = List<Map<String, dynamic>>.from(localLinks)
                              ..removeAt(index);
                            controller.commitLinks(next);
                            localLinks.clear();
                            localLinks.addAll(next);
                            setModalState(() {});
                          },
                        );
                      }),
                      const SizedBox(height: 10),
                    ],
                    if (showForm) ...[
                      CustomTextField(
                        label: 'Name of the Link',
                        controller: controller.linkController,
                      ),
                      const SizedBox(height: 24),
                      AppCtaButton(
                        label: 'Save Link',
                        height: 50,
                        onPressed: () {
                          if (controller.selectedIndex == -1 ||
                              controller.linkController.text
                                  .trim()
                                  .isEmpty) {
                            controller.onError(
                              'Select platform & enter link',
                            );
                            return;
                          }
                          final next = List<Map<String, dynamic>>.from(localLinks);
                          final entry = {
                            'name': kSignup3PortfolioNames[
                                controller.selectedIndex],
                            'url': controller.linkController.text.trim(),
                            'icon': kSignup3PortfolioIcons[
                                controller.selectedIndex],
                          };
                          if (controller.editingIndex != null) {
                            next[controller.editingIndex!] = entry;
                          } else {
                            next.add(entry);
                          }
                          controller.commitLinks(next);
                          localLinks.clear();
                          localLinks.addAll(next);
                          setModalState(() {
                            showForm = false;
                            controller.editingIndex = null;
                            controller.selectedIndex = -1;
                            controller.linkController.clear();
                          });
                        },
                      ),
                    ],
                    if (!showForm) ...[
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          setModalState(() {
                            showForm = true;
                            controller.editingIndex = null;
                            controller.selectedIndex = -1;
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
                      AppCtaButton(
                        label: 'Save',
                        height: 50,
                        onPressed: () => Navigator.pop(context),
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

class _SavedPortfolioRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SavedPortfolioRow({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final iconStr = signup3ResolveLinkIcon(
      item['icon']?.toString(),
      item['name']?.toString(),
    );
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.white24),
        color: AppColors.textSubtle,
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: AppRadii.lgAll,
              color: AppColors.surfaceMid,
            ),
            child: Transform.rotate(
              angle: pi / 2,
              child: const Icon(Icons.drag_indicator, size: 18),
            ),
          ),
          const SizedBox(width: 8),
          iconStr.endsWith('.svg')
              ? SvgPicture.asset(
                  iconStr,
                  height: 20,
                  width: 20,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
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
              padding: EdgeInsets.zero,
              icon: SvgPicture.asset(
                AppAssets.pencil,
                width: 18,
                height: 18,
              ),
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
              padding: EdgeInsets.zero,
              icon: SvgPicture.asset(
                AppAssets.delete,
                width: 18,
                height: 18,
              ),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
