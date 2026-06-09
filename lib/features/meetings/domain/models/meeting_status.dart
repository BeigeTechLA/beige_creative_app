enum MeetingStatus { upcoming, completed, initiated, reviewer }

extension MeetingStatusX on MeetingStatus {
  String get label {
    switch (this) {
      case MeetingStatus.upcoming:
        return 'Upcoming';
      case MeetingStatus.completed:
        return 'Completed';
      case MeetingStatus.initiated:
        return 'Initiated';
      case MeetingStatus.reviewer:
        return 'Reviewer';
    }
  }
}
