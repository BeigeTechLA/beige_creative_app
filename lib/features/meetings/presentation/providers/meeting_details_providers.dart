import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/meeting.dart';
import 'meetings_repository_provider.dart';

final meetingDetailsProvider =
    AutoDisposeFutureProviderFamily<Meeting, String>((ref, id) {
  final repo = ref.watch(meetingsRepositoryProvider);
  return repo.getById(id);
});
