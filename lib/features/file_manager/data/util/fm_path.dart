import '../../domain/models/fm_phase.dart';

/// Path composition helpers for the object-store `filepath` grammar the
/// backend expects on every mutation.
///
/// Grammar:
///
/// ```
/// <workspace.rootPath> + <phase-segment>/ + <relative>/ + <fileName>
/// ```
///
/// - `phase-segment` is `Pre-Production` / `Post-Production`, absent when
///   `phase == root`.
/// - Directory paths end with `/`; file paths do not.
class FmPath {
  const FmPath._();

  /// Joins path segments with a single `/` separator. Strips redundant
  /// separators at the boundary so callers can pass either
  /// `Edits/Revisions` or `Edits/Revisions/`.
  static String join(String a, String b) {
    if (a.isEmpty) return b;
    if (b.isEmpty) return a;
    final left = a.endsWith('/') ? a.substring(0, a.length - 1) : a;
    final right = b.startsWith('/') ? b.substring(1) : b;
    return '$left/$right';
  }

  /// Absolute folder path (trailing `/`) for a `{rootPath, phase, relative}`
  /// triple. Used to build the `filepath` for folder deletes and the
  /// destination paths for uploads.
  ///
  /// - `rootPath` = workspace's `rootPath` from the API (e.g.
  ///   `corporate_harsh_#4833/`).
  /// - `phase` = which of pre/post; `root` leaves the segment out entirely.
  /// - `relative` = path inside the phase (e.g. `Edits/Revisions`, or
  ///   empty for the phase root).
  static String folderPath({
    required String rootPath,
    required FmPhase phase,
    String relative = '',
  }) {
    var out = _ensureTrailingSlash(rootPath);
    final seg = phase.folderSegment;
    if (seg.isNotEmpty) out = _ensureTrailingSlash(join(out, seg));
    if (relative.isNotEmpty) {
      out = _ensureTrailingSlash(join(out, relative));
    }
    return out;
  }

  /// Absolute file path (no trailing `/`) for a file inside a phase-scoped
  /// folder.
  static String filePath({
    required String rootPath,
    required FmPhase phase,
    String relative = '',
    required String fileName,
  }) {
    final folder = folderPath(rootPath: rootPath, phase: phase, relative: relative);
    return '$folder$fileName';
  }

  /// True when a raw path is a folder — the API's convention is a trailing
  /// slash on directory entries.
  static bool isFolder(String path) => path.endsWith('/');

  /// Ensures the folder API delete contract — folder deletes require the
  /// trailing `/`, file deletes must not have one.
  static String forDelete({required String path, required bool isFolder}) {
    if (isFolder) return _ensureTrailingSlash(path);
    return path.endsWith('/') ? path.substring(0, path.length - 1) : path;
  }

  static String _ensureTrailingSlash(String s) =>
      s.endsWith('/') ? s : '$s/';
}
