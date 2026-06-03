import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../model_class/myprofile_model.dart';
import '../../../../config/env.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/common_file_viewer.dart';
import '../../../../shared/widgets/common_uploader.dart';
import '../../../../shared/widgets/top_message.dart';
import '../providers/profile_files_providers.dart';

class CertificatesScreen extends ConsumerWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<FilesListState>(certificatesNotifierProvider, (prev, next) {
      final msg = next.errorMessage;
      if (msg != null && msg != prev?.errorMessage) {
        TopMessage.show(context, msg);
      }
    });

    final state = ref.watch(certificatesNotifierProvider);
    final certs = state.files;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => context.pop(),
                        child: SvgPicture.asset(
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
                  Row(
                    children: [
                      Text(
                        'Certificates',
                        style: AppTextStyles.displayLabel16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: AppRadii.lgAll,
                          ),
                          child: TextField(
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.white),
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.white24),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.white24,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppRadii.lgAll,
                        ),
                        child: const Icon(Icons.tune, color: AppColors.white),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: certs.length,
                      itemBuilder: (context, index) {
                        final cert = certs[index];
                        return _CertificateRow(
                          cert: cert,
                          onMenuTap: () => _openOptions(context, ref, cert),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.xxlAll,
                        ),
                      ),
                      onPressed: () => _openUploadDialog(context, ref),
                      child: Text(
                        'Add New Certificate',
                        style: AppTextStyles.displayLabel14
                            .copyWith(color: AppColors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (state.isLoading) AppLoader(),
          ],
        ),
      ),
    );
  }

  void _openUploadDialog(BuildContext context, WidgetRef ref) {
    Future<void> handlePick(BuildContext sheetCtx, Future<dynamic> picker) async {
      sheetCtx.pop();
      final file = await picker;
      if (file == null) return;
      await ref.read(certificatesNotifierProvider.notifier).upload(file);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (sheetCtx) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: const BoxDecoration(
            color: AppColors.surfaceShadow,
            borderRadius: AppRadii.topPortfolio,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: Text(
                      'Upload your File',
                      style: AppTextStyles.displayStrong16,
                    ),
                  ),
                  InkWell(
                    onTap: () => sheetCtx.pop(),
                    child: const Icon(Icons.close, color: AppColors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.white24),
              _UploadOption(
                svgPath: AppAssets.scanner,
                title: 'Scan from Camera',
                onTap: () =>
                    handlePick(sheetCtx, CommonUploader.pickFromCamera()),
              ),
              const Divider(color: AppColors.white24),
              _UploadOption(
                svgPath: AppAssets.gallery,
                title: 'Import from Gallery',
                onTap: () =>
                    handlePick(sheetCtx, CommonUploader.pickFromGallery()),
              ),
              const Divider(color: AppColors.white24),
              _UploadOption(
                svgPath: AppAssets.document,
                title: 'Import from Files',
                onTap: () => handlePick(sheetCtx, CommonUploader.pickFile()),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openOptions(BuildContext context, WidgetRef ref, CrewFile cert) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (sheetCtx) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: const BoxDecoration(
            color: AppColors.surfaceShadow,
            borderRadius: AppRadii.topHuge,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  sheetCtx.pop();
                  CommonFileViewer.open(
                    context: context,
                    filePath: '${Env.imageUrl}${cert.filePath}',
                    isNetwork: true,
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.visibility, color: AppColors.white),
                    const SizedBox(width: 12),
                    Text(
                      'View Details',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  sheetCtx.pop();
                  ref
                      .read(certificatesNotifierProvider.notifier)
                      .delete(cert.crewFilesId);
                },
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: AppColors.error),
                    const SizedBox(width: 12),
                    Text(
                      'Delete',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.error),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

class _CertificateRow extends StatelessWidget {
  final CrewFile cert;
  final VoidCallback onMenuTap;

  const _CertificateRow({required this.cert, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.smd),
      decoration: BoxDecoration(
        color: AppColors.surfaceShadow,
        borderRadius: AppRadii.lgAll,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadii.smAll,
            child: SizedBox(
              height: 55,
              width: 55,
              child: CachedNetworkImage(
                imageUrl: '${Env.imageUrl}${cert.filePath}',
                fit: BoxFit.cover,
                errorWidget: (context, url, error) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: SvgPicture.asset(
                      AppAssets.imageHolder,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cert.filePath.split('/').last,
                  style: AppTextStyles.bodyCompactMedium,
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: onMenuTap,
                child: SvgPicture.asset(
                  AppAssets.moreVert,
                  height: 20,
                  width: 20,
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ],
      ),
    );
  }
}

class _UploadOption extends StatelessWidget {
  final String svgPath;
  final String title;
  final VoidCallback onTap;

  const _UploadOption({
    required this.svgPath,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            SvgPicture.asset(svgPath, height: 22, width: 22),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
