import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';

import '../../domain/models/fm_node.dart';
import '../../domain/repositories/file_manager_repository.dart';
import 'file_manager_repository_provider.dart';
import 'node_action_state.dart';

class NodeActionNotifier extends AutoDisposeNotifier<NodeActionState> {
  late FileManagerRepository _repo;

  @override
  NodeActionState build() {
    _repo = ref.watch(fileManagerRepositoryProvider);
    return const NodeActionState();
  }

  /// Copies a share URL to the clipboard. (`share_plus` not yet on the
  /// dependency list — copy + snackbar matches the existing meetings link
  /// affordance. Swap to native share when product asks for it.)
  Future<void> share({required String nodeId, required FmNodeKind kind}) async {
    if (state.isSharing(nodeId)) return;
    state = state.copyWith(
      sharingIds: {...state.sharingIds, nodeId},
      clearSignal: true,
    );
    try {
      final url = await _repo.getShareLink(nodeId: nodeId, kind: kind);
      await Clipboard.setData(ClipboardData(text: url));
      state = state.copyWith(
        sharingIds: state.sharingIds.difference({nodeId}),
        lastSignal: const FmActionSignal(
          kind: FmActionSignalKind.shareCopied,
          message: 'Share link copied to clipboard',
        ),
      );
    } catch (e) {
      state = state.copyWith(
        sharingIds: state.sharingIds.difference({nodeId}),
        lastSignal: FmActionSignal(
          kind: FmActionSignalKind.error,
          message: 'Failed to generate share link',
        ),
      );
    }
  }

  /// Downloads a file to a temp path then opens it via [OpenFile]. Updates
  /// `downloadProgress[fileId]` 0..1 along the way.
  Future<void> download({required String fileId}) async {
    if (state.isDownloading(fileId)) return;
    final progress = {...state.downloadProgress, fileId: 0.0};
    state = state.copyWith(downloadProgress: progress, clearSignal: true);

    try {
      final path = await _repo.downloadFile(
        fileId: fileId,
        onProgress: (p) {
          final next = {...state.downloadProgress, fileId: p};
          state = state.copyWith(downloadProgress: next);
        },
      );
      final next = {...state.downloadProgress}..remove(fileId);
      state = state.copyWith(
        downloadProgress: next,
        lastSignal: const FmActionSignal(
          kind: FmActionSignalKind.downloaded,
          message: 'Download complete',
        ),
      );
      await OpenFile.open(path);
    } catch (e) {
      final next = {...state.downloadProgress}..remove(fileId);
      state = state.copyWith(
        downloadProgress: next,
        lastSignal: const FmActionSignal(
          kind: FmActionSignalKind.error,
          message: 'Download failed',
        ),
      );
    }
  }

  /// Deletes a node. Caller invalidates the appropriate listing notifier on
  /// success so the row drops without a refetch — returned bool reports
  /// whether the call succeeded.
  Future<bool> delete({
    required String nodeId,
    required FmNodeKind kind,
  }) async {
    if (state.isDeleting(nodeId)) return false;
    state = state.copyWith(
      deletingIds: {...state.deletingIds, nodeId},
      clearSignal: true,
    );
    try {
      await _repo.deleteNode(nodeId: nodeId, kind: kind);
      state = state.copyWith(
        deletingIds: state.deletingIds.difference({nodeId}),
        lastSignal: const FmActionSignal(
          kind: FmActionSignalKind.deleted,
          message: 'Deleted',
        ),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        deletingIds: state.deletingIds.difference({nodeId}),
        lastSignal: const FmActionSignal(
          kind: FmActionSignalKind.error,
          message: 'Delete failed',
        ),
      );
      return false;
    }
  }

  void clearSignal() {
    if (state.lastSignal == null) return;
    state = state.copyWith(clearSignal: true);
  }
}

final nodeActionNotifierProvider =
    AutoDisposeNotifierProvider<NodeActionNotifier, NodeActionState>(
      NodeActionNotifier.new,
    );
