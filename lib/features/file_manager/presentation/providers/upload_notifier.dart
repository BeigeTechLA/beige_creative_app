import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/fm_folder_key.dart';
import '../../domain/models/fm_upload_item.dart';
import '../../domain/repositories/upload_repository.dart';
import 'folder_contents_notifier.dart';
import 'upload_repository_provider.dart';
import 'upload_state.dart';

class UploadNotifier extends Notifier<UploadState> {
  late UploadRepository _uploadRepository;

  @override
  UploadState build() {
    _uploadRepository = ref.watch(uploadRepositoryProvider);
    return const UploadState();
  }

  /// Initiates an end-to-end upload sequence for the provided [items] to [folderKey].
  Future<bool> startUpload({
    required List<UploadTaskItem> items,
    required FmFolderKey folderKey,
  }) async {
    if (items.isEmpty) return true;

    state = UploadState(
      status: UploadBatchStatus.requestingPolicies,
      items: items,
    );

    // 1. Request presigned upload policies
    final uploadItems = items
        .map(
          (item) => FmUploadItem(
            filepath: item.remoteFilePath,
            fileContentType: item.mimeType,
            fileSize: item.sizeBytes,
            fileName: item.name,
          ),
        )
        .toList();

    Map<String, dynamic> policyByPath = {};
    try {
      final policies = await _uploadRepository.getUploadPolicies(uploadItems);
      for (final policy in policies) {
        policyByPath[policy.filepath] = policy;
      }
    } catch (e) {
      state = state.copyWith(
        status: UploadBatchStatus.failed,
        errorMessage: 'Failed to obtain upload authorization from server.',
      );
      return false;
    }

    // 2. Upload file bytes to cloud storage
    state = state.copyWith(status: UploadBatchStatus.uploading);
    final completedItems = <FmUploadItem>[];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final policy = policyByPath[item.remoteFilePath];

      if (policy == null) {
        _updateItemStatus(item.id, UploadItemStatus.failed, errorMessage: 'Missing upload policy');
        continue;
      }

      _updateItemStatus(item.id, UploadItemStatus.uploading);

      try {
        final file = File(item.localPath);
        await _uploadRepository.uploadFileToStorage(
          uploadUrl: policy.uploadUrl,
          file: file,
          headers: policy.headers,
          method: policy.method,
          onProgress: (sent, total) {
            _updateItemProgress(item.id, sent, total);
          },
        );

        _updateItemStatus(item.id, UploadItemStatus.completed);
        completedItems.add(
          FmUploadItem(
            filepath: item.remoteFilePath,
            fileContentType: item.mimeType,
            fileSize: item.sizeBytes,
            fileName: item.name,
          ),
        );
      } catch (e) {
        _updateItemStatus(
          item.id,
          UploadItemStatus.failed,
          errorMessage: e.toString(),
        );
      }
    }

    // 3. Confirm uploaded files batch with backend
    if (completedItems.isNotEmpty) {
      state = state.copyWith(status: UploadBatchStatus.confirming);
      try {
        await _uploadRepository.confirmUploadBatch(completedItems);
      } catch (e) {
        // Warning: Files uploaded to storage but confirmation failed
        state = state.copyWith(
          status: UploadBatchStatus.failed,
          errorMessage: 'Files uploaded to storage, but registration failed: $e',
        );
        return false;
      }

      // 4. Refresh folder contents
      try {
        ref.read(folderContentsNotifierProvider(folderKey).notifier).refresh();
      } catch (_) {}
    }

    final hasFailures = state.items.any((i) => i.status == UploadItemStatus.failed);
    state = state.copyWith(
      status: hasFailures ? UploadBatchStatus.failed : UploadBatchStatus.completed,
    );

    return !hasFailures;
  }

  void _updateItemProgress(String itemId, int sent, int total) {
    final updated = state.items.map((item) {
      if (item.id == itemId) {
        final progress = total > 0 ? (sent / total).clamp(0.0, 1.0) : 0.0;
        return item.copyWith(
          progress: progress,
          bytesSent: sent,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(items: updated);
  }

  void _updateItemStatus(
    String itemId,
    UploadItemStatus status, {
    String? errorMessage,
  }) {
    final updated = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(
          status: status,
          errorMessage: errorMessage,
          progress: status == UploadItemStatus.completed ? 1.0 : item.progress,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(items: updated);
  }

  void reset() {
    state = const UploadState();
  }
}

final uploadNotifierProvider = NotifierProvider<UploadNotifier, UploadState>(
  UploadNotifier.new,
);
