import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../domain/models/file_type.dart';
import '../../domain/models/fm_comment.dart';
import '../../domain/models/fm_folder_key.dart';
import '../../domain/models/fm_node.dart';
import '../../domain/models/fm_revision_action.dart';
import '../providers/comments_notifier.dart';
import '../providers/file_ops_repository_provider.dart';
import '../providers/node_action_notifier.dart';
import 'fm_file_type_icon.dart';
import 'fm_status_pill.dart';
import 'fm_version_tag.dart';

/// Interactive, full-height bottom sheet for file preview, metadata, and
/// comments. Handles keyboard avoidance for the comment input. Comments
/// are loaded from `commentsNotifierProvider(fileMetaId)` where
/// `fileMetaId = file.filepath ?? file.id`.
class FmFilePreviewSheet extends ConsumerStatefulWidget {
  final FmFile file;

  /// Parent folder key. When null the Revision + Approve actions are
  /// disabled because we don't know the workspace's `externalId` — the
  /// revision endpoint requires it. Non-null when opened from the
  /// folder-contents screen.
  final FmFolderKey? folderKey;

  const FmFilePreviewSheet({super.key, required this.file, this.folderKey});

  static Future<void> show(
    BuildContext context,
    FmFile file, {
    FmFolderKey? folderKey,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.topHuge),
      builder: (context) => FmFilePreviewSheet(
        file: file,
        folderKey: folderKey,
      ),
    );
  }

  @override
  ConsumerState<FmFilePreviewSheet> createState() => _FmFilePreviewSheetState();
}

class _FmFilePreviewSheetState extends ConsumerState<FmFilePreviewSheet> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _posting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String get _fileMetaId => widget.file.filepath ?? widget.file.id;

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    }
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _posting) return;

    setState(() => _posting = true);
    try {
      await ref
          .read(commentsNotifierProvider(_fileMetaId).notifier)
          .post(text);
      if (!mounted) return;
      _commentController.clear();
      FocusScope.of(context).unfocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post comment: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  Future<void> _openReviewChooser() async {
    final action = await showModalBottomSheet<FmRevisionAction>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.topHuge),
      builder: (ctx) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: const Icon(Icons.check_circle_outline, color: AppColors.success),
              title: const Text('Approve'),
              subtitle: const Text('Move to Final Deliverables.'),
              onTap: () => Navigator.pop(ctx, FmRevisionAction.approve),
            ),
            const Divider(height: 1, color: AppColors.dividerDark),
            ListTile(
              leading: const Icon(Icons.change_circle_outlined, color: AppColors.warning),
              title: const Text('Request Revision'),
              subtitle: const Text('Create a new Version folder for the next cut.'),
              onTap: () => Navigator.pop(ctx, FmRevisionAction.requestRevision),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;
    await _reviewRevision(action);
  }

  Future<void> _reviewRevision(FmRevisionAction action) async {
    final folderKey = widget.folderKey;
    if (folderKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revision review needs a workspace context.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    final filepath = widget.file.filepath ?? widget.file.id;
    final ops = ref.read(fileOpsRepositoryProvider);
    try {
      final result = await ops.reviewRevision(
        externalId: folderKey.externalId,
        filepath: filepath,
        action: action,
      );
      if (!mounted) return;
      Navigator.pop(context); // dismiss preview sheet
      final label = switch (result.action) {
        FmRevisionAction.requestRevision =>
          'Revision requested — Version ${result.nextVersionNumber ?? '?'} folder created',
        FmRevisionAction.approve =>
          'Approved — file moved to Final Deliverables',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(label), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Revision review failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final filepath = _fileMetaId;
    final isDownloading = ref.watch(nodeActionNotifierProvider.select((s) => s.isDownloading(filepath)));
    final downloadProgress = ref.watch(nodeActionNotifierProvider.select((s) => s.downloadProgress[filepath]));
    final commentsAsync = ref.watch(commentsNotifierProvider(filepath));

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: Column(
          children: [
            // Top Drag Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  FmFileTypeIcon(type: widget.file.type, size: 40),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.file.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatSize(widget.file.sizeBytes),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textPrimary, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.dividerDark, height: 1),

            // Main Scrollable Area
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  // Badges (Version + Status)
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      if (widget.file.version != null)
                        FmVersionTag(
                          version: widget.file.version,
                          isLatest: widget.file.isLatest,
                        ),
                      if (widget.file.statusLabel != null)
                        FmStatusPill(label: widget.file.statusLabel!),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Actions Row
                  Row(
                    children: [
                      // Review button — opens a two-option chooser
                      // (Request Revision / Approve). Disabled when
                      // parent folderKey is unknown (see [FmFilePreviewSheet.show]).
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.folderKey == null
                              ? null
                              : _openReviewChooser,
                          icon: const Icon(Icons.rule, size: 18, color: AppColors.warning),
                          label: Text(
                            'Review',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.warning, width: 1.2),
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Download button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isDownloading
                              ? null
                              : () => ref.read(nodeActionNotifierProvider.notifier).downloadFile(filepath),
                          icon: isDownloading
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Icon(Icons.download_outlined, size: 18, color: AppColors.primary),
                          label: Text(
                            isDownloading
                                ? '${((downloadProgress ?? 0.0) * 100).toInt()}%'
                                : 'Download',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.borderGold, width: 1.2),
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Share button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => ref
                              .read(nodeActionNotifierProvider.notifier)
                              .shareFile(filepath: filepath, subject: widget.file.name),
                          icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.primary),
                          label: Text(
                            'Share',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.borderGold, width: 1.2),
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Media Box — tap-through to the OS handler. Per
                  // FILE_MANAGER_API_PLAN §4.9 the app never renders
                  // file bytes inline; tap fetches a signed view URL
                  // then hands off via `url_launcher(externalApplication)`.
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      onTap: () => ref
                          .read(nodeActionNotifierProvider.notifier)
                          .openFile(filepath),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMid,
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          border: Border.all(color: AppColors.dividerDark, width: 1),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.file.type == FileType.video
                                  ? Icons.play_circle_outline
                                  : Icons.open_in_new,
                              size: 48,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              widget.file.type == FileType.video
                                  ? 'Open in Player'
                                  : 'Open in Viewer',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Metadata Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceInput,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'File Details',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _metadataRow('Uploaded by', widget.file.uploaderName ?? 'Lana Guzman'),
                        _metadataRow(
                          'Last updated',
                          widget.file.openedAt != null
                              ? DateFormat('MMM dd, yyyy · hh:mm a').format(widget.file.openedAt!)
                              : 'June 26, 2026',
                        ),
                        _metadataRow('File type', widget.file.type.name.toUpperCase()),
                        _metadataRow('Current version', widget.file.version != null ? 'V${widget.file.version}' : 'V1'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Comments Header
                  Text(
                    'Comments${commentsAsync.hasValue ? ' (${_countAll(commentsAsync.value!)})' : ''}',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Comments list — async
                  ...commentsAsync.when(
                    loading: () => [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                    error: (e, _) => [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        alignment: Alignment.center,
                        child: Text(
                          'Could not load comments.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                    data: (comments) {
                      if (comments.isEmpty) {
                        return [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                            alignment: Alignment.center,
                            child: Text(
                              'No comments yet. Be the first to comment!',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                            ),
                          ),
                        ];
                      }
                      return [
                        for (final c in comments) _commentTile(c),
                      ];
                    },
                  ),
                ],
              ),
            ),

            // Fixed Comment Input Field at Bottom
            const Divider(color: AppColors.dividerDark, height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                        fillColor: AppColors.surfaceInput,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _postComment(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 20,
                    child: IconButton(
                      icon: _posting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : const Icon(Icons.send, color: AppColors.onPrimary, size: 18),
                      onPressed: _posting ? null : _postComment,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _countAll(List<FmComment> comments) {
    var n = comments.length;
    for (final c in comments) {
      n += c.replies.length;
    }
    return n;
  }

  Widget _commentTile(FmComment c, {bool isReply = false}) {
    final time = c.createdAt;
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppSpacing.md,
        left: isReply ? AppSpacing.lg : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                c.author.name.isEmpty ? 'Unknown' : c.author.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (time != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '•  ${DateFormat('hh:mm a').format(time)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            c.body,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          if (c.replies.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            for (final r in c.replies) _commentTile(r, isReply: true),
          ],
          if (!isReply) ...[
            const SizedBox(height: AppSpacing.xs),
            const Divider(color: AppColors.dividerDark, height: 1),
          ],
        ],
      ),
    );
  }

  Widget _metadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
