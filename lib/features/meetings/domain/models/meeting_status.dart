enum MeetingStatus { upcoming, completed, initiated, revision }

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
    }
  }
}
