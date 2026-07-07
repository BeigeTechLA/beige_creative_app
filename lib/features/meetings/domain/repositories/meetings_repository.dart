import '../models/meeting.dart';
import '../models/meeting_filter.dart';
import '../models/meeting_response.dart';
import '../models/meetings_tab.dart';
import '../models/update_meeting_input.dart';

/// Stable interface for meetings. Backed by `MeetingsRepositoryImpl` (Dio)
/// against the `external-meetings` REST surface. Test fakes implement this
/// contract directly (see `_FakeMeetingsRepository` in the meetings screen
/// widget test) so production code never branches on test vs prod.
///
/// `update`/`delete`/`addParticipants` carry plumbing parity with the
/// crew-side app — wire them when Edit/Delete/Invite UI affordances ship.
abstract class MeetingsRepository {
  /// Tab drives the server-side `meeting_time_status` filter.
  /// [filter] runs client-side over the fetched page.
  /// [currentUserId] is threaded to the DTO for `myResponse` derivation.
  Future<List<Meeting>> list({
    MeetingsTab? tab,
    MeetingFilter? filter,
    String? currentUserId,
  });

  Future<Meeting> getById(String id);

  /// Partial update — every field on [patch] nullable, `null` = unchanged.
  /// Server recomputes `duration`; impl never sends it.
  Future<Meeting> update(String id, UpdateMeetingInput patch);

  /// Hard or soft delete — backend behavior undocumented. Caller treats 2xx
  /// as success.
  Future<void> delete(String id);

  /// Attaches participants to an existing meeting. Returns the full updated
  /// Meeting. Used internally by `create` to complete the 2-step create flow;
  /// also surfaced for a future "add participant" UI affordance.
  Future<Meeting> addParticipants(String id, List<String> userIds);

  /// Records the signed-in user's RSVP on the meeting. Server returns the
  /// updated Meeting so callers can refresh local state.
  Future<Meeting> respond(String id, MeetingResponse response);
}
