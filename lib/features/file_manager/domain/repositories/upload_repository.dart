import 'dart:io';

import '../models/fm_upload_item.dart';
import '../models/fm_upload_policy.dart';

/// Contract for File Manager file upload operations (presign, direct-to-cloud-storage PUT,
/// and batch confirmation).
abstract class UploadRepository {
  /// `POST /external-file-manager/upload-policies/batch`
  /// Requests presigned upload URLs for each item in [items].
  Future<List<FmUploadPolicy>> getUploadPolicies(List<FmUploadItem> items);

  /// Streams raw file bytes directly to [uploadUrl] via HTTP PUT (or specified method)
  /// using the provided [headers].
  ///
  /// Emits progress callbacks [onProgress] with (bytesSent, totalBytes).
  Future<void> uploadFileToStorage({
    required String uploadUrl,
    required File file,
    required Map<String, String> headers,
    String method = 'PUT',
    void Function(int sent, int total)? onProgress,
  });

  /// `POST /external-file-manager/files-uploaded/batch`
  /// Confirms and registers the uploaded files with the backend database.
  Future<void> confirmUploadBatch(List<FmUploadItem> items);
}
