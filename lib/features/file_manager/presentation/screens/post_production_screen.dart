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
import '../../../../shared/layouts/app_scaffold.dart';
import '../providers/file_manager_providers.dart';

const _kFolderId = 'lana-123456';

class PostProductionScreen extends ConsumerStatefulWidget {
  const PostProductionScreen({super.key});

  @override
  ConsumerState<PostProductionScreen> createState() =>
      _PostProductionScreenState();
}

class _PostProductionScreenState extends ConsumerState<PostProductionScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postProductionNotifierProvider(_kFolderId));
    final notifier =
        ref.read(postProductionNotifierProvider(_kFolderId).notifier);

    return AppScaffold(
      body: Column(
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
                    'Lana #123456',
                    style: AppTextStyles.displayLabel16,
                  ),
                  const Spacer(),
                ],
              ),
            ),
            AppSpacing.verticalBase,
            Padding(
              padding: AppSpacing.insetsHBase,
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
                    const Icon(Icons.search, color: AppColors.white54),
                    AppSpacing.gapHSmd,
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: notifier.setQuery,
                        style: AppTextStyles.inherit,
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          hintStyle: AppTextStyles.inherit,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.verticalBase,
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: AppSpacing.insetsHBase,
                      itemCount: state.filtered.length,
                      itemBuilder: (_, index) {
                        final folder = state.filtered[index];
                        return InkWell(
                          borderRadius: AppRadii.portfolioCompactAll,
                          onTap: () =>
                              context.pushNamed(Routes.preProduction.name),
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.mld,
                            ),
                            padding: const EdgeInsets.all(
                              AppSpacing.folderCardInset,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMid,
                              borderRadius: AppRadii.portfolioCompactAll,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.folder,
                                      color: AppColors.primary,
                                    ),
                                    AppSpacing.gapHSm,
                                    Text(
                                      folder.name,
                                      style: AppTextStyles.bodyCompactStrong,
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.more_vert,
                                      color: AppColors.white,
                                    ),
                                  ],
                                ),
                                AppSpacing.verticalSm,
                                Text(
                                  '${folder.fileCount.toString().padLeft(2, '0')} Files',
                                  style: AppTextStyles.bodySmall,
                                ),
                                AppSpacing.verticalSm,
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.smd,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.circleGradientTop,
                                    borderRadius: AppRadii.hugeAll,
                                  ),
                                  child: Text(
                                    folder.category,
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ),
                                const Divider(
                                  color: AppColors.dividerDark,
                                  thickness: 0.8,
                                ),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          AppColors.softLightBlue,
                                      child: Text(
                                        folder.ownerInitials,
                                        style: AppTextStyles.inherit,
                                      ),
                                    ),
                                    AppSpacing.gapHSmd,
                                    Text(
                                      folder.openedAtLabel,
                                      style: AppTextStyles.inherit14,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
    );
  }
}
