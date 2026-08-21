import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige_creative_app/shared/widgets/app_icon_tap_target.dart';
import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../routes/profile_args.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/loading.dart';
import '../../../../shared/widgets/app_cta_button.dart';
import '../../../../shared/widgets/top_message.dart';
import '../providers/profile_files_providers.dart';
import '../widgets/featured_work_grid.dart';
import '../widgets/featured_work_upload_sheet.dart';

class FeaturedWorkList extends ConsumerStatefulWidget {
  const FeaturedWorkList({super.key});

  @override
  ConsumerState<FeaturedWorkList> createState() => _FeaturedWorkListState();
}

class _FeaturedWorkListState extends ConsumerState<FeaturedWorkList> {
  final List<File> tempFeaturedImages = [];
  final List<String> selectedTags = [];
  List<dynamic> editingImages = [];
  bool isEditMode = false;
  bool isSaving = false;

  final TextEditingController enterWorkTitleController =
      TextEditingController();

  @override
  void dispose() {
    enterWorkTitleController.dispose();
    super.dispose();
  }

  void _showSnack(String message) => TopMessage.show(context, message);

  void _onEditTapped(String title, List<dynamic> images) {
    setState(() {
      isEditMode = true;
      isSaving = false;
      enterWorkTitleController.text = title;
      editingImages = List.from(images);
      tempFeaturedImages.clear();
    });
    _openUploadSheet();
  }

  Future<void> _onNavigate(String title, List<dynamic> images) async {
    final result = await context.pushNamed(
      Routes.featuredWorkDetails.name,
      extra: FeaturedWorkDetailsArgs(title: title, images: images).toExtra(),
    );
    if (result == true) {
      ref.read(featuredWorkNotifierProvider.notifier).refresh();
    }
  }

  void _onAddTapped() {
    setState(() {
      isEditMode = false;
      isSaving = false;
      enterWorkTitleController.clear();
      editingImages.clear();
      tempFeaturedImages.clear();
      selectedTags.clear();
    });
    _openUploadSheet();
  }

  void _openUploadSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return FeaturedWorkUploadSheet(
            titleController: enterWorkTitleController,
            tempFeaturedImages: tempFeaturedImages,
            editingImages: editingImages,
            isSaving: isSaving,
            onSavePressed: () async {
              await _onSavePressed(setSheetState);
            },
          );
        },
      ),
    );
  }

  Future<void> _onSavePressed(StateSetter setSheetState) async {
    if (isSaving) return;
    if (enterWorkTitleController.text.trim().isEmpty) {
      _showSnack('Please enter title');
      return;
    }
    final totalImages = editingImages.length + tempFeaturedImages.length;
    if (totalImages == 0) {
      _showSnack('Please select at least 1 image');
      return;
    }
    if (totalImages > 5) {
      _showSnack('Maximum 5 images allowed');
      return;
    }
    if (tempFeaturedImages.isEmpty) {
      if (!mounted) return;
      context.pop();
      return;
    }

    setSheetState(() {
      isSaving = true;
    });

    try {
      final ok = await ref
          .read(featuredWorkNotifierProvider.notifier)
          .upload(
            title: enterWorkTitleController.text.trim(),
            tags: List<String>.from(selectedTags),
            files: List<File>.from(tempFeaturedImages),
          );
      if (!mounted) return;
      if (ok) {
        setState(() {
          tempFeaturedImages.clear();
          editingImages.clear();
          selectedTags.clear();
          isEditMode = false;
        });
        enterWorkTitleController.clear();
        context.pop();
      }
    } finally {
      if (mounted) {
        setSheetState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> _onDelete(List<dynamic> images) async {
    final ids = images
        .map((img) => img.crewFilesId as int)
        .toList(growable: false);
    await ref.read(featuredWorkNotifierProvider.notifier).deleteMany(ids);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<FeaturedWorkState>(featuredWorkNotifierProvider, (prev, next) {
      final msg = next.errorMessage;
      if (msg != null && msg != prev?.errorMessage) {
        TopMessage.show(context, msg);
      }
    });

    final state = ref.watch(featuredWorkNotifierProvider);

    return AppScaffold(
      safeBottomNavigationBar: true,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardCompactInset),
            child: Column(
              children: [
                Row(
                  children: [
                    AppIconTapTarget(
                      semanticLabel: 'Back',
                      onTap: () => context.pop(),
                      icon: SvgPicture.asset(
                        AppAssets.back,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Text('Featured work', style: AppTextStyles.displayLabel16),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: FeaturedWorkGrid(
                    featuredWorkFiles: state.files,
                    onEdit: _onEditTapped,
                    onDelete: _onDelete,
                    onNavigate: _onNavigate,
                  ),
                ),
              ],
            ),
          ),
          if (state.isLoading) const AppLoader(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardCompactInset),
        child: AppCtaButton(
          label: 'Add Featured Works',
          height: 50,
          onPressed: _onAddTapped,
        ),
      ),
    );
  }
}
