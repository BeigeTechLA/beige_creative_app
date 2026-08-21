import '../../domain/models/fm_copy_result.dart';
import 'fm_envelope_dto.dart';

/// Result of `POST /external-file-manager/copy-files` (Send For Edits).
///
/// ```json
/// "data": {
///   "total": 1,
///   "successCount": 1,
///   "failedCount": 0,
///   "sourcePath": "…",
///   "targetPath": "…",
///   "items": [
///     {
///       "sourcePath": "…",
///       "destinationPath": "…",
///       "success": true,
///       "metadata": { "id": "…", "name": "…", "size": 271606 }
///     }
///   ]
/// }
/// ```
class FmCopyResultDto {
  static FmCopyResult fromJson(Map<String, dynamic> j) {
    final items = FmJson.asList(j['items']).map(_itemFromJson).toList();
    return FmCopyResult(
      total: FmJson.asInt(j['total']) ?? items.length,
      successCount: FmJson.asInt(j['successCount']) ??
          items.where((i) => i.success).length,
      failedCount: FmJson.asInt(j['failedCount']) ??
          items.where((i) => !i.success).length,
      sourcePath: FmJson.nonEmpty(j['sourcePath']),
      targetPath: FmJson.nonEmpty(j['targetPath']),
      items: items,
    );
  }

  static FmCopyItem _itemFromJson(Map<String, dynamic> j) => FmCopyItem(
    sourcePath: (j['sourcePath'] ?? '').toString(),
    destinationPath: FmJson.nonEmpty(j['destinationPath']),
    success: FmJson.asBool(j['success']),
    errorMessage: FmJson.nonEmpty(j['error'] ?? j['errorMessage']),
  );
}
