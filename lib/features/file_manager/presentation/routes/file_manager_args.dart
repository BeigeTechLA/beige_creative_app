import '../../domain/models/fm_linked_project.dart';

/// `state.extra` parsers for file-manager nested routes.
///
/// Both routes carry the entity id in the path param and the display title
/// in `extra` so the destination screen can render its app-bar without a
/// second fetch. For the folder route, `extra` may also pre-seed the
/// linked-project badge — the screen reads it if present.
class FolderContentsArgs {
  final String title;
  final FmLinkedProject? linkedProject;

  const FolderContentsArgs({required this.title, this.linkedProject});

  static FolderContentsArgs fromExtra(Object? extra) {
    if (extra is Map<String, dynamic>) {
      final t = extra['title'];
      final p = extra['linkedProject'];
      final title = (t is String && t.isNotEmpty) ? t : 'Folder';
      return FolderContentsArgs(
        title: title,
        linkedProject: p is FmLinkedProject ? p : null,
      );
    }
    return const FolderContentsArgs(title: 'Folder');
  }
}

