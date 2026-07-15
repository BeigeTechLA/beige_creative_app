import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/spacing.dart';
import '../../../../shared/widgets/loading.dart';
import '../../domain/models/fm_node.dart';
import 'fm_file_card.dart';
import 'fm_folder_card.dart';

/// Renders a mixed list of [FmFolder] + [FmFile] using the dedicated card
/// per node kind. Triggers [onLoadMore] when the user scrolls within
/// [loadMoreThreshold] of the bottom and [hasMore] is true. Caller owns
/// pagination state; this widget is purely presentational.
class FmRecursiveList extends StatefulWidget {
  final List<FmNode> items;
  final bool hasMore;
  final bool loadingMore;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final void Function(FmFolder) onFolderTap;
  final void Function(FmFolder)? onFolderMore;
  final void Function(FmFile) onFileTap;
  final void Function(FmFile)? onFileMore;
  final double loadMoreThreshold;
  final bool isMultiSelectMode;
  final Set<String> selectedFileIds;
  final void Function(String fileId, bool selected)? onFileSelectedChanged;

  const FmRecursiveList({
    super.key,
    required this.items,
    required this.hasMore,
    required this.loadingMore,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onFolderTap,
    required this.onFileTap,
    this.onFolderMore,
    this.onFileMore,
    this.loadMoreThreshold = 240,
    this.isMultiSelectMode = false,
    this.selectedFileIds = const {},
    this.onFileSelectedChanged,
  });

  @override
  State<FmRecursiveList> createState() => _FmRecursiveListState();
}

class _FmRecursiveListState extends State<FmRecursiveList> {
  bool _onScroll(ScrollNotification n) {
    if (!widget.hasMore || widget.loadingMore) return false;
    final pixels = n.metrics.pixels;
    final max = n.metrics.maxScrollExtent;
    if (max - pixels < widget.loadMoreThreshold) {
      widget.onLoadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final showMoreSpinner = widget.loadingMore;
    final itemCount = widget.items.length + (showMoreSpinner ? 1 : 0);

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.base,
          ),
          itemCount: itemCount,
          separatorBuilder: (_, _) =>
              const SizedBox(height: AppSpacing.cardGap),
          itemBuilder: (context, index) {
            if (showMoreSpinner && index == itemCount - 1) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.base),
                child: Center(
                  child: AppCircularLoader(
                    size: 22,
                    strokeWidth: 2.4,
                    color: AppColors.primary,
                  ),
                ),
              );
            }
            final node = widget.items[index];
            return switch (node) {
              FmFolder() => FmFolderCard(
                folder: node,
                onTap: () => widget.onFolderTap(node),
                onMore: widget.onFolderMore == null
                    ? null
                    : () => widget.onFolderMore!(node),
              ),
              FmFile() => FmFileCard(
                file: node,
                onTap: () => widget.onFileTap(node),
                onMore: widget.onFileMore == null
                    ? null
                    : () => widget.onFileMore!(node),
                isMultiSelectMode: widget.isMultiSelectMode,
                isSelected: widget.selectedFileIds.contains(node.id),
                onSelectedChanged: widget.onFileSelectedChanged == null
                    ? null
                    : (val) => widget.onFileSelectedChanged!(node.id, val ?? false),
              ),
            };
          },
        ),
      ),
    );
  }
}
