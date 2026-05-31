import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/route_names.dart';
import '../../../../app/shadows.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../domain/entities/file_folder.dart';
import '../providers/file_manager_providers.dart';

class FileManagerScreen extends ConsumerStatefulWidget {
  const FileManagerScreen({super.key});

  @override
  ConsumerState<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends ConsumerState<FileManagerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 2, vsync: this);
  final TextEditingController _folderController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _tabController.dispose();
    _folderController.dispose();
    _categoryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fileManagerNotifierProvider);
    final notifier = ref.read(fileManagerNotifierProvider.notifier);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Builder(
                  builder: (ctx) => InkWell(
                    onTap: () => Scaffold.of(ctx).openDrawer(),
                    child: SvgPicture.asset(
                      AppAssets.menu,
                      width: 26,
                      height: 26,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'File Manager',
                  style: AppTextStyles.displayLabel16,
                ),
                const Spacer(),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.mld,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMid,
                      borderRadius: AppRadii.xlAll,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(AppAssets.search_icon),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: notifier.setQuery,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search File, User...',
                              hintStyle: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.white38,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: notifier.toggleView,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMid,
                      borderRadius: AppRadii.lgAll,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        state.view == FileManagerView.card
                            ? AppAssets.grid
                            : AppAssets.list,
                        height: 22,
                        width: 22,
                        // ignore: deprecated_member_use
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.label,
                indicator: UnderlineTabIndicator(
                  borderSide: const BorderSide(
                    width: 3,
                    color: AppColors.primary,
                  ),
                  insets: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.editProfileBtnH,
                  ),
                ),
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.white30,
                labelStyle: AppTextStyles.body14Medium,
                tabs: const [
                  Tab(text: 'All Files'),
                  Tab(text: 'Recent Files'),
                ],
              ),
              Container(height: 2, color: AppColors.dividerDark),
            ],
          ),

          const SizedBox(height: 10),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _FolderList(
                  folders: state.filteredAll,
                  view: state.view,
                  isLoading: state.isLoading,
                ),
                _FolderList(
                  folders: state.filteredRecent,
                  view: state.view,
                  isLoading: state.isLoading,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Center(
              child: InkWell(
                onTap: () => _showCreateFolderSheet(
                  folderController: _folderController,
                  categoryController: _categoryController,
                ),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppRadii.mldAll,
                    boxShadow: AppShadows.card,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: AppColors.black, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Add / Create',
                        style: AppTextStyles.body14Medium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateFolderSheet({
    required TextEditingController folderController,
    required TextEditingController categoryController,
  }) {
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
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.white24,
                      borderRadius: AppRadii.mldAll,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Create Folder',
                      style: AppTextStyles.displayLabel16,
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(sheetCtx),
                      child: const Icon(Icons.close, color: AppColors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Create new folder for users',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white30,
                  ),
                ),
                const Divider(
                  color: AppColors.dividerDark,
                  thickness: 0.8,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Folder Name',
                  controller: folderController,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  label: 'Category',
                  controller: categoryController,
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.xxlAll,
                            ),
                          ),
                          onPressed: () => context.pop(),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.displayLabel14.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.xxlAll,
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            'Create Folder',
                            style: AppTextStyles.displayLabel13.copyWith(
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

class _FolderList extends StatelessWidget {
  final List<FileFolder> folders;
  final FileManagerView view;
  final bool isLoading;

  const _FolderList({
    required this.folders,
    required this.view,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (folders.isEmpty) {
      return Center(
        child: Text(
          'No folders',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white54),
        ),
      );
    }
    if (view == FileManagerView.list) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        itemCount: folders.length,
        itemBuilder: (_, index) => _FolderRowCompact(folder: folders[index]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      itemCount: folders.length,
      itemBuilder: (_, index) => _FolderCard(folder: folders[index]),
    );
  }
}

class _FolderCard extends StatelessWidget {
  final FileFolder folder;
  const _FolderCard({required this.folder});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(RouteNames.postProduction),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.mld),
        padding: const EdgeInsets.all(AppSpacing.folderCardInset),
        decoration: BoxDecoration(
          color: AppColors.surfaceMid,
          borderRadius: AppRadii.portfolioCompactAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.folder, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  folder.name,
                  style: AppTextStyles.bodyCompactStrong.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.white),
                  color: AppColors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.xxxlAll,
                  ),
                  onSelected: (_) {},
                  itemBuilder: (_) => [
                    _popupItem('open', Icons.folder_open, 'Open'),
                    _popupItem(
                      'view',
                      Icons.remove_red_eye,
                      'View Shoot Details',
                    ),
                    _popupItem('rename', Icons.edit, 'Rename'),
                    const PopupMenuDivider(),
                    _popupItem('share', Icons.share, 'Share'),
                    _popupItem('download', Icons.download, 'Download'),
                    const PopupMenuDivider(),
                    _popupItem(
                      'delete',
                      Icons.delete,
                      'Delete',
                      isDelete: true,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${folder.fileCount.toString().padLeft(2, '0')} Files',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
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
                style: AppTextStyles.bodySmallMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            const Divider(color: AppColors.dividerDark, thickness: 0.8),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.softLightBlue,
                  child: Text(
                    folder.ownerInitials,
                    style: AppTextStyles.bodyLargeMedium.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  folder.openedAtLabel,
                  style: AppTextStyles.bodyLargeMedium.copyWith(
                    color: AppColors.white30,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FolderRowCompact extends StatelessWidget {
  final FileFolder folder;
  const _FolderRowCompact({required this.folder});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(RouteNames.postProduction),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.mld),
        padding: const EdgeInsets.all(AppSpacing.folderCardInset),
        decoration: BoxDecoration(
          color: AppColors.surfaceMid,
          borderRadius: AppRadii.portfolioCompactAll,
        ),
        child: Row(
          children: [
            const Icon(Icons.folder, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                folder.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            const Icon(Icons.more_vert, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}

PopupMenuItem<String> _popupItem(
  String value,
  IconData icon,
  String text, {
  bool isDelete = false,
}) {
  return PopupMenuItem<String>(
    value: value,
    child: Row(
      children: [
        Icon(icon, color: isDelete ? AppColors.error : AppColors.white),
        const SizedBox(width: 10),
        Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDelete ? AppColors.error : AppColors.white,
          ),
        ),
      ],
    ),
  );
}
