import 'package:beige_creative_app/app/assets.dart';

const List<String> kSignup3PortfolioNames = ['Vimeo', 'YouTube', 'Google Drive'];

const List<String> kSignup3PortfolioIcons = [
  AppAssets.vimeo,
  AppAssets.youtube,
  AppAssets.googleDrive,
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
  AppAssets.behance,
  AppAssets.ball,
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

/// Reverse of [signup3SocialPlatformKey]: maps a stored platform key
/// (e.g. `facebook`) back to its display name (e.g. `Facebook`) so
/// getProfile data can hydrate the step 3 social sheet.
String signup3SocialDisplayName(String platformKey) {
  final key = platformKey.trim().toLowerCase();
  for (final name in kSignup3SocialNames) {
    if (signup3SocialPlatformKey(name) == key) return name;
  }
  if (key.isEmpty) return '';
  return key[0].toUpperCase() + key.substring(1);
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

/// Reverse of [signup3PortfolioPlatformKey]: maps a stored platform key
/// (e.g. `google_drive`) back to its display name (e.g. `Google Drive`) so
/// getProfile data can hydrate the step 3 portfolio sheet.
String signup3PortfolioDisplayName(String platformKey) {
  final key = platformKey.trim().toLowerCase();
  for (final name in kSignup3PortfolioNames) {
    if (signup3PortfolioPlatformKey(name) == key) return name;
  }
  if (key.isEmpty) return '';
  return key[0].toUpperCase() + key.substring(1);
}

String signup3NormalizeUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  return 'https://$trimmed';
}

String signup3SocialIcon(String platformOrName) {
  switch (platformOrName.trim().toLowerCase()) {
    case 'facebook':
      return AppAssets.facebook;
    case 'instagram':
      return AppAssets.insta;
    case 'tiktok':
      return AppAssets.tiktok;
    case 'behance':
      return AppAssets.behance;
    case 'website':
      return AppAssets.ball;
    default:
      return AppAssets.ball;
  }
}

String signup3PortfolioIcon(String platformOrName) {
  switch (platformOrName.trim().toLowerCase()) {
    case 'vimeo':
      return AppAssets.vimeo;
    case 'youtube':
      return AppAssets.youtube;
    case 'google drive':
    case 'google_drive':
      return AppAssets.googleDrive;
    default:
      return AppAssets.ball;
  }
}

String signup3ResolveLinkIcon(String? icon, String? name) {
  if (icon != null && icon.isNotEmpty && icon != 'null') {
    return icon;
  }
  if (name == null || name.isEmpty) return AppAssets.icLink;
  final lower = name.trim().toLowerCase();
  if (lower == 'vimeo' ||
      lower == 'youtube' ||
      lower == 'google drive' ||
      lower == 'google_drive') {
    return signup3PortfolioIcon(lower);
  }
  return signup3SocialIcon(lower);
}

