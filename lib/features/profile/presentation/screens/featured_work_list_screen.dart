import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/route_names.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../widgets/app_loder.dart';
import '../../../../widgets/top_message.dart';
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
      enterWorkTitleController.text = title;
      editingImages = List.from(images);
      tempFeaturedImages.clear();
    });
    _openUploadSheet();
  }

  Future<void> _onNavigate(String title, List<dynamic> images) async {
    final result = await context.pushNamed(
      RouteNames.featuredWorkDetails,
      extra: {'title': title, 'images': images},
    );
    if (result == true) {
      ref.read(featuredWorkNotifierProvider.notifier).refresh();
    }
  }

  void _openUploadSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (_) => FeaturedWorkUploadSheet(
        titleController: enterWorkTitleController,
        tempFeaturedImages: tempFeaturedImages,
        editingImages: editingImages,
        onSavePressed: _onSavePressed,
      ),
    );
  }

  Future<void> _onSavePressed() async {
    if (enterWorkTitleController.text.trim().isEmpty) {
      _showSnack('Please enter title');
      return;
    }
    final totalImages = editingImages.length + tempFeaturedImages.length;
    if (totalImages < 5) {
      _showSnack('Minimum 5 images required');
      return;
    }
    if (tempFeaturedImages.isEmpty) {
      if (!mounted) return;
      context.pop();
      return;
    }
    final ok = await ref.read(featuredWorkNotifierProvider.notifier).upload(
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

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardCompactInset),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => context.pop(),
                        child: SvgPicture.asset(
                          AppAssets.back,
                          height: 24,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Text(
                        'Featured work',
                        style: AppTextStyles.displayLabel16,
                      ),
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
          ),
          if (state.isLoading) AppLoader(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardCompactInset),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: AppRadii.xxlAll),
            ),
            onPressed: _openUploadSheet,
            child: const Text(
              'Add Featured Works',
              style: AppTextStyles.displayLabel14,
            ),
          ),
        ),
      ),
    );
  }
}
