import '../models/meeting.dart';
import '../models/meeting_status.dart';

/// RSVP cutoff: hide Accept/Reject once the meeting is within this window.
const Duration kRsvpCutoff = Duration(hours: 1);

/// Whether RSVP (Accept / Reject) controls should be shown for [meeting].
///
/// Returns false when the meeting is completed or when the start time is
/// less than [kRsvpCutoff] away (including already started / past meetings).
/// [now] is injectable for tests; defaults to `DateTime.now()`.
bool canRsvpToMeeting(Meeting meeting, {DateTime? now}) {
  if (meeting.status == MeetingStatus.completed) return false;
  final reference = now ?? DateTime.now();
  return meeting.startAt.difference(reference) > kRsvpCutoff;
}
