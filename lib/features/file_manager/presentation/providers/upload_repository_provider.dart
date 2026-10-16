import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/upload_repository_dummy.dart';
import '../../data/repositories/upload_repository_impl.dart';
import '../../data/sources/upload_remote_source.dart';
import '../../domain/repositories/upload_repository.dart';
import 'file_manager_repository_provider.dart' show useDummyFileManagerProvider;

final uploadRemoteSourceProvider = Provider<UploadRemoteSource>(
  (ref) => UploadRemoteSource(ref.watch(dioClientProvider)),
);

final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  final useDummy = ref.watch(useDummyFileManagerProvider);
  if (useDummy) return UploadRepositoryDummy();
  return UploadRepositoryImpl(ref.watch(uploadRemoteSourceProvider));
});
