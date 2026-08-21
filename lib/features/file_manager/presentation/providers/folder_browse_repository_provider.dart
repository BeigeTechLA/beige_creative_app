import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/folder_browse_repository_dummy.dart';
import '../../data/repositories/folder_browse_repository_remote.dart';
import '../../data/sources/folder_browse_remote_source.dart';
import '../../domain/repositories/folder_browse_repository.dart';
import 'file_manager_repository_provider.dart' show useDummyFileManagerProvider;

final _folderBrowseRemoteSourceProvider = Provider<FolderBrowseRemoteSource>(
  (ref) => FolderBrowseRemoteSource(ref.watch(dioClientProvider)),
);

final folderBrowseRepositoryProvider = Provider<FolderBrowseRepository>((ref) {
  final useDummy = ref.watch(useDummyFileManagerProvider);
  if (useDummy) return FolderBrowseRepositoryDummy();
  return FolderBrowseRepositoryRemote(
    ref.watch(_folderBrowseRemoteSourceProvider),
  );
});
