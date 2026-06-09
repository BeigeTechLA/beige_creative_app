enum MeetingPlatform { zoom, meet, teams }

extension MeetingPlatformX on MeetingPlatform {
  String get label {
    switch (this) {
      case MeetingPlatform.zoom:
        return 'Zoom';
      case MeetingPlatform.meet:
        return 'Google Meet';
      case MeetingPlatform.teams:
        return 'Microsoft Teams';
    }
  }
}
