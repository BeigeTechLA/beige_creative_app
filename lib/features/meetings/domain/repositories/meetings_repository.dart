import '../models/create_meeting_input.dart';
import '../models/meeting.dart';
import '../models/meeting_filter.dart';
import '../models/meeting_status.dart';

/// Stable interface for meetings. Backed by `MeetingsRepositoryDummy` in UI
/// phases (MT1-MT7). MT8 swaps in REST implementation behind the same
/// contract — UI never changes.
abstract class MeetingsRepository {
  Future<List<Meeting>> list({
    MeetingStatus? tab,
    MeetingFilter? filter,
  });

  Future<Meeting> getById(String id);

  Future<Meeting> create(CreateMeetingInput input);
}
