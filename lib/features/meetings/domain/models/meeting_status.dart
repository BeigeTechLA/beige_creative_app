enum MeetingStatus {
  upcoming,
  completed,
  initiated,
  revision,
  pending,
  cancelled,
  rescheduled,
  scheduled,
}

extension MeetingStatusX on MeetingStatus {
  String get label {
    switch (this) {
      case MeetingStatus.upcoming:
        return 'Upcoming';
      case MeetingStatus.completed:
        return 'Completed';
      case MeetingStatus.initiated:
        return 'Initiated';
      case MeetingStatus.revision:
        return 'Revision';
      case MeetingStatus.pending:
        return 'Pending';
      case MeetingStatus.cancelled:
        return 'Cancelled';
      case MeetingStatus.rescheduled:
        return 'Rescheduled';
      case MeetingStatus.scheduled:
        return 'Scheduled';
    }
  }
}
