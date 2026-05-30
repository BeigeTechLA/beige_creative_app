import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../widgets/custom_text_field.dart';

typedef PortfolioLinkChange = void Function(VoidCallback mutator);

typedef PortfolioSaveLink = Future<void> Function({
  required void Function(bool) setUpdating,
  required bool Function() getUpdating,
  VoidCallback? onAdded,
});

/// Body of the "Add Portfolio Links" bottom sheet. Mirrors the social sheet
/// shape — parent owns mutable state, sheet mutates in place via callbacks.
class ProfilePortfolioLinksSheet extends StatefulWidget {
  final List<Map<String, String>> portfolioLinks;
  final List<String> portfolioNames;
  final List<String> portfolioIcons;
  final TextEditingController nameController;
  final TextEditingController linkController;
  final int initialSelectedPortfolioIndex;
  final int initialEditingIndex;
  final bool startInEditMode;
  final PortfolioLinkChange onParentMutate;
  final PortfolioSaveLink onSaveLink;
  final Future<void> Function() onSaveAll;
  final void Function(int updatedSelectedIndex, int updatedEditingIndex)
      onSelectionChanged;

  const ProfilePortfolioLinksSheet({
    super.key,
    required this.portfolioLinks,
    required this.portfolioNames,
    required this.portfolioIcons,
    required this.nameController,
    required this.linkController,
    required this.initialSelectedPortfolioIndex,
    required this.initialEditingIndex,
    required this.startInEditMode,
    required this.onParentMutate,
    required this.onSaveLink,
    required this.onSaveAll,
    required this.onSelectionChanged,
  });

  @override
  State<ProfilePortfolioLinksSheet> createState() =>
      _ProfilePortfolioLinksSheetState();
}

class _ProfilePortfolioLinksSheetState
    extends State<ProfilePortfolioLinksSheet> {
  late bool showForm;
  late int selectedPortfolioIndex;
  late int editingIndex;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    selectedPortfolioIndex = widget.initialSelectedPortfolioIndex;
    editingIndex = widget.initialEditingIndex;
    showForm = widget.portfolioLinks.isEmpty || widget.startInEditMode;
  }

  void _emitSelection() {
    widget.onSelectionChanged(selectedPortfolioIndex, editingIndex);
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
                  const Text(
                    'Add Portfolio Links',
                    style: AppTextStyles.displayLabel16,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.white),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Add YouTube, Vimeo, or Google Drive links to showcase your portfolio.',
                style: AppTextStyles.inherit13,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  widget.portfolioIcons.length,
                  (index) => InkWell(
                    onTap: () {
                      setState(() {
                        showForm = true;
                        editingIndex = -1;
                        selectedPortfolioIndex = index;
                        widget.nameController.text =
                            widget.portfolioNames[index];
                        widget.linkController.clear();
                      });
                      _emitSelection();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        borderRadius: AppRadii.xlAll,
                        border: Border.all(
                          color: selectedPortfolioIndex == index
                              ? AppColors.primary
                              : AppColors.white24,
                        ),
                        color: selectedPortfolioIndex == index
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.transparent,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          widget.portfolioIcons[index],
                          height: 22,
                          width: 22,
                          colorFilter: ColorFilter.mode(
                            selectedPortfolioIndex == index
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
              const SizedBox(height: 20),
              if (!showForm &&
                  editingIndex == -1 &&
                  widget.portfolioLinks.isNotEmpty) ...[
                Text(
                  '${widget.portfolioLinks.length}/3',
                  style: AppTextStyles.body12
                      .copyWith(color: AppColors.white24),
                ),
                const SizedBox(height: 10),
                ...widget.portfolioLinks.asMap().entries.map((entry) {
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
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: AppRadii.lgAll,
                            color: AppColors.surfaceMid,
                          ),
                          child: Transform.rotate(
                            angle: 3.14159 / 2,
                            child: const Icon(
                              Icons.drag_indicator,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          item['icon']!,
                          height: 20,
                          width: 20,
                          color: AppColors.primary,
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
                                selectedPortfolioIndex =
                                    widget.portfolioNames.indexWhere(
                                  (e) =>
                                      e.toLowerCase() ==
                                      item['name']!.toLowerCase(),
                                );
                                if (selectedPortfolioIndex == -1) {
                                  selectedPortfolioIndex = 0;
                                }
                                widget.nameController.text = item['name']!;
                                widget.linkController.text = item['url']!;
                                editingIndex = index;
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
                                  widget.portfolioLinks.removeAt(index);
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
                  label: 'Link URL',
                  controller: widget.linkController,
                ),
                const SizedBox(height: 24),
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
                    onPressed: isUpdating
                        ? null
                        : () => widget.onSaveLink(
                              setUpdating: (val) =>
                                  setState(() => isUpdating = val),
                              getUpdating: () => isUpdating,
                              onAdded: () =>
                                  setState(() => showForm = false),
                            ),
                    child: isUpdating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.black,
                            ),
                          )
                        : const Text(
                            'Save Link',
                            style: AppTextStyles.buttonMedium,
                          ),
                  ),
                ),
              ],
              if (!showForm) ...[
                const SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    setState(() {
                      showForm = true;
                      editingIndex = -1;
                      selectedPortfolioIndex = 0;
                      widget.nameController.text =
                          widget.portfolioNames[selectedPortfolioIndex];
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
                if (editingIndex == -1)
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
                      onPressed: widget.onSaveAll,
                      child: const Text(
                        'Save',
                        style: AppTextStyles.buttonMedium,
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
  }
}
