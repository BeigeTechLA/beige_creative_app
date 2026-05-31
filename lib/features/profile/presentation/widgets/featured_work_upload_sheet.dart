import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../service/api_service.dart';
import '../../../../shared/widgets/common_uploader.dart';
import '../../../../shared/widgets/custom_text_field.dart';

/// Bottom-sheet body for adding / editing featured work. State is shared with
/// the parent screen — the parent owns the title controller and the two
/// image lists; the sheet mutates them via the `setStateOuter` callback and
/// rebuilds locally via its own [StatefulWidget].
///
/// Lifted from the orchestrator's `_featuredSheet` method (lines ~1083-1465)
/// during 4.08 split. Save validation, image-count thresholds, and modal
/// layout preserved verbatim.
class FeaturedWorkUploadSheet extends StatefulWidget {
  final TextEditingController titleController;
  final List<File> tempFeaturedImages;
  final List<dynamic> editingImages;
  final Future<void> Function() onSavePressed;

  const FeaturedWorkUploadSheet({
    super.key,
    required this.titleController,
    required this.tempFeaturedImages,
    required this.editingImages,
    required this.onSavePressed,
  });

  @override
  State<FeaturedWorkUploadSheet> createState() =>
      _FeaturedWorkUploadSheetState();
}

class _FeaturedWorkUploadSheetState extends State<FeaturedWorkUploadSheet> {
  @override
  Widget build(BuildContext context) {
    final totalImages =
        widget.editingImages.length + widget.tempFeaturedImages.length;

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
                  style: AppTextStyles.displayLabel16.copyWith(
                    color: AppColors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.white),
                ),
              ],
            ),
            Text(
              'For best results, use PNG, JPG or GIF.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white30,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.dividerDark),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Enter Work Title*',
              controller: widget.titleController,
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
                decoration: BoxDecoration(borderRadius: AppRadii.xxlAll),
                child: totalImages == 0
                    ? _emptyDropZone()
                    : _imageGrid(totalImages),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: totalImages >= 5
                      ? AppColors.primary
                      : AppColors.lavenderGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.xlAll,
                  ),
                ),
                onPressed: widget.onSavePressed,
                child: const Text('Save', style: AppTextStyles.buttonMedium),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _emptyDropZone() {
    return GestureDetector(
      onTap: () async {
        final file = await CommonUploader.pickFromGallery();
        if (file != null) {
          setState(() => widget.tempFeaturedImages.add(file));
        }
      },
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppAssets.Upload,
              // ignore: deprecated_member_use
              color: AppColors.white,
              width: 24,
              height: 24,
            ),
            const SizedBox(height: 18),
            Text(
              'Upload New Image, Video,Or Browse',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLargeStrong.copyWith(
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Choose a file in a 4:3, 5:4, 9:16,\nor 16:9 aspect ratio.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyCompact.copyWith(
                color: AppColors.white30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageGrid(int totalImages) {
    return SizedBox(
      height: 320,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: totalImages + 1,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          if (index == totalImages) {
            return GestureDetector(
              onTap: () async {
                final file = await CommonUploader.pickFromGallery();
                if (file != null) {
                  setState(() => widget.tempFeaturedImages.add(file));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: AppRadii.lgAll,
                  border: Border.all(color: AppColors.white24),
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

          if (index < widget.editingImages.length) {
            final image = widget.editingImages[index];
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: AppRadii.lgAll,
                  child: Image.network(
                    '${ApiService.imageURL}${image.filePath}',
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
                      setState(() => widget.editingImages.removeAt(index));
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
          }

          final localIndex = index - widget.editingImages.length;
          return Stack(
            children: [
              ClipRRect(
                borderRadius: AppRadii.lgAll,
                child: Image.file(
                  widget.tempFeaturedImages[localIndex],
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
                    setState(() =>
                        widget.tempFeaturedImages.removeAt(localIndex));
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
}
