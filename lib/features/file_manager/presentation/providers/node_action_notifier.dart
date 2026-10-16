import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/util/fm_downloads_saver.dart';
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

  /// Downloads a file **in-app** and saves it to device storage (Downloads/Files).
  /// Streams byte progress directly to [state.downloadProgress[filepath]].
  Future<void> downloadFile(String filepath, {String? fileName}) async {
    if (state.isDownloading(filepath)) return;
    final keepAlive = ref.keepAlive();
    state = state.copyWith(
      downloadProgress: {...state.downloadProgress, filepath: 0.0},
      clearSignal: true,
    );
    try {
      final signed = await _repo.downloadUrl(filepath);
      final url = _preferHttps(signed.url);
      final savePath = await FmDownloadsSaver.resolvePath(
        fileName ?? filepath,
        isArchive: false,
      );
      await _repo.downloadArchive(
        url: url,
        savePath: savePath,
        onProgress: (received, total) {
          if (total <= 0) return;
          state = state.copyWith(
            downloadProgress: {
              ...state.downloadProgress,
              filepath: received / total,
            },
          );
        },
      );
      final next = {...state.downloadProgress}..remove(filepath);
      state = state.copyWith(
        downloadProgress: next,
        lastSignal: FmActionSignal(
          kind: FmActionSignalKind.downloaded,
          message: 'Saved to ${FmDownloadsSaver.displayLocation}',
        ),
      );
    } catch (e) {
      final next = {...state.downloadProgress}..remove(filepath);
      state = state.copyWith(
        downloadProgress: next,
        lastSignal: const FmActionSignal(
          kind: FmActionSignalKind.error,
          message: 'Failed to download file',
        ),
      );
    } finally {
      keepAlive.close();
    }
  }

  /// Downloads a folder (server-generated ZIP) **in-app** and saves it to
  /// device storage — no browser hand-off. The folder-download endpoint is
  /// authenticated, so the transfer runs through the Dio client (Bearer
  /// attached) rather than `launchUrl`. Real transfer progress is reported
  /// on [trackingKey] so the UI can show a determinate bar. Pass the
  /// folder's path as [trackingKey] so widgets share the same id, and
  /// [fileName] for a nicer saved-file name (defaults to the folder name).
  Future<void> downloadFolder({
    required String trackingKey,
    required String externalId,
    FmPhase? phase,
    String? path,
    String? fileName,
  }) async {
    if (state.isDownloading(trackingKey)) return;
    final keepAlive = ref.keepAlive();
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
      final url = _preferHttps(signed.url);
      final savePath = await FmDownloadsSaver.resolvePath(
        fileName ?? signed.filepath ?? path ?? externalId,
      );
      await _repo.downloadArchive(
        url: url,
        savePath: savePath,
        onProgress: (received, total) {
          if (total <= 0) return;
          state = state.copyWith(
            downloadProgress: {
              ...state.downloadProgress,
              trackingKey: received / total,
            },
          );
        },
      );
      final next = {...state.downloadProgress}..remove(trackingKey);
      state = state.copyWith(
        downloadProgress: next,
        lastSignal: FmActionSignal(
          kind: FmActionSignalKind.downloaded,
          message: 'Saved to ${FmDownloadsSaver.displayLocation}',
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
    } finally {
      keepAlive.close();
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

  /// The folder-download URL comes back as `http://api2.…beige.app/…`.
  /// Cleartext HTTP is blocked on Android release builds (and iOS ATS), so
  /// upgrade BEIGE hosts to `https` before the transfer.
  String _preferHttps(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    if (uri.scheme == 'http' && uri.host.endsWith('beige.app')) {
      return uri.replace(scheme: 'https').toString();
    }
    return url;
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw StateError('Download response contains an invalid URL');
    }
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
