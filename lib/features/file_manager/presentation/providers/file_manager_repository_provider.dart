import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/file_manager_repository_dummy.dart';
import '../../data/repositories/file_manager_repository_remote.dart';
import '../../data/sources/file_manager_remote_source.dart';
import '../../domain/repositories/file_manager_repository.dart';

/// Real API data is the default across every File Manager screen.
/// Dummy repositories remain available only for explicit development overrides.
final useDummyFileManagerProvider = StateProvider<bool>((_) => false);

final _remoteFileManagerSourceProvider = Provider<FileManagerRemoteSource>(
  (ref) => FileManagerRemoteSource(ref.watch(dioClientProvider)),
);

/// Single source of truth the UI watches. `ref.watch`es the flag so the
/// remote swap is a one-line change at app boot.
// ignore: deprecated_member_use_from_same_package
final fileManagerRepositoryProvider = Provider<FileManagerRepository>((ref) {
  final useDummy = ref.watch(useDummyFileManagerProvider);
  if (useDummy) {
    return FileManagerRepositoryDummy();
  }
  return FileManagerRepositoryRemote(
    ref.watch(_remoteFileManagerSourceProvider),
  );
});
