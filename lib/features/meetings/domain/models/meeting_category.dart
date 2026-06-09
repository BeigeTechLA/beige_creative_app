enum MeetingCategory {
  commercial,
  editorial,
  corporate,
  podcast,
  privateEvents,
  socialContent,
  musicVideos,
}

extension MeetingCategoryX on MeetingCategory {
  String get label {
    switch (this) {
      case MeetingCategory.commercial:
        return 'Commercial & Advertising';
      case MeetingCategory.editorial:
        return 'Editorial';
      case MeetingCategory.corporate:
        return 'Corporate';
      case MeetingCategory.podcast:
        return 'Podcast & Shows';
      case MeetingCategory.privateEvents:
        return 'Private Events';
      case MeetingCategory.socialContent:
        return 'Social Content';
      case MeetingCategory.musicVideos:
        return 'Music Videos';
    }
  }
}
