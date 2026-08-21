import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../screens/folder_contents_screen.dart';
import '../screens/success_screen.dart';
import 'file_manager_args.dart';

/// File-manager nested routes. The root `/files` tab lives in the
/// `StatefulShellRoute` in `lib/app/router.dart`. Files open externally
/// via the OS (`url_launcher`) — no in-app screen route.
final List<RouteBase> fileManagerRoutes = [
  GoRoute(
    path: Routes.filesFolder.path,
    name: Routes.filesFolder.name,
    builder: (context, state) {
      final externalId = state.pathParameters['id'] ?? '';
      final args = FolderContentsArgs.fromRoute(
        externalId: externalId,
        extra: state.extra,
      );
      return FolderContentsScreen(
        folderKey: args.key,
        title: args.title,
        linkedProject: args.linkedProject,
      );
    },
  ),
  GoRoute(
    path: Routes.filesSuccess.path,
    name: Routes.filesSuccess.name,
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>? ?? {};
      return SuccessScreen(
        title: extra['title']?.toString() ?? 'Success',
        message: extra['message']?.toString() ?? 'Operation completed successfully.',
        ctaText: extra['ctaText']?.toString() ?? 'Continue',
        onCtaPressed: extra['onCtaPressed'] as VoidCallback? ?? () => context.pop(),
      );
    },
  ),
];
