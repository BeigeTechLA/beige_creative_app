import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/meetings_repository_impl.dart';
import '../../data/sources/meetings_remote_source.dart';
import '../../domain/repositories/meetings_repository.dart';

final _remoteMeetingsSourceProvider = Provider<MeetingsRemoteSource>(
  (ref) => MeetingsRemoteSource(
    ref.watch(dioClientProvider),
    ref.watch(sessionStoreProvider),
  ),
);

final meetingsRepositoryProvider = Provider<MeetingsRepository>(
  (ref) => MeetingsRepositoryImpl(ref.watch(_remoteMeetingsSourceProvider)),
);
