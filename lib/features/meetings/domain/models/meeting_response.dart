/// CP response to an external meeting invite. Also used as the participant's
/// current RSVP state on a meeting. Server enum on
/// `PATCH /external-meetings/:id/respond` body field `response` accepts
/// only `accepted` / `declined`; `pending` is read-only state.
enum MeetingResponse { pending, accepted, declined }

extension MeetingResponseX on MeetingResponse {
  String get serverValue {
    switch (this) {
      case MeetingResponse.pending:
        return 'pending';
      case MeetingResponse.accepted:
        return 'accepted';
      case MeetingResponse.declined:
        return 'declined';
    }
  }
}

/// Parses a raw server RSVP state into [MeetingResponse]. Returns `null` when
/// the field is absent or unrecognized so callers can treat as pending.
MeetingResponse? rsvpFromServer(String? raw) {
  switch (raw?.toLowerCase().trim()) {
    case 'accepted':
    case 'accept':
      return MeetingResponse.accepted;
    case 'declined':
    case 'decline':
    case 'rejected':
      return MeetingResponse.declined;
    case 'pending':
    case 'invited':
      return MeetingResponse.pending;
  }
  return null;
}
