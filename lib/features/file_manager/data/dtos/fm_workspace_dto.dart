import '../../domain/models/fm_folder_key.dart';
import '../../domain/models/fm_linked_project.dart';
import '../../domain/models/fm_node.dart';
import '../../domain/models/fm_phase.dart';
import '../../domain/models/fm_workspace_meta.dart';
import '../../domain/models/link_state.dart';
import 'fm_envelope_dto.dart';

/// Workspace entry from `GET /external-file-manager/workspaces` and
/// (as `workspace` sub-object) from every folder-listing endpoint.
///
/// Sample:
///
/// ```json
/// {
///   "externalId": "3134",
///   "folderName": "private_neha_#3134",
///   "rootPath": "private_neha_#3134/",
///   "fullPath": "Website_Shoots_Flow/private_neha_#3134/",
///   "consoleUrl": "https://console.cloud.google.com/…",
///   "fileCount": 0,
///   "createdAt": "2026-04-13T12:14:03.001Z",
///   "updatedAt": "2026-04-13T12:14:04.239Z",
///   "isCommonEvent": true,
///   "eventId": 5,
///   "eventName": "Indexing",
///   "visibleUntil": null
/// }
/// ```
class FmWorkspaceDto {
  static FmFolder fromJson(Map<String, dynamic> j) {
    final rootPath = (j['rootPath'] ?? '').toString();
    final isCommonEvent = FmJson.asBool(j['isCommonEvent']);
    final eventName = FmJson.nonEmpty(j['eventName']);
    final externalId = (j['externalId'] ?? '').toString();

    return FmFolder(
      id: externalId,
      name: (j['folderName'] ?? '').toString(),
      fileCount: FmJson.asInt(j['fileCount']) ?? 0,
      openedAt: FmJson.asDate(j['updatedAt']),
      nextKey: FmFolderKey(externalId: externalId, phase: FmPhase.root),
      filepath: rootPath.isEmpty ? null : rootPath,
      // Common events carry their own event name as the tag; regular
      // linked workspaces don't emit a tag from this endpoint yet —
      // will bind through `linkedProject.title` once backend adds it.
      tagLabel: isCommonEvent ? eventName : null,
      linkState: isCommonEvent ? LinkState.linked : null,
      // `linkedProject` sub-object not part of `/workspaces` response —
      // populated later from the meetings feature when the two data
      // planes converge. Leave null here.
      linkedProject: null as FmLinkedProject?,
      workspaceMeta: FmWorkspaceMeta(
        rootPath: rootPath,
        fullPath: FmJson.nonEmpty(j['fullPath']),
        consoleUrl: FmJson.nonEmpty(j['consoleUrl']),
        isCommonEvent: isCommonEvent,
        eventId: FmJson.asInt(j['eventId']),
        eventName: eventName,
        visibleUntil: FmJson.asDate(j['visibleUntil']),
      ),
    );
  }
}

/// Pagination sidecar returned alongside `workspaces` on the list
/// endpoint. Kept separate so we can plug it into `FmPage<FmFolder>` at
/// the source layer without polluting the domain.
class FmPaginationDto {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const FmPaginationDto({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  static FmPaginationDto fromJson(Map<String, dynamic> j) => FmPaginationDto(
    page: FmJson.asInt(j['page']) ?? 1,
    limit: FmJson.asInt(j['limit']) ?? 0,
    total: FmJson.asInt(j['total']) ?? 0,
    totalPages: FmJson.asInt(j['totalPages']) ?? 1,
    hasNextPage: FmJson.asBool(j['hasNextPage']),
    hasPreviousPage: FmJson.asBool(j['hasPreviousPage']),
  );

  /// The 1-indexed page number the notifier should request next, or
  /// `null` if this is the last page. Matches the `FmPage.nextCursor`
  /// contract.
  String? get nextPageCursor => hasNextPage ? (page + 1).toString() : null;
}
