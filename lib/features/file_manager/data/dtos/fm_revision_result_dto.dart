import '../../domain/models/fm_revision_action.dart';
import '../../domain/models/fm_revision_result.dart';
import 'fm_envelope_dto.dart';

/// Result of `POST /external-file-manager/revision-file/review`.
/// Two shapes depending on `action`:
///
/// ```json
/// // request_revision
/// { "action": "request_revision",
///   "versionNumber": 1,
///   "nextVersionNumber": 2,
///   "nextVersionPath": "…/Revisions/Version2" }
///
/// // approve
/// { "action": "approve",
///   "versionNumber": 1,
///   "finalDeliverable": { "id": "…", "path": "…", "name": "…" } }
/// ```
class FmRevisionResultDto {
  static FmRevisionResult fromJson(Map<String, dynamic> j) {
    final action = FmRevisionActionX.fromApi(j['action']?.toString()) ??
        FmRevisionAction.requestRevision;

    final deliverable = FmJson.asMap(j['finalDeliverable']);

    return FmRevisionResult(
      action: action,
      versionNumber: FmJson.asInt(j['versionNumber']) ?? 0,
      nextVersionNumber: FmJson.asInt(j['nextVersionNumber']),
      nextVersionPath: FmJson.nonEmpty(j['nextVersionPath']),
      finalDeliverable: deliverable == null
          ? null
          : FmRevisionDeliverable(
              id: (deliverable['id'] ?? '').toString(),
              path: (deliverable['path'] ?? '').toString(),
              name: (deliverable['name'] ?? '').toString(),
            ),
    );
  }
}
