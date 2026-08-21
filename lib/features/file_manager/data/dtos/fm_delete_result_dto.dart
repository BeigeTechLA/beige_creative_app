import '../../domain/models/fm_delete_result.dart';
import 'fm_envelope_dto.dart';

/// Result of `POST /external-file-manager/delete`.
///
/// ```json
/// "data": {
///   "deleted": true,
///   "deletedCount": 1,
///   "metadataDeletedCount": 0,
///   "embeddingDeletedCount": 0
/// }
/// ```
class FmDeleteResultDto {
  static FmDeleteResult fromJson(Map<String, dynamic> j) {
    return FmDeleteResult(
      deleted: FmJson.asBool(j['deleted']),
      deletedCount: FmJson.asInt(j['deletedCount']) ?? 0,
      metadataDeletedCount: FmJson.asInt(j['metadataDeletedCount']) ?? 0,
      embeddingDeletedCount: FmJson.asInt(j['embeddingDeletedCount']) ?? 0,
    );
  }
}
