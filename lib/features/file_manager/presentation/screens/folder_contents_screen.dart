import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../domain/models/fm_folder_key.dart';
import '../../domain/models/fm_linked_project.dart';
import '../../domain/models/fm_node.dart';
import '../../domain/models/fm_phase.dart';
import '../providers/file_manager_root_state.dart' show FmListStatus;
import '../providers/file_ops_repository_provider.dart';
import '../providers/folder_browse_repository_provider.dart';
import '../providers/folder_contents_notifier.dart';
import '../providers/folder_contents_state.dart';
import '../providers/node_action_notifier.dart';
import '../providers/node_action_state.dart';
import '../routes/file_manager_args.dart';
import '../widgets/fm_actions_sheet.dart';
import '../widgets/fm_delete_confirm_dialog.dart';
import '../widgets/fm_empty_view.dart';
import '../widgets/fm_error_view.dart';
import '../widgets/fm_project_badge_card.dart';
import '../../../../shared/widgets/loading.dart';
import '../widgets/fm_recursive_list.dart';
import '../widgets/fm_search_field.dart';

import '../widgets/fm_file_preview_sheet.dart';
import '../widgets/fm_upload_sheet.dart';

class FolderContentsScreen extends ConsumerStatefulWidget {
  final FmFolderKey folderKey;
  final String title;
  final FmLinkedProject? linkedProject;

  const FolderContentsScreen({
    super.key,
    required this.folderKey,
    required this.title,
    this.linkedProject,
  });

  @override
  ConsumerState<FolderContentsScreen> createState() => _FolderContentsScreenState();
}

class _FolderContentsScreenState extends ConsumerState<FolderContentsScreen> {
  bool _isMultiSelectMode = false;
  final Set<String> _selectedFileIds = {};
  String _selectedVersionFilter = 'All';

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      _selectedFileIds.clear();
    });
  }

  void _onFileSelectedChanged(String fileId, bool selected) {
    setState(() {
      if (selected) {
        _selectedFileIds.add(fileId);
      } else {
        _selectedFileIds.remove(fileId);
      }
    });
  }

  void _openChildFolder(BuildContext context, FmFolder folder) {
    final key = folder.nextKey ?? FmFolderKey(externalId: folder.id);
    context.pushNamed(
      Routes.filesFolder.name,
      pathParameters: {'id': key.externalId},
      extra: FolderContentsArgs.toExtra(
        key: key,
        title: folder.name,
        linkedProject: folder.linkedProject,
      ),
    );
  }

  void _openFile(BuildContext context, FmFile file) {
    FmFilePreviewSheet.show(context, file, folderKey: widget.folderKey);
  }

  Future<void> _onFolderMore(
    BuildContext context,
    WidgetRef ref,
    FmFolder folder,
  ) async {
    final action = await showFmActionsSheet(context, kind: FmNodeKind.folder);
    if (action == null || !context.mounted) return;
    final actions = ref.read(nodeActionNotifierProvider.notifier);
    final key = folder.nextKey ?? FmFolderKey(externalId: folder.id);
    final folderPath = folder.filepath ?? folder.id;
    switch (action) {
      case FmNodeAction.open:
        _openChildFolder(context, folder);
      case FmNodeAction.share:
        // Folder share = server ZIP URL handed to the OS share sheet.
        // Real `/share` OTP flow lands in FM9.03.
        await actions.downloadFolder(
          trackingKey: folderPath,
          externalId: key.externalId,
          phase: key.phase,
          path: key.path.isEmpty ? null : key.path,
        );
      case FmNodeAction.download:
        await actions.downloadFolder(
          trackingKey: folderPath,
          externalId: key.externalId,
          phase: key.phase,
          path: key.path.isEmpty ? null : key.path,
        );
      case FmNodeAction.delete:
        final ok = await showFmDeleteConfirmDialog(
          context,
          title: 'Delete folder?',
          message: 'This will permanently delete "${folder.name}" and all its '
              'contents. This cannot be undone.',
        );
        if (ok != true || !context.mounted) return;
        final deleted = await actions.delete(filepath: folderPath);
        if (deleted) {
          ref.invalidate(folderContentsNotifierProvider(widget.folderKey));
        }
    }
  }

  Future<void> _onFileMore(
    BuildContext context,
    WidgetRef ref,
    FmFile file,
  ) async {
    final action = await showFmActionsSheet(context, kind: FmNodeKind.file);
    if (action == null || !context.mounted) return;
    final actions = ref.read(nodeActionNotifierProvider.notifier);
    final filepath = file.filepath ?? file.id;
    switch (action) {
      case FmNodeAction.open:
        _openFile(context, file);
      case FmNodeAction.share:
        await actions.shareFile(filepath: filepath, subject: file.name);
      case FmNodeAction.download:
        await actions.downloadFile(filepath);
      case FmNodeAction.delete:
        final ok = await showFmDeleteConfirmDialog(
          context,
          title: 'Delete file?',
          message: 'This will permanently delete "${file.name}". '
              'This cannot be undone.',
        );
        if (ok != true || !context.mounted) return;
        final deleted = await actions.delete(filepath: filepath);
        if (deleted) {
          ref.invalidate(folderContentsNotifierProvider(widget.folderKey));
        }
    }
  }

  bool _hasFiles(List<FmNode> items) {
    return items.any((item) => item is FmFile);
  }

  bool _hasVersions(List<FmNode> items) {
    return items.any((item) => item is FmFile && item.version != null);
  }

  List<String> _getVersionOptions(List<FmNode> items) {
    final versions = items
        .whereType<FmFile>()
        .map((f) => f.version)
        .whereType<int>()
        .toSet()
        .toList();
    versions.sort();
    return ['All', ...versions.map((v) => 'V$v')];
  }

  List<FmNode> _filterItemsByVersion(List<FmNode> items) {
    if (_selectedVersionFilter == 'All') return items;
    final verNum = int.tryParse(_selectedVersionFilter.replaceAll('V', ''));
    if (verNum == null) return items;
    return items.where((item) {
      if (item is FmFile) {
        return item.version == verNum;
      }
      return true; // Keep folders visible
    }).toList();
  }

  bool _shouldShowCtaButton() {
    if (_isMultiSelectMode) return true;
    final name = widget.title.toLowerCase();
    return name.contains('post production') ||
        name.contains('raw footage') ||
        name.contains('edit') ||
        name.contains('revision');
  }

  /// True when the current folder is the Revisions container — its CTA
  /// creates a new `Version{n+1}` folder instead of opening the Upload
  /// sheet.
  bool get _isRevisionsFolder =>
      widget.title.toLowerCase().contains('revision');

  Future<void> _createNextVersionFolder() async {
    final state = ref.read(folderContentsNotifierProvider(widget.folderKey));
    // Scan existing `VersionN` folders to pick the next N.
    var maxN = 0;
    for (final n in state.items.whereType<FmFolder>()) {
      final m = RegExp(r'^Version(\d+)$', caseSensitive: false)
          .firstMatch(n.name.trim());
      final v = m == null ? null : int.tryParse(m.group(1)!);
      if (v != null && v > maxN) maxN = v;
    }
    final nextName = 'Version${maxN + 1}';

    try {
      await ref.read(folderBrowseRepositoryProvider).createFolder(
        externalId: widget.folderKey.externalId,
        phase: widget.folderKey.phase,
        path: widget.folderKey.path,
        folderName: nextName,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Failed to create $nextName: $e'),
        ),
      );
      return;
    }
    if (!mounted) return;
    ref.invalidate(folderContentsNotifierProvider(widget.folderKey));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        content: Text('$nextName folder created'),
      ),
    );
  }

  Future<void> _onRequestEdits() async {
    if (_selectedFileIds.isEmpty) return;

    // Map selected file ids back to their absolute filepaths — the copy
    // endpoint is path-addressed. Dummy files may not have a filepath;
    // fall back to id so the fake path still round-trips.
    final state = ref.read(folderContentsNotifierProvider(widget.folderKey));
    final sourcePaths = <String>[
      for (final f in state.items.whereType<FmFile>())
        if (_selectedFileIds.contains(f.id)) (f.filepath ?? f.id),
    ];
    if (sourcePaths.isEmpty) return;

    final count = sourcePaths.length;
    final ops = ref.read(fileOpsRepositoryProvider);
    try {
      await ops.copyFiles(
        externalId: widget.folderKey.externalId,
        phase: FmPhase.post,
        targetPath: 'Edits/Selected for Edits',
        sourcePaths: sourcePaths,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Failed to send edits: $e'),
        ),
      );
      return;
    }

    if (!mounted) return;

    // Refresh both the current folder (source files may now show
    // `File Selected For Edits`) and the destination folder — a fresh
    // browse under `Edits/Selected for Edits` picks up the copies.
    ref.invalidate(folderContentsNotifierProvider(widget.folderKey));

    context.pushNamed(
      Routes.filesSuccess.name,
      extra: <String, dynamic>{
        'title': 'Edits Request Sent',
        'message': 'Your request for editing $count raw footage files has been sent to the production team.',
        'ctaText': 'Open Edit Folder',
        'onCtaPressed': () {
          _toggleMultiSelectMode();
          context.goNamed(Routes.files.name);
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(folderContentsNotifierProvider(widget.folderKey));
    final notifier = ref.read(folderContentsNotifierProvider(widget.folderKey).notifier);

    ref.listen<FmActionSignal?>(
      nodeActionNotifierProvider.select((s) => s.lastSignal),
      (prev, next) {
        if (next == null || next == prev) return;
        TopMessage.show(
          context,
          next.message,
          type: next.kind == FmActionSignalKind.error
              ? TopMessageType.error
              : TopMessageType.success,
        );
        ref.read(nodeActionNotifierProvider.notifier).clearSignal();
      },
    );

    final filteredItems = _filterItemsByVersion(state.items);

    return AppScaffold(
      body: Column(
        children: [
          _FolderHeader(
            title: widget.title,
            onBack: () => context.pop(),
            isMultiSelectMode: _isMultiSelectMode,
            onToggleMultiSelect: _toggleMultiSelectMode,
            showMultiSelectToggle: _hasFiles(state.items),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Row(
              children: [
                Expanded(
                  child: FmSearchField(
                    initialValue: state.searchQuery,
                    onChanged: notifier.setSearchQuery,
                  ),
                ),
                if (_hasVersions(state.items)) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMid,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.dividerDark),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedVersionFilter,
                        dropdownColor: AppColors.surface,
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                        items: _getVersionOptions(state.items).map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(v),
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedVersionFilter = val ?? 'All';
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.linkedProject != null) ...[
            const SizedBox(height: AppSpacing.base),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: FmProjectBadgeCard(project: widget.linkedProject!),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: _Body(
              state: state.copyWith(items: filteredItems),
              onRefresh: notifier.refresh,
              onLoadMore: notifier.loadMore,
              onFolderTap: (f) => _openChildFolder(context, f),
              onFolderMore: (f) => _onFolderMore(context, ref, f),
              onFileTap: (f) => _openFile(context, f),
              onFileMore: (f) => _onFileMore(context, ref, f),
              isMultiSelectMode: _isMultiSelectMode,
              selectedFileIds: _selectedFileIds,
              onFileSelectedChanged: _onFileSelectedChanged,
            ),
          ),
          if (_shouldShowCtaButton())
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isMultiSelectMode
                      ? (_selectedFileIds.isEmpty ? null : _onRequestEdits)
                      : (_isRevisionsFolder
                          ? _createNextVersionFolder
                          : () => FmUploadSheet.show(
                                context,
                                widget.folderKey,
                                widget.title,
                              )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.disabled,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    _isMultiSelectMode
                        ? 'Request Edits (${_selectedFileIds.length})'
                        : (_isRevisionsFolder ? 'Create Folder' : 'Upload Files'),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: _isMultiSelectMode && _selectedFileIds.isEmpty
                          ? AppColors.textTertiary
                          : AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final FolderContentsState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final void Function(FmFolder) onFolderTap;
  final void Function(FmFolder) onFolderMore;
  final void Function(FmFile) onFileTap;
  final void Function(FmFile) onFileMore;
  final bool isMultiSelectMode;
  final Set<String> selectedFileIds;
  final void Function(String fileId, bool selected) onFileSelectedChanged;

  const _Body({
    required this.state,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onFolderTap,
    required this.onFolderMore,
    required this.onFileTap,
    required this.onFileMore,
    required this.isMultiSelectMode,
    required this.selectedFileIds,
    required this.onFileSelectedChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (state.status == FmListStatus.loading && state.items.isEmpty) {
      return const AppScreenLoader();
    }
    if (state.status == FmListStatus.error && state.items.isEmpty) {
      return FmErrorView(
        message: state.errorMessage ?? 'Something went wrong',
        onRetry: onRefresh,
      );
    }

    final visible = state.visibleItems;
    if (visible.isEmpty) {
      if (state.searchQuery.trim().isNotEmpty) {
        return FmEmptyView.search(query: state.searchQuery);
      }
      return const FmEmptyView.folder();
    }

    return FmRecursiveList(
      items: visible,
      hasMore: state.hasMore,
      loadingMore: state.status == FmListStatus.loadingMore,
      onRefresh: onRefresh,
      onLoadMore: onLoadMore,
      onFolderTap: onFolderTap,
      onFolderMore: onFolderMore,
      onFileTap: onFileTap,
      onFileMore: onFileMore,
      isMultiSelectMode: isMultiSelectMode,
      selectedFileIds: selectedFileIds,
      onFileSelectedChanged: onFileSelectedChanged,
    );
  }
}

/// Nested-screen header. Matches `AppMainToolbar` typography
/// (`displayLabel16`) + 48dp tap targets, but swaps the drawer button for a
/// back arrow.
class _FolderHeader extends StatelessWidget {
  static const double _target = 48;

  final String title;
  final VoidCallback onBack;
  final bool isMultiSelectMode;
  final VoidCallback? onToggleMultiSelect;
  final bool showMultiSelectToggle;

  const _FolderHeader({
    required this.title,
    required this.onBack,
    this.isMultiSelectMode = false,
    this.onToggleMultiSelect,
    this.showMultiSelectToggle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: onBack,
            constraints: const BoxConstraints.tightFor(
              width: _target,
              height: _target,
            ),
            padding: EdgeInsets.zero,
            icon: SvgPicture.asset(
              AppAssets.back,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              isMultiSelectMode ? 'Select Files' : title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.displayLabel16,
            ),
          ),
          const Spacer(),
          if (showMultiSelectToggle)
            IconButton(
              tooltip: isMultiSelectMode ? 'Cancel Selection' : 'Select Files',
              onPressed: onToggleMultiSelect,
              constraints: const BoxConstraints.tightFor(
                width: _target,
                height: _target,
              ),
              padding: EdgeInsets.zero,
              icon: Icon(
                isMultiSelectMode ? Icons.cancel_outlined : Icons.checklist_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            )
          else
            const SizedBox.square(dimension: _target),
        ],
      ),
    );
  }
}
