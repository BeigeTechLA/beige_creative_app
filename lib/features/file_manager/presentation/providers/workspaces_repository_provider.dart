import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/workspaces_repository_dummy.dart';
import '../../data/repositories/workspaces_repository_remote.dart';
import '../../data/sources/workspaces_remote_source.dart';
import '../../domain/repositories/workspaces_repository.dart';
import 'file_manager_repository_provider.dart' show useDummyFileManagerProvider;

/// Dio source is a singleton — swap it via override in tests.
final _workspacesRemoteSourceProvider = Provider<WorkspacesRemoteSource>(
  (ref) => WorkspacesRemoteSource(ref.watch(dioClientProvider)),
);

/// Root workspaces + common events. Toggled by the same
/// [useDummyFileManagerProvider] flag as the legacy `FileManagerRepository`
/// so a single flip switches the entire feature.
final workspacesRepositoryProvider = Provider<WorkspacesRepository>((ref) {
  final useDummy = ref.watch(useDummyFileManagerProvider);
  if (useDummy) return WorkspacesRepositoryDummy();
  return WorkspacesRepositoryRemote(
    ref.watch(_workspacesRemoteSourceProvider),
  );
});
