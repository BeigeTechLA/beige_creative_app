import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/fm_phase.dart';
import '../../domain/repositories/file_ops_repository.dart';
import 'file_ops_repository_provider.dart';
import 'node_action_state.dart';

/// Universal kebab action handler. Every action goes through
/// [FileOpsRepository] to fetch a short-lived signed URL, then hands the
/// URL to the OS (`url_launcher` / `share_plus`) — the app never renders
/// file bytes inline (§4.9 of `FILE_MANAGER_API_PLAN.md`).
///
/// State is keyed by the resource's `filepath` (or fallback id for
/// dummy nodes). Widgets read `isSharing / isDownloading / isDeleting`
/// on the same string they pass into the command.
class NodeActionNotifier extends AutoDisposeNotifier<NodeActionState> {
  late FileOpsRepository _repo;

  @override
  NodeActionState build() {
    _repo = ref.watch(fileOpsRepositoryProvider);
    return const NodeActionState();
  }

  /// Shares a file via the system share sheet. Fetches a signed
  /// view-URL, then hands it to `share_plus`. Folders defer to the real
  /// `/share` OTP flow in FM9 — until then, folder share is disabled
  /// upstream (kebab omits the item).
  Future<void> shareFile({required String filepath, String? subject}) async {
    if (state.isSharing(filepath)) return;
    state = state.copyWith(
      sharingIds: {...state.sharingIds, filepath},
      clearSignal: true,
    );
    try {
      final signed = await _repo.viewUrl(filepath);
      // share_plus 10.x — `subject` not supported on `shareUri`; the
      // system share sheet uses the URL as its subject on iOS.
      await Share.shareUri(Uri.parse(signed.url));
      state = state.copyWith(
        sharingIds: state.sharingIds.difference({filepath}),
        lastSignal: const FmActionSignal(
          kind: FmActionSignalKind.shareCopied,
          message: 'Share sheet opened',
        ),
      );
    } catch (e) {
      state = state.copyWith(
        sharingIds: state.sharingIds.difference({filepath}),
        lastSignal: const FmActionSignal(
          kind: FmActionSignalKind.error,
          message: 'Failed to share file',
        ),
      );
    }
  }

  /// Downloads a file by handing the signed URL to the OS browser (which
  /// prompts the user for save location).
  Future<void> downloadFile(String filepath) async {
    if (state.isDownloading(filepath)) return;
    state = state.copyWith(
      downloadProgress: {...state.downloadProgress, filepath: 0.0},
      clearSignal: true,
    );
    try {
      final signed = await _repo.downloadUrl(filepath);
      await _openExternal(signed.url);
      final next = {...state.downloadProgress}..remove(filepath);
      state = state.copyWith(
        downloadProgress: next,
        lastSignal: const FmActionSignal(
          kind: FmActionSignalKind.downloaded,
          message: 'Opened in browser',
        ),
      );
    } catch (e) {
      final next = {...state.downloadProgress}..remove(filepath);
      state = state.copyWith(
        downloadProgress: next,
        lastSignal: const FmActionSignal(
          kind: FmActionSignalKind.error,
          message: 'Failed to open download',
        ),
      );
    }
  }

  /// Downloads a folder (server-generated ZIP). Same OS handoff as
  /// [downloadFile]. Progress keyed by [trackingKey] so the UI can gate
  /// its spinner — pass the folder's path so widgets share the same id.
  Future<void> downloadFolder({
    required String trackingKey,
    required String externalId,
    FmPhase? phase,
    String? path,
  }) async {
    if (state.isDownloading(trackingKey)) return;
    state = state.copyWith(
      downloadProgress: {...state.downloadProgress, trackingKey: 0.0},
      clearSignal: true,
    );
    try {
      final signed = await _repo.folderDownloadUrl(
        externalId: externalId,
        phase: phase,
        path: path,
      );
      await _openExternal(signed.url);
      final next = {...state.downloadProgress}..remove(trackingKey);
      state = state.copyWith(
        downloadProgress: next,
        lastSignal: const FmActionSignal(
          kind: FmActionSignalKind.downloaded,
          message: 'Opened folder download in browser',
        ),
      );
    } catch (e) {
      final next = {...state.downloadProgress}..remove(trackingKey);
      state = state.copyWith(
        downloadProgress: next,
        lastSignal: const FmActionSignal(
          kind: FmActionSignalKind.error,
          message: 'Failed to download folder',
        ),
      );
    }
  }

  /// Opens a file for viewing — same signed-URL + OS-handoff dance as
  /// [downloadFile], but backed by the view-url endpoint (which returns
  /// a URL that renders inline in the OS handler rather than triggering
  /// a download).
  Future<void> openFile(String filepath) async {
    try {
      final signed = await _repo.viewUrl(filepath);
      await _openExternal(signed.url);
    } catch (e) {
      state = state.copyWith(
        lastSignal: const FmActionSignal(
          kind: FmActionSignalKind.error,
          message: 'Failed to open file',
        ),
      );
    }
  }

  /// Deletes a file or folder. Folder deletes must carry a trailing `/`
  /// on [filepath] — callers should pass `FmPath.forDelete(...)` output
  /// or the folder's own `filepath` field. Returns whether the delete
  /// succeeded so the caller can decide whether to invalidate the
  /// folder-contents notifier.
  Future<bool> delete({required String filepath}) async {
    if (state.isDeleting(filepath)) return false;
    state = state.copyWith(
      deletingIds: {...state.deletingIds, filepath},
      clearSignal: true,
    );
    try {
      final result = await _repo.delete(filepath);
      state = state.copyWith(
        deletingIds: state.deletingIds.difference({filepath}),
        lastSignal: const FmActionSignal(
          kind: FmActionSignalKind.deleted,
          message: 'Deleted',
        ),
      );
      return result.deleted;
    } catch (e) {
      state = state.copyWith(
        deletingIds: state.deletingIds.difference({filepath}),
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

  Future<void> _openExternal(String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      throw StateError('launchUrl returned false for $url');
    }
  }
}

final nodeActionNotifierProvider =
    AutoDisposeNotifierProvider<NodeActionNotifier, NodeActionState>(
      NodeActionNotifier.new,
    );
