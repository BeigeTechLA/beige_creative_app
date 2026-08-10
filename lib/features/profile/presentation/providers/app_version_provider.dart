import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final appVersionProvider = FutureProvider<String>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    final version = info.version.isEmpty ? '1.0.0' : info.version;
    final build = info.buildNumber;
    if (build.isNotEmpty) {
      return 'v$version ($build)';
    }
    return 'v$version';
  } catch (_) {
    return 'v1.0.0';
  }
});
