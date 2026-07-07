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
import '../../../../shared/widgets/common_file_viewer.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../domain/models/fm_linked_project.dart';
import '../../domain/models/fm_node.dart';
import '../providers/file_manager_root_state.dart' show FmListStatus;
import '../providers/folder_contents_notifier.dart';
import '../providers/folder_contents_state.dart';
import '../providers/node_action_notifier.dart';
import '../providers/node_action_state.dart';
import '../widgets/fm_actions_sheet.dart';
import '../widgets/fm_delete_confirm_dialog.dart';
import '../widgets/fm_empty_view.dart';
import '../widgets/fm_error_view.dart';
import '../widgets/fm_project_badge_card.dart';
import '../../../../shared/widgets/loading.dart';
import '../widgets/fm_recursive_list.dart';
import '../widgets/fm_search_field.dart';

class FolderContentsScreen extends ConsumerWidget {
  final String folderId;
  final String title;
  final FmLinkedProject? linkedProject;

  const FolderContentsScreen({
    super.key,
    required this.folderId,
    required this.title,
    this.linkedProject,
  });

  void _openChildFolder(BuildContext context, FmFolder folder) {
    context.pushNamed(
      Routes.filesFolder.name,
      pathParameters: {'id': folder.id},
      extra: <String, dynamic>{
        'title': folder.name,
        if (folder.linkedProject != null) 'linkedProject': folder.linkedProject,
      },
    );
  }

  void _openFile(BuildContext context, FmFile file) {
    CommonFileViewer.open(context: context, filePath: file.downloadUrl);
  }

  Future<void> _onFolderMore(
    BuildContext context,
    WidgetRef ref,
    FmFolder folder,
  ) async {
    final action = await showFmActionsSheet(context, kind: FmNodeKind.folder);
    if (action == null || !context.mounted) return;
    final actions = ref.read(nodeActionNotifierProvider.notifier);
    switch (action) {
      case FmNodeAction.open:
        _openChildFolder(context, folder);
      case FmNodeAction.share:
        await actions.share(nodeId: folder.id, kind: FmNodeKind.folder);
      case FmNodeAction.download:
        break;
      case FmNodeAction.delete:
        final ok = await showFmDeleteConfirmDialog(
          context,
          title: 'Delete folder?',
          message: 'This will permanently delete "${folder.name}" and all its '
              'contents. This cannot be undone.',
        );
        if (ok != true || !context.mounted) return;
        final deleted = await actions.delete(
          nodeId: folder.id,
          kind: FmNodeKind.folder,
        );
        if (deleted) {
          ref.invalidate(folderContentsNotifierProvider(folderId));
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
    switch (action) {
      case FmNodeAction.open:
        _openFile(context, file);
      case FmNodeAction.share:
        await actions.share(nodeId: file.id, kind: FmNodeKind.file);
      case FmNodeAction.download:
        await actions.download(fileId: file.id);
      case FmNodeAction.delete:
        final ok = await showFmDeleteConfirmDialog(
          context,
          title: 'Delete file?',
          message: 'This will permanently delete "${file.name}". '
              'This cannot be undone.',
        );
        if (ok != true || !context.mounted) return;
        final deleted = await actions.delete(
          nodeId: file.id,
          kind: FmNodeKind.file,
        );
        if (deleted) {
          ref.invalidate(folderContentsNotifierProvider(folderId));
        }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(folderContentsNotifierProvider(folderId));
    final notifier = ref.read(folderContentsNotifierProvider(folderId).notifier);

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

    return AppScaffold(
      body: Column(
        children: [
          _FolderHeader(title: title, onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: FmSearchField(
              initialValue: state.searchQuery,
              onChanged: notifier.setSearchQuery,
            ),
          ),
          if (linkedProject != null) ...[
            const SizedBox(height: AppSpacing.base),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: FmProjectBadgeCard(project: linkedProject!),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: _Body(
              state: state,
              onRefresh: notifier.refresh,
              onLoadMore: notifier.loadMore,
              onFolderTap: (f) => _openChildFolder(context, f),
              onFolderMore: (f) => _onFolderMore(context, ref, f),
              onFileTap: (f) => _openFile(context, f),
              onFileMore: (f) => _onFileMore(context, ref, f),
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

  const _Body({
    required this.state,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onFolderTap,
    required this.onFolderMore,
    required this.onFileTap,
    required this.onFileMore,
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

  const _FolderHeader({required this.title, required this.onBack});

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
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.displayLabel16,
            ),
          ),
          const Spacer(),
          const SizedBox.square(dimension: _target),
        ],
      ),
    );
  }
}
