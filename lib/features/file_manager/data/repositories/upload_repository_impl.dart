import 'dart:io';

import '../../domain/models/fm_upload_item.dart';
import '../../domain/models/fm_upload_policy.dart';
import '../../domain/repositories/upload_repository.dart';
import '../sources/upload_remote_source.dart';

class UploadRepositoryImpl implements UploadRepository {
  UploadRepositoryImpl(this._remoteSource);

  final UploadRemoteSource _remoteSource;

  @override
  Future<List<FmUploadPolicy>> getUploadPolicies(List<FmUploadItem> items) =>
      _remoteSource.getUploadPolicies(items);

  @override
  Future<void> uploadFileToStorage({
    required String uploadUrl,
    required File file,
    required Map<String, String> headers,
    String method = 'PUT',
    void Function(int sent, int total)? onProgress,
  }) =>
      _remoteSource.uploadToStorage(
        uploadUrl: uploadUrl,
        file: file,
        headers: headers,
        method: method,
        onProgress: onProgress,
      );

  @override
  Future<void> confirmUploadBatch(List<FmUploadItem> items) =>
      _remoteSource.confirmUploads(items);
}
