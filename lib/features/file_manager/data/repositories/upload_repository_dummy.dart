import 'dart:io';

import '../../domain/models/fm_upload_item.dart';
import '../../domain/models/fm_upload_policy.dart';
import '../../domain/repositories/upload_repository.dart';

class UploadRepositoryDummy implements UploadRepository {
  @override
  Future<List<FmUploadPolicy>> getUploadPolicies(List<FmUploadItem> items) async {
    return items.map((item) {
      return FmUploadPolicy(
        filepath: item.filepath,
        uploadUrl: 'https://storage.googleapis.com/dummy-bucket/${item.filepath}',
        method: 'PUT',
        headers: {'Content-Type': item.fileContentType},
      );
    }).toList();
  }

  @override
  Future<void> uploadFileToStorage({
    required String uploadUrl,
    required File file,
    required Map<String, String> headers,
    String method = 'PUT',
    void Function(int sent, int total)? onProgress,
  }) async {
    final length = file.existsSync() ? await file.length() : 1000;
    onProgress?.call(length ~/ 2, length);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    onProgress?.call(length, length);
  }

  @override
  Future<void> confirmUploadBatch(List<FmUploadItem> items) async {}
}
