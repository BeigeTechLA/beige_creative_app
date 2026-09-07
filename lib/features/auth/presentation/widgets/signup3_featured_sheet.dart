import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_cta_button.dart';
import '../../../../shared/widgets/common_uploader.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class Signup3FeaturedSheetController {
  final TextEditingController titleController;
  List<File> tempImages;
  int? editingProjectIndex;
  final List<List<File>> featuredProjects;
  final List<String> featuredProjectsTitles;
  List<String> selectedTags;
  final void Function(
    List<List<File>> projects,
    List<String> titles,
  ) commit;
  final Future<bool> Function({
    required String title,
    required List<File> files,
    int? editIndex,
  })? onUploadAndSave;
  final void Function(String message) onError;

  Signup3FeaturedSheetController({
    required this.titleController,
    required this.tempImages,
    required this.editingProjectIndex,
    required this.featuredProjects,
    required this.featuredProjectsTitles,
    required this.selectedTags,
    required this.commit,
    this.onUploadAndSave,
    required this.onError,
  });
}
Future<void> showSignup3FeaturedSheet({
  required BuildContext context,
  required Signup3FeaturedSheetController controller,
}) {
  bool isUploading = false;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> pickImages() async {
            final remainingSlots = 5 - controller.tempImages.length;
            if (remainingSlots <= 0) {
              controller.onError('Maximum 5 images allowed');
              return;
            }
            final files = await CommonUploader.pickMultipleFromGallery();
            if (files.isNotEmpty) {
              const maxSizeBytes = 30 * 1024 * 1024; // 30MB
              final validFiles = <File>[];
              bool oversizedFound = false;

              for (final file in files) {
                if (file.lengthSync() > maxSizeBytes) {
                  oversizedFound = true;
                } else {
                  validFiles.add(file);
                }
              }

              if (oversizedFound) {
                controller.onError('Each image must be max 30MB');
              }

              if (validFiles.isNotEmpty) {
                setModalState(() {
                  if (validFiles.length > remainingSlots) {
                    controller.tempImages
                        .addAll(validFiles.take(remainingSlots));
                    controller.onError('Maximum 5 images allowed');
                  } else {
                    controller.tempImages.addAll(validFiles);
                  }
                });
              }
            }
          }

          return Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: AppRadii.topMassive,
            ),
            child: SingleChildScrollView(
              child: Column(
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
                      Text(
                        'Featured Work',
                        style: AppTextStyles.displayLabel16
                            .copyWith(color: AppColors.white),
                      ),
                      IconButton(
                        onPressed: isUploading
                            ? null
                            : () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: AppColors.white),
                      ),
                    ],
                  ),
                  Text(
                    'Upload exactly 5 images (PNG, JPG or GIF, max 30MB total).',
                    style: AppTextStyles.body14
                        .copyWith(color: AppColors.white30),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.dividerDark),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Enter Work Title*',
                    controller: controller.titleController,
                    onChanged: (_) => setModalState(() {}),
                  ),
                  const SizedBox(height: 16),
                  DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      radius: AppRadii.radiusXxl,
                      color: AppColors.white24,
                      strokeWidth: 1,
                      dashPattern: const [4, 4],
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.base),
                      decoration: BoxDecoration(
                        color: AppColors.transparent,
                        borderRadius: AppRadii.xxlAll,
                      ),
                      child: controller.tempImages.isEmpty
                          ? _emptyDropZone(pickImages)
                          : _imageGrid(controller, setModalState, pickImages),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Builder(
                    builder: (context) {
                      final isValid = controller.titleController.text
                              .trim()
                              .isNotEmpty &&
                          controller.tempImages.length == 5 &&
                          !isUploading;
                      return AppCtaButton(
                        label: isUploading ? 'Uploading...' : 'Save',
                        height: 48,
                        enabled: isValid,
                        onPressed: () async {
                          final title = controller.titleController.text.trim();
                          if (title.isEmpty) {
                            controller.onError('Please enter work title');
                            return;
                          }
                          if (controller.tempImages.length != 5) {
                            controller.onError(
                              'Exactly 5 images are required for featured work',
                            );
                            return;
                          }

                          if (controller.onUploadAndSave != null) {
                            setModalState(() {
                              isUploading = true;
                            });
                            final success = await controller.onUploadAndSave!(
                              title: title,
                              files: List<File>.from(controller.tempImages),
                              editIndex: controller.editingProjectIndex,
                            );
                            if (context.mounted) {
                              if (success) {
                                controller.tempImages.clear();
                                controller.titleController.clear();
                                controller.editingProjectIndex = null;
                                Navigator.pop(context);
                              } else {
                                setModalState(() {
                                  isUploading = false;
                                });
                              }
                            }
                            return;
                          }

                          final projects = [...controller.featuredProjects];
                          final titles = [
                            ...controller.featuredProjectsTitles
                          ];
                          if (controller.editingProjectIndex != null) {
                            projects[controller.editingProjectIndex!] =
                                List.from(controller.tempImages);
                            if (controller.editingProjectIndex! <
                                titles.length) {
                              titles[controller.editingProjectIndex!] = title;
                            }
                          } else {
                            projects.add(List.from(controller.tempImages));
                            titles.add(title);
                          }
                          controller.commit(projects, titles);
                          controller.tempImages.clear();
                          controller.titleController.clear();
                          controller.editingProjectIndex = null;
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _emptyDropZone(VoidCallback onTap) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 180,
        maxHeight: 240,
      ),
      child: Container(
        width: double.infinity,
        color: AppColors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppAssets.upload,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
              width: 24,
              height: 24,
            ),
            const SizedBox(height: 18),
            Text(
              'Upload New Image, Video, Or Browse',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMediumStrong.copyWith(
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Choose a file in a 4:3, 5:4, 9:16,\nor 16:9 aspect ratio.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.copyWith(
                color: AppColors.white30,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _imageGrid(
  Signup3FeaturedSheetController controller,
  void Function(void Function()) setModalState,
  VoidCallback onAdd,
) {
  final bool canAddMore = controller.tempImages.length < 5;
  return ConstrainedBox(
    constraints: const BoxConstraints(
      minHeight: 220,
      maxHeight: 360,
    ),
    child: GridView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: canAddMore
          ? controller.tempImages.length + 1
          : controller.tempImages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (canAddMore && index == controller.tempImages.length) {
          return GestureDetector(
            onTap: onAdd,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppRadii.lgAll,
                border: Border.all(
                  color: AppColors.white24,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
            ),
          );
        }
        return Stack(
          children: [
            ClipRRect(
              borderRadius: AppRadii.lgAll,
              child: Image.file(
                controller.tempImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () {
                  setModalState(() {
                    controller.tempImages.removeAt(index);
                  });
                },
                child: Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
