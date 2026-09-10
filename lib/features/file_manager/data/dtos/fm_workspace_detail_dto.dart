import '../../domain/models/fm_folder_key.dart';
import '../../domain/models/fm_folder_contents.dart';
import '../../domain/models/fm_node.dart';
import '../../domain/models/fm_phase.dart';
import 'fm_envelope_dto.dart';
import 'fm_file_node_dto.dart';
import 'fm_folder_node_dto.dart';
import 'fm_workspace_dto.dart';

/// Response of `GET /external-file-manager/workspace/{externalId}` and
/// `GET /external-file-manager/workspace/{externalId}/files`.
///
/// Both endpoints share the same envelope shape:
///
/// ```json
/// {
///   "workspace": { … FmWorkspaceDto … },
///   "phase": "root" | "pre" | "post",   // /files only
///   "path": "…",                         // /files only
///   "basePath": "corporate_harsh_#4833/",
///   "folders": [ FmFolderNodeDto ],
///   "files":   [ FmFileNodeDto ]
/// }
/// ```
///
/// Missing `phase` + `path` retain the requested location when available.
class FmWorkspaceDetailDto {
  static FmFolderContents fromJson(
    Map<String, dynamic> j, {
    required String externalId,
    FmFolderKey? requestedKey,
  }) {
    final workspaceJson = FmJson.asMap(j['workspace']);
    final workspace = workspaceJson != null
        ? FmWorkspaceDto.fromJson(workspaceJson)
        : null;

    final phase = j['phase'] == null
        ? requestedKey?.phase ?? FmPhase.root
        : FmPhaseX.fromApi(j['phase']?.toString());
    final path = (j['path'] ?? requestedKey?.path ?? '').toString();
    final basePath = (j['basePath'] ?? '').toString();

    final key = FmFolderKey(externalId: externalId, phase: phase, path: path);
    final folders = FmJson.asList(
      j['folders'],
    ).map((f) => FmFolderNodeDto.fromJson(f, parent: key)).toList();
    final files = FmJson.asList(
      j['files'],
    ).map(FmFileNodeDto.fromJson).toList();

    return FmFolderContents(
      key: key,
      basePath: basePath,
      workspace: workspace,
      items: <FmNode>[...folders, ...files],
    );
  }
}
