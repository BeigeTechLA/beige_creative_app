import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../model_class/myprofile_model.dart';
import '../../../../config/env.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/top_message.dart';
import '../providers/profile_files_providers.dart';

class FeaturedWorkDetailsScreen extends ConsumerStatefulWidget {
  final String title;
  final List<dynamic> images;

  const FeaturedWorkDetailsScreen({
    super.key,
    required this.title,
    required this.images,
  });

  @override
  ConsumerState<FeaturedWorkDetailsScreen> createState() =>
      _FeaturedWorkDetailsScreenState();
}

class _FeaturedWorkDetailsScreenState
    extends ConsumerState<FeaturedWorkDetailsScreen> {
  late List<dynamic> images;
  bool isLoading = false;
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    images = List<dynamic>.from(widget.images);
  }

  Future<void> _delete(int index) async {
    final imageData = images[index];
    final id = imageData is CrewFile
        ? imageData.crewFilesId
        : imageData.crewFilesId as int;
    setState(() => isLoading = true);
    final ok = await ref
        .read(featuredWorkNotifierProvider.notifier)
        .deleteMany([id]);
    if (!mounted) return;
    if (ok) {
      setState(() {
        hasChanges = true;
        images.removeAt(index);
        isLoading = false;
      });
      if (images.isEmpty) Navigator.pop(context, true);
    } else {
      setState(() => isLoading = false);
      TopMessage.show(context, 'Delete Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, hasChanges);
      },
      child: AppScaffold(
        safeTop: false,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context, hasChanges),
            icon: SvgPicture.asset(
              AppAssets.back,
              height: 18,
              width: 18,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          title: Text(
            widget.title,
            style: AppTextStyles.headingOutfitLg
                .copyWith(color: AppColors.white),
          ),
        ),
        body: Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.cardCompactInset),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final imageData = images[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.base),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.hugeAll,
                    color: AppColors.surfaceShadow,
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: AppRadii.hugeAll,
                        child: CachedNetworkImage(
                          imageUrl: '${Env.imageUrl}${imageData.filePath}',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => _delete(index),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: AppColors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: AppColors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                    ),
                  ),
                );
              },
            ),
            if (isLoading) AppLoader(),
          ],
        ),
      ),
    );
  }
}
