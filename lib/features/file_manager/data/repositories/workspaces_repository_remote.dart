import '../../domain/models/fm_common_event.dart';
import '../../domain/models/fm_node.dart';
import '../../domain/models/fm_page.dart';
import '../../domain/repositories/workspaces_repository.dart';
import '../sources/workspaces_remote_source.dart';

/// Dio-backed implementation. Pass-through to [WorkspacesRemoteSource] —
/// feature logic (pagination cursor mapping) lives at the source layer.
class WorkspacesRepositoryRemote implements WorkspacesRepository {
  WorkspacesRepositoryRemote(this._remote);

  final WorkspacesRemoteSource _remote;

  @override
  Future<FmPage<FmFolder>> list({String? cursor, int limit = 20}) =>
      _remote.list(cursor: cursor, limit: limit);

  @override
  Future<List<FmCommonEvent>> listCommonEvents() =>
      _remote.listCommonEvents();
}
