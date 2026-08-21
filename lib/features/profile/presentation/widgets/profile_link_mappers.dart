import '../../../../app/assets.dart';

// Label/icon mappers shared between Myprofile and its link sheets.
// Pure functions; safe to move once the Notifier migration lands in 4.12.

String portfolioIcon(String key) {
  switch (key.toLowerCase()) {
    case 'youtube':
      return AppAssets.youtube;
    case 'vimeo':
      return AppAssets.vimeo;
    case 'google_drive':
      return AppAssets.googleDrive;
    default:
      return AppAssets.ball;
  }
}

String portfolioKey(String name) {
  switch (name.toLowerCase()) {
    case 'vimeo':
      return 'vimeo';
    case 'youtube':
      return 'youtube';
    case 'google drive':
      return 'google_drive';
    default:
      return name.toLowerCase();
  }
}

String formatPortfolioName(String key) {
  switch (key.toLowerCase()) {
    case 'youtube':
      return 'YouTube';
    case 'vimeo':
      return 'Vimeo';
    case 'google_drive':
      return 'Google Drive';
    default:
      return key;
  }
}

String socialPlatformKey(String name) {
  switch (name.toLowerCase()) {
    case 'facebook':
      return 'facebook';
    case 'instagram':
      return 'instagram';
    case 'tiktok':
      return 'tiktok';
    case 'behance':
      return 'behance';
    default:
      return name.toLowerCase();
  }
}

String socialIcon(String key) {
  switch (key.toLowerCase()) {
    case 'facebook':
      return AppAssets.facebook;
    case 'instagram':
      return AppAssets.insta;
    case 'tiktok':
      return AppAssets.tiktok;
    case 'behance':
      return AppAssets.behance;
    default:
      return AppAssets.ball;
  }
}
