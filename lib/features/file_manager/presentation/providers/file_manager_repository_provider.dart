import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/file_manager_repository_dummy.dart';
import '../../data/repositories/file_manager_repository_remote.dart';
import '../../data/sources/file_manager_remote_source.dart';
import '../../domain/repositories/file_manager_repository.dart';

/// Toggles between the dummy in-memory repo and the remote Dio repo.
///
/// **Default `true` until backend endpoints land.** Plan §8 documents the
/// expected shape; flip to `false` once the API is confirmed and integration
/// tested end-to-end. Premature flip → 404 on every list.
final useDummyFileManagerProvider = StateProvider<bool>((_) => true);

final _remoteFileManagerSourceProvider = Provider<FileManagerRemoteSource>(
  (ref) => FileManagerRemoteSource(ref.watch(dioClientProvider)),
);

/// Single source of truth the UI watches. `ref.watch`es the flag so the
/// remote swap is a one-line change at app boot.
final fileManagerRepositoryProvider = Provider<FileManagerRepository>((ref) {
  final useDummy = ref.watch(useDummyFileManagerProvider);
  if (useDummy) {
    return FileManagerRepositoryDummy();
  }
  return FileManagerRepositoryRemote(
    ref.watch(_remoteFileManagerSourceProvider),
  );
});
