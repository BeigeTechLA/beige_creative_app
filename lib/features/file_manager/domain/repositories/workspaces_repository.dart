import '../models/fm_common_event.dart';
import '../models/fm_node.dart';
import '../models/fm_page.dart';

/// Root-level listing contract. Backed by two API endpoints:
///
/// - [list] → `GET /external-file-manager/workspaces` (project roots).
/// - [listCommonEvents] → `GET /external-file-manager/common-events`
///   (event roots surfaced under the Common Events tab).
///
/// Two implementations ship in tree: `WorkspacesRepositoryRemote`
/// (Dio) and `WorkspacesRepositoryDummy` (in-memory), toggled by
/// `useDummyFileManagerProvider`.
abstract class WorkspacesRepository {
  /// Fetches one page of project workspaces. `cursor` is the 1-indexed
  /// page number the notifier already saw; `null` requests page 1.
  /// `workspaceType` maps to the server-side `workspaceType` filter
  /// (e.g. `recent`); `null` returns the default (all) listing. The
  /// server does not implement `q` yet — search filters client-side in
  /// the notifier.
  Future<FmPage<FmFolder>> list({
    String? cursor,
    int limit = 20,
    String? workspaceType,
  });

  /// Fetches all common events. Backend does not paginate this endpoint
  /// in the current API doc, so the notifier treats the response as a
  /// single page (nextCursor = null).
  Future<List<FmCommonEvent>> listCommonEvents();
}
