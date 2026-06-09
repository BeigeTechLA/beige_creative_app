import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
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
  final void Function(String message) onError;

  Signup3FeaturedSheetController({
    required this.titleController,
    required this.tempImages,
    required this.editingProjectIndex,
    required this.featuredProjects,
    required this.featuredProjectsTitles,
    required this.selectedTags,
    required this.commit,
    required this.onError,
  });
}

Future<void> showSignup3FeaturedSheet({
  required BuildContext context,
  required Signup3FeaturedSheetController controller,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setModalState) {
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
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: AppColors.white),
                      ),
                    ],
                  ),
                  Text(
                    'For best results, use a PNG, JPG, Video or\nGIF image etc.',
                    style: AppTextStyles.body14
                        .copyWith(color: AppColors.white30),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.dividerDark),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Enter Work Title*',
                    controller: controller.titleController,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final file = await CommonUploader.pickFromGallery();
                      if (file != null) {
                        setModalState(() {
                          controller.tempImages.add(file);
                        });
                      }
                    },
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        radius: AppRadii.radiusXxl,
                        color: AppColors.white24,
                        strokeWidth: 1,
                        dashPattern: const [4, 4],
                      ),
                      child: Container(
                        height: 190,
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.base),
                        decoration: BoxDecoration(
                          borderRadius: AppRadii.xxlAll,
                        ),
                        child: controller.tempImages.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.upload,
                                    color: AppColors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Upload new image, video, or browse',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodyMediumStrong
                                        .copyWith(color: AppColors.white),
                                  ),
                                ],
                              )
                            : ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 220,
                                  maxHeight: 360,
                                ),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: controller.tempImages.length + 1,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 1,
                                  ),
                                  itemBuilder: (context, index) {
                                    if (index ==
                                        controller.tempImages.length) {
                                      return GestureDetector(
                                        onTap: () async {
                                          final file = await CommonUploader
                                              .pickFromGallery();
                                          if (file != null) {
                                            setModalState(() {
                                              controller.tempImages.add(file);
                                            });
                                          }
                                        },
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
                                                controller.tempImages
                                                    .removeAt(index);
                                              });
                                            },
                                            child: Container(
                                              height: 24,
                                              width: 24,
                                              decoration: BoxDecoration(
                                                color: AppColors.black
                                                    .withValues(alpha: 0.7),
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
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Builder(
                      builder: (context) {
                        final isValid = controller.titleController.text
                                .trim()
                                .isNotEmpty &&
                            controller.tempImages.length >= 5;
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isValid
                                ? AppColors.primary
                                : AppColors.lavenderGrey,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.xlAll,
                            ),
                          ),
                          onPressed: () {
                            if (!isValid) {
                              controller
                                  .onError('Minimum 5 images required');
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
                                titles[controller.editingProjectIndex!] =
                                    controller.titleController.text.trim();
                              }
                            } else {
                              projects.add(List.from(controller.tempImages));
                              titles.add(
                                controller.titleController.text.trim(),
                              );
                            }
                            controller.commit(projects, titles);
                            controller.tempImages.clear();
                            controller.titleController.clear();
                            controller.editingProjectIndex = null;
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Save',
                            style: AppTextStyles.inheritSemiBold
                                .copyWith(color: AppColors.black),
                          ),
                        );
                      },
                    ),
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
