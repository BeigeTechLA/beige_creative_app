import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../shared/widgets/app_main_toolbar.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../domain/models/fm_folder_key.dart';
import '../../domain/models/fm_node.dart';
import '../providers/file_manager_root_notifier.dart';
import '../providers/file_manager_root_state.dart';
import '../providers/node_action_notifier.dart';
import '../providers/node_action_state.dart';
import '../routes/file_manager_args.dart';
import '../widgets/fm_actions_sheet.dart';
import '../widgets/fm_delete_confirm_dialog.dart';
import '../widgets/fm_empty_view.dart';
import '../widgets/fm_error_view.dart';
import '../widgets/fm_recursive_list.dart';
import '../widgets/fm_search_field.dart';
import '../widgets/fm_tab_bar.dart';
import '../../../../shared/widgets/loading.dart';

class FileManagerScreen extends ConsumerWidget {
  const FileManagerScreen({super.key});

  void _openFolder(BuildContext context, FmFolder folder) {
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

  Future<void> _onFolderMore(
    BuildContext context,
    WidgetRef ref,
    FmFolder folder,
  ) async {
    final action = await showFmActionsSheet(context, kind: FmNodeKind.folder);
    if (action == null || !context.mounted) return;
    final actions = ref.read(nodeActionNotifierProvider.notifier);
    final folderPath = folder.filepath ?? folder.id;
    switch (action) {
      case FmNodeAction.open:
        _openFolder(context, folder);
      case FmNodeAction.share:
        // Workspace-root share = whole-workspace ZIP URL via the OS
        // share sheet. Real `/share` OTP flow deferred to FM9.03.
        await actions.downloadFolder(
          trackingKey: folderPath,
          externalId: folder.id,
        );
      case FmNodeAction.download:
        await actions.downloadFolder(
          trackingKey: folderPath,
          externalId: folder.id,
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
          ref.invalidate(fileManagerRootNotifierProvider);
        }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fileManagerRootNotifierProvider);
    final notifier = ref.read(fileManagerRootNotifierProvider.notifier);

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

    return SafeArea(
      child: Column(
        children: [
          const AppMainToolbar(title: 'File Manager'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: FmSearchField(
              hintText: 'Search Folder...',
              initialValue: state.searchQuery,
              onChanged: notifier.setSearchQuery,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          FmTabBar(
            selected: state.tab,
            onChanged: notifier.selectTab,
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: _Body(
              state: state,
              onRefresh: notifier.refresh,
              onLoadMore: notifier.loadMore,
              onFolderTap: (f) => _openFolder(context, f),
              onFolderMore: (f) => _onFolderMore(context, ref, f),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final FileManagerRootState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final void Function(FmFolder) onFolderTap;
  final void Function(FmFolder) onFolderMore;

  const _Body({
    required this.state,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onFolderTap,
    required this.onFolderMore,
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
      return const FmEmptyView();
    }

    return FmRecursiveList(
      items: List<FmNode>.from(visible),
      hasMore: state.hasMore,
      loadingMore: state.status == FmListStatus.loadingMore,
      onRefresh: onRefresh,
      onLoadMore: onLoadMore,
      onFolderTap: onFolderTap,
      onFolderMore: onFolderMore,
      onFileTap: (_) {},
    );
  }
}
