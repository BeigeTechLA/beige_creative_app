import 'package:beige_creative_app/app/assets.dart';

const List<String> kSignup3PortfolioNames = ['Vimeo', 'YouTube', 'Google Drive'];

const List<String> kSignup3PortfolioIcons = [
  AppAssets.v,
  AppAssets.youtube,
  AppAssets.googledrive,
];

const List<String> kSignup3SocialNames = [
  'Facebook',
  'Instagram',
  'TikTok',
  'Behance',
  'Website',
];

const List<String> kSignup3SocialIcons = [
  AppAssets.facebook,
  AppAssets.insta,
  AppAssets.tiktok,
  AppAssets.be,
  AppAssets.Ball,
];

String signup3SocialPlatformKey(String name) {
  switch (name.toLowerCase()) {
    case 'facebook':
      return 'facebook';
    case 'instagram':
      return 'instagram';
    case 'tiktok':
      return 'tiktok';
    case 'behance':
      return 'behance';
    case 'website':
      return 'website';
    default:
      return name.toLowerCase();
  }
}

String signup3PortfolioPlatformKey(String name) {
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

String signup3NormalizeUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  return 'https://$trimmed';
}
