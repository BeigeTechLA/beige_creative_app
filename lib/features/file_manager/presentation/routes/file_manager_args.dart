import '../../domain/models/fm_folder_key.dart';
import '../../domain/models/fm_linked_project.dart';
import '../../domain/models/fm_phase.dart';

/// `state.extra` parser for the folder route. Carries the [FmFolderKey]
/// tuple (externalId comes from the path param; phase + path travel in
/// `extra`) plus screen-scoped display data (title, optional linked
/// project badge).
///
/// Callers construct the extra map explicitly — see [toExtra] for the
/// canonical builder. Missing / malformed fields fall back to
/// `phase = FmPhase.root, path = ''` so link-outs from external
/// surfaces don't crash on entry.
class FolderContentsArgs {
  final FmFolderKey key;
  final String title;
  final FmLinkedProject? linkedProject;

  const FolderContentsArgs({
    required this.key,
    required this.title,
    this.linkedProject,
  });

  static FolderContentsArgs fromRoute({
    required String externalId,
    required Object? extra,
  }) {
    final map = extra is Map<String, dynamic> ? extra : const <String, dynamic>{};

    final t = map['title'];
    final title = (t is String && t.isNotEmpty) ? t : 'Folder';

    // Prefer a pre-built key when the caller supplied one — it may
    // carry a computed phase transition the screen can't derive from
    // the path param alone.
    final providedKey = map['key'];
    final key = providedKey is FmFolderKey
        ? providedKey
        : FmFolderKey(
            externalId: externalId,
            phase: FmPhaseX.fromApi(map['phase']?.toString()),
            path: (map['path'] ?? '').toString(),
          );

    final p = map['linkedProject'];
    return FolderContentsArgs(
      key: key,
      title: title,
      linkedProject: p is FmLinkedProject ? p : null,
    );
  }

  /// Canonical builder for the `extra` payload. Screens should call this
  /// rather than assembling the map inline to keep the shape in one
  /// place.
  static Map<String, dynamic> toExtra({
    required FmFolderKey key,
    required String title,
    FmLinkedProject? linkedProject,
  }) => <String, dynamic>{
    'key': key,
    'phase': key.phase.apiValue,
    'path': key.path,
    'title': title,
    'linkedProject': ?linkedProject,
  };
}
