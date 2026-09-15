import 'package:flutter/foundation.dart';

enum UploadBatchStatus {
  idle,
  requestingPolicies,
  uploading,
  confirming,
  completed,
  failed,
}

enum UploadItemStatus {
  pending,
  uploading,
  completed,
  failed,
}

@immutable
class UploadTaskItem {
  final String id;
  final String name;
  final String localPath;
  final String remoteFilePath;
  final String mimeType;
  final int sizeBytes;
  final UploadItemStatus status;
  final double progress; // 0.0 to 1.0
  final int bytesSent;
  final String? errorMessage;

  const UploadTaskItem({
    required this.id,
    required this.name,
    required this.localPath,
    required this.remoteFilePath,
    required this.mimeType,
    required this.sizeBytes,
    this.status = UploadItemStatus.pending,
    this.progress = 0.0,
    this.bytesSent = 0,
    this.errorMessage,
  });

  UploadTaskItem copyWith({
    UploadItemStatus? status,
    double? progress,
    int? bytesSent,
    String? errorMessage,
  }) {
    return UploadTaskItem(
      id: id,
      name: name,
      localPath: localPath,
      remoteFilePath: remoteFilePath,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      bytesSent: bytesSent ?? this.bytesSent,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@immutable
class UploadState {
  final UploadBatchStatus status;
  final List<UploadTaskItem> items;
  final String? errorMessage;

  const UploadState({
    this.status = UploadBatchStatus.idle,
    this.items = const [],
    this.errorMessage,
  });

  bool get isUploading =>
      status == UploadBatchStatus.requestingPolicies ||
      status == UploadBatchStatus.uploading ||
      status == UploadBatchStatus.confirming;

  int get totalCount => items.length;
  int get uploadedCount =>
      items.where((i) => i.status == UploadItemStatus.completed).length;
  int get failedCount =>
      items.where((i) => i.status == UploadItemStatus.failed).length;
  int get pendingCount =>
      items.where((i) => i.status == UploadItemStatus.pending).length;

  int get totalBytes => items.fold(0, (sum, i) => sum + i.sizeBytes);
  int get totalBytesSent => items.fold(0, (sum, i) => sum + i.bytesSent);

  double get overallProgress {
    if (totalBytes == 0) return 0.0;
    return (totalBytesSent / totalBytes).clamp(0.0, 1.0);
  }

  UploadState copyWith({
    UploadBatchStatus? status,
    List<UploadTaskItem>? items,
    String? errorMessage,
  }) {
    return UploadState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }
}
