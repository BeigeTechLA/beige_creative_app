import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/shadows.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_cta_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

typedef SocialLinkChange = void Function(VoidCallback mutator);

/// Body of the "Add Social Links" bottom sheet. State (lists + controllers +
/// selection indices) is owned by the parent and mutated in place; the sheet
/// requests a parent rebuild via [onParentMutate].
///
/// Lifted verbatim from `myprofile.dart::openSocialDialog` during 4.11 split.
class ProfileSocialLinksSheet extends StatefulWidget {
  final List<Map<String, String>> socialLinks;
  final List<String> socialNames;
  final List<String> socialIcons;
  final TextEditingController nameController;
  final TextEditingController linkController;
  final int initialSelectedSocialIndex;
  final int initialEditingIndex;
  final bool startInEditMode;
  final SocialLinkChange onParentMutate;
  final Future<void> Function() onSaveAll;
  final void Function(int updatedSelectedIndex, int updatedEditingIndex,
      bool isEditing) onSelectionChanged;

  const ProfileSocialLinksSheet({
    super.key,
    required this.socialLinks,
    required this.socialNames,
    required this.socialIcons,
    required this.nameController,
    required this.linkController,
    required this.initialSelectedSocialIndex,
    required this.initialEditingIndex,
    required this.startInEditMode,
    required this.onParentMutate,
    required this.onSaveAll,
    required this.onSelectionChanged,
  });

  @override
  State<ProfileSocialLinksSheet> createState() =>
      _ProfileSocialLinksSheetState();
}

class _ProfileSocialLinksSheetState extends State<ProfileSocialLinksSheet> {
  late bool showForm;
  late int selectedSocialIndex;
  late int editingIndex;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    selectedSocialIndex = widget.initialSelectedSocialIndex;
    editingIndex = widget.initialEditingIndex;
    showForm = widget.socialLinks.isEmpty || widget.startInEditMode;
    isEditing = widget.startInEditMode;
  }

  void _emitSelection() {
    widget.onSelectionChanged(selectedSocialIndex, editingIndex, isEditing);
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'Add Social Links',
                    style: AppTextStyles.displayLabel16,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.white),
                  ),
                ],
              ),
              const Text(
                'Add links that showcase your work, recognition,\npersonality and more!',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.dividerDark),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    widget.socialIcons.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(
                        right: index < widget.socialIcons.length - 1 ? 10.0 : 0.0,
                      ),
                      child: InkWell(
                        borderRadius: AppRadii.xxlAll,
                        onTap: () {
                          setState(() {
                            selectedSocialIndex = index;
                            widget.nameController.text = widget.socialNames[index];
                          });
                          _emitSelection();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: selectedSocialIndex == index
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : AppColors.transparent,
                            borderRadius: AppRadii.xxlAll,
                            border: Border.all(
                              color: selectedSocialIndex == index
                                  ? AppColors.primary
                                  : AppColors.white24,
                              width: selectedSocialIndex == index ? 1.5 : 0.8,
                            ),
                            boxShadow: selectedSocialIndex == index
                                ? AppShadows.goldCta
                                : const [],
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              widget.socialIcons[index],
                              height: 22,
                              width: 22,
                              colorFilter: ColorFilter.mode(
                                selectedSocialIndex == index
                                    ? AppColors.primary
                                    : AppColors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (!isEditing && widget.socialLinks.isNotEmpty) ...[
                Text(
                  '${widget.socialLinks.length}/6',
                  style: AppTextStyles.body12
                      .copyWith(color: AppColors.white24),
                ),
                const SizedBox(height: 10),
                ...widget.socialLinks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.smd,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.lgAll,
                      border: Border.all(color: AppColors.white24),
                      color: AppColors.black,
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
                            angle: 3.14159 / 2,
                            child: const Icon(
                              Icons.drag_indicator,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          item['icon']!,
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item['name']!,
                            style: AppTextStyles.body14Medium
                                .copyWith(color: AppColors.white),
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
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.white,
                              size: 16,
                            ),
                            onPressed: () {
                              setState(() {
                                showForm = true;
                                selectedSocialIndex = widget.socialNames
                                    .indexOf(item['name']!);
                                widget.nameController.text = item['name']!;
                                widget.linkController.text = item['url']!;
                              });
                              _emitSelection();
                            },
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
                            icon: const Icon(
                              Icons.delete,
                              color: AppColors.error,
                              size: 16,
                            ),
                            onPressed: () {
                              setState(() {
                                widget.onParentMutate(() {
                                  widget.socialLinks.removeAt(index);
                                });
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),
              ],
              if (showForm) ...[
                CustomTextField(
                  label: 'Name of the Link*',
                  controller: widget.nameController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Link URL*',
                  controller: widget.linkController,
                ),
                const SizedBox(height: 20),
                AppCtaButton(
                  label: 'Save Link',
                  height: 50,
                  onPressed: () {
                    if (selectedSocialIndex == -1 ||
                        widget.linkController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select platform and enter link',
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                    final name = widget.socialNames[selectedSocialIndex];
                    final icon = widget.socialIcons[selectedSocialIndex];
                    final url = widget.linkController.text.trim();

                    setState(() {
                      widget.onParentMutate(() {
                        if (editingIndex != -1) {
                          widget.socialLinks[editingIndex] = {
                            'name': name,
                            'url': url,
                            'icon': icon,
                          };
                        } else {
                          widget.socialLinks.add({
                            'name': name,
                            'url': url,
                            'icon': icon,
                          });
                        }
                      });
                      showForm = false;
                      selectedSocialIndex = -1;
                      isEditing = false;
                      editingIndex = -1;
                      widget.nameController.clear();
                      widget.linkController.clear();
                    });
                    _emitSelection();
                  },
                ),
              ],
              if (!showForm) ...[
                const SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    setState(() {
                      showForm = true;
                      selectedSocialIndex = -1;
                      widget.nameController.clear();
                      widget.linkController.clear();
                    });
                    _emitSelection();
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
                      const Text(
                        'Add another link',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCtaButton(
                  label: 'Save',
                  height: 50,
                  onPressed: widget.onSaveAll,
                ),
              ],
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
