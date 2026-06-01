import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../providers/file_manager_providers.dart';
import '../routes/file_manager_args.dart';

const _kFolderId = 'lana-123456';

class PreProductionScreen extends ConsumerStatefulWidget {
  const PreProductionScreen({super.key});

  @override
  ConsumerState<PreProductionScreen> createState() =>
      _PreProductionScreenState();
}

class _PreProductionScreenState extends ConsumerState<PreProductionScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(preProductionNotifierProvider(_kFolderId));
    final notifier =
        ref.read(preProductionNotifierProvider(_kFolderId).notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    child: SvgPicture.asset(AppAssets.back),
                  ),
                  const Spacer(),
                  const Text(
                    'Pre Production',
                    style: AppTextStyles.displayLabel16,
                  ),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
              ),
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.mld,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMid,
                  borderRadius: AppRadii.lgAll,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: notifier.setQuery,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white30,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base,
                      ),
                      itemCount: state.filtered.length,
                      itemBuilder: (_, index) {
                        final file = state.filtered[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                          padding: const EdgeInsets.all(AppSpacing.base),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMid,
                            borderRadius: AppRadii.hugeAll,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    file.isPdf
                                        ? Icons.picture_as_pdf
                                        : Icons.description,
                                    color: file.isPdf
                                        ? AppColors.redAccent
                                        : AppColors.blue,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    file.name,
                                    style: AppTextStyles.bodyCompactMedium
                                        .copyWith(color: AppColors.white),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.more_vert,
                                    color: AppColors.white,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Container(
                                height: 140,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.circleGradientTop,
                                  borderRadius: AppRadii.xxlAll,
                                ),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.base,
                                      vertical: AppSpacing.sm,
                                    ),
                                    decoration: BoxDecoration(
                                      color: file.isPdf
                                          ? AppColors.redAccent
                                          : AppColors.blue,
                                      borderRadius: AppRadii.mdAll,
                                    ),
                                    child: Text(
                                      file.isPdf ? 'Pdf' : 'Doc',
                                      style: AppTextStyles.bodyLargeStrong
                                          .copyWith(color: AppColors.white),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Divider(
                                color: AppColors.dividerDark,
                                thickness: 0.8,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.softLightBlue,
                                    child: Text(
                                      file.ownerInitials,
                                      style: AppTextStyles.bodyCompactStrong
                                          .copyWith(color: AppColors.black),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    file.openedAtLabel,
                                    style: AppTextStyles.bodyCompact.copyWith(
                                      color: AppColors.white30,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.base,
          AppSpacing.smd,
          AppSpacing.base,
          AppSpacing.xl,
        ),
        decoration: const BoxDecoration(color: AppColors.background),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              borderRadius: AppRadii.smAll,
              onTap: () {
                context.pushNamed(
                  Routes.fileViewer.name,
                  extra: const FileViewerArgs(folderId: _kFolderId).toExtra(),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View Shoot Details',
                    style: AppTextStyles.bodyCompact.copyWith(
                      color: AppColors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.upload, color: AppColors.black),
                label: Text(
                  'Upload Files',
                  style: AppTextStyles.displayLabel14.copyWith(
                    color: AppColors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.xlAll,
                  ),
                ),
                onPressed: () => _showUploadDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (sheetCtx) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surfaceStats,
            borderRadius: AppRadii.topPortfolio,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 5,
                    width: 40,
                    margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.white30,
                      borderRadius: AppRadii.mldAll,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Upload Files',
                      style: AppTextStyles.displayLabel16,
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(sheetCtx),
                      child: const Icon(Icons.close, color: AppColors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Files will be uploaded to the folder Lana Guzman',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white30,
                  ),
                ),
                const Divider(color: AppColors.dividerDark, thickness: 0.8),
                const SizedBox(height: 20),
                Container(
                  height: 230,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMid,
                    borderRadius: AppRadii.xxlAll,
                    border: Border.all(color: AppColors.dividerDark),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(AppAssets.iconUploadFilled, height: 40),
                        const SizedBox(height: 16),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Drag your files here or ',
                                style: AppTextStyles.bodyLargeMedium.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                              TextSpan(
                                text: 'Browse',
                                style: AppTextStyles.bodyLargeMedium.copyWith(
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.xlAll,
                            ),
                          ),
                          onPressed: () => Navigator.pop(sheetCtx),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.displayLabel14.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.xlAll,
                            ),
                          ),
                          onPressed: () => Navigator.pop(sheetCtx),
                          child: Text(
                            'Upload Files',
                            style: AppTextStyles.displayLabel14.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
