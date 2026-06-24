/// CP response to an external meeting invite. Server enum on
/// `PATCH /external-meetings/:id/respond` body field `response`.
enum MeetingResponse { accepted, declined }

extension MeetingResponseX on MeetingResponse {
  String get serverValue {
    switch (this) {
      case MeetingResponse.accepted:
        return 'accepted';
      case MeetingResponse.declined:
        return 'declined';
    }
  }
}
