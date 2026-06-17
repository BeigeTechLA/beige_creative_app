import '../models/create_meeting_input.dart';
import '../models/meeting.dart';
import '../models/meeting_filter.dart';
import '../models/meeting_status.dart';
import '../models/update_meeting_input.dart';

/// Stable interface for meetings. Backed by `MeetingsRepositoryImpl` (Dio)
/// against the `external-meetings` REST surface. Test fakes implement this
/// contract directly (see `_FakeMeetingsRepository` in the meetings screen
/// widget test) so production code never branches on test vs prod.
///
/// `update`/`delete`/`addParticipants` were added in MT8.05 ahead of any UI
/// surface — wire them when Edit/Delete/Invite affordances ship.
abstract class MeetingsRepository {
  Future<List<Meeting>> list({
    MeetingStatus? tab,
    MeetingFilter? filter,
  });

  Future<Meeting> getById(String id);

  Future<Meeting> create(CreateMeetingInput input);

  /// Partial update — every field on [patch] nullable, `null` = unchanged.
  /// Server recomputes `duration`; impl never sends it.
  Future<Meeting> update(String id, UpdateMeetingInput patch);

  /// Hard or soft delete — backend behavior undocumented
  /// (`MEETINGS_API.md` §6). Caller treats 2xx as success.
  Future<void> delete(String id);

  /// Attaches participants to an existing meeting. Returns the full updated
  /// Meeting (server response per `MEETINGS_API.md` §4). Used internally by
  /// `create` to complete the 2-step create flow; also surfaced for future
  /// "add participant" UI affordance.
  Future<Meeting> addParticipants(String id, List<String> userIds);
}
