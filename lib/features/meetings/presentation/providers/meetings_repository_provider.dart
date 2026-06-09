import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/meetings_repository_dummy.dart';
import '../../domain/repositories/meetings_repository.dart';

/// Routes all meetings reads/writes to the dummy in-memory source while
/// `true`. Flip to `false` in MT8 once the Dio-backed implementation lands.
final useDummyMeetingsProvider = Provider<bool>((ref) => true);

final _dummyMeetingsRepositoryProvider = Provider<MeetingsRepositoryDummy>(
  (ref) => MeetingsRepositoryDummy(),
);

final meetingsRepositoryProvider = Provider<MeetingsRepository>((ref) {
  // Single dummy impl today; switch arm added when MT8 lands the remote impl.
  // Reading the flag here keeps the provider graph stable for that swap.
  ref.watch(useDummyMeetingsProvider);
  return ref.watch(_dummyMeetingsRepositoryProvider);
});
