import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/file_ops_repository_dummy.dart';
import '../../data/repositories/file_ops_repository_remote.dart';
import '../../data/sources/file_ops_remote_source.dart';
import '../../domain/repositories/file_ops_repository.dart';
import 'file_manager_repository_provider.dart' show useDummyFileManagerProvider;

final _fileOpsRemoteSourceProvider = Provider<FileOpsRemoteSource>(
  (ref) => FileOpsRemoteSource(ref.watch(dioClientProvider)),
);

final fileOpsRepositoryProvider = Provider<FileOpsRepository>((ref) {
  final useDummy = ref.watch(useDummyFileManagerProvider);
  if (useDummy) return FileOpsRepositoryDummy();
  return FileOpsRepositoryRemote(ref.watch(_fileOpsRemoteSourceProvider));
});
