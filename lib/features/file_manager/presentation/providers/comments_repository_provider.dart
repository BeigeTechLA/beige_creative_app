import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/comments_repository_dummy.dart';
import '../../data/repositories/comments_repository_remote.dart';
import '../../data/sources/comments_remote_source.dart';
import '../../domain/repositories/comments_repository.dart';
import 'file_manager_repository_provider.dart' show useDummyFileManagerProvider;

final _commentsRemoteSourceProvider = Provider<CommentsRemoteSource>(
  (ref) => CommentsRemoteSource(ref.watch(dioClientProvider)),
);

final commentsRepositoryProvider = Provider<CommentsRepository>((ref) {
  final useDummy = ref.watch(useDummyFileManagerProvider);
  if (useDummy) return CommentsRepositoryDummy();
  return CommentsRepositoryRemote(ref.watch(_commentsRemoteSourceProvider));
});
