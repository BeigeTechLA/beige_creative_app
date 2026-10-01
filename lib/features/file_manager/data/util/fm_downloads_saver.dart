import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Resolves an on-device save path for downloaded archives, using only
/// `path_provider` (no MediaStore / gallery dependency).
///
/// Platform behaviour (see FILE_MANAGER download decision, 2026-09-14):
/// - **Android** — the app-scoped external `Download/` directory
///   (`Android/data/<pkg>/files/Download`). It is browsable in the Files
///   app but is NOT the system-wide public Downloads folder; true public
///   Downloads on Android 10+ requires the MediaStore API, deliberately
///   skipped to avoid a native dependency.
/// - **iOS** — the app Documents directory, surfaced under
///   `On My iPhone / <App>` in the Files app via the `UIFileSharingEnabled`
///   and `LSSupportsOpeningDocumentsInPlace` Info.plist flags.
class FmDownloadsSaver {
  const FmDownloadsSaver._();

  /// Returns an absolute file path (directory guaranteed to exist) for
  /// [fileName]. The name is sanitised. If [isArchive] is true, `.zip` is
  /// ensured.
  static Future<String> resolvePath(
    String fileName, {
    bool isArchive = true,
  }) async {
    final safeName = _sanitize(fileName, isArchive: isArchive);
    final dir = await _targetDir();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return '${dir.path}/$safeName';
  }

  /// Human-readable location for user-facing confirmation copy.
  static String get displayLocation => Platform.isIOS ? 'Files' : 'Downloads';

  static Future<Directory> _targetDir() async {
    if (Platform.isAndroid) {
      final base = await getExternalStorageDirectory();
      if (base != null) return Directory('${base.path}/Download');
    }
    return getApplicationDocumentsDirectory();
  }

  static String _sanitize(String raw, {bool isArchive = true}) {
    var name = raw.trim();
    // Collapse to the trailing path segment if a full path slipped in.
    while (name.endsWith('/')) {
      name = name.substring(0, name.length - 1);
    }
    if (name.contains('/')) name = name.split('/').last;
    // Replace filesystem-hostile characters.
    name = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    if (name.isEmpty) name = isArchive ? 'download.zip' : 'download';
    if (isArchive && !name.toLowerCase().endsWith('.zip')) {
      name = '$name.zip';
    }
    return name;
  }
}
