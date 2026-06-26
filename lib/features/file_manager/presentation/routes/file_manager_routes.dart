import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../screens/folder_contents_screen.dart';
import 'file_manager_args.dart';

/// File-manager nested routes. The root `/files` tab lives in the
/// `StatefulShellRoute` in `lib/app/router.dart`. Files open inline via
/// `CommonFileViewer.open` — no in-app screen route.
final List<RouteBase> fileManagerRoutes = [
  GoRoute(
    path: Routes.filesFolder.path,
    name: Routes.filesFolder.name,
    builder: (context, state) {
      final id = state.pathParameters['id'] ?? '';
      final args = FolderContentsArgs.fromExtra(state.extra);
      return FolderContentsScreen(
        folderId: id,
        title: args.title,
        linkedProject: args.linkedProject,
      );
    },
  ),
];
