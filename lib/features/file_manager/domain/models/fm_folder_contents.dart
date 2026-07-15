import 'package:flutter/foundation.dart';

import 'fm_folder_key.dart';
import 'fm_node.dart';

/// Result of `GET /external-file-manager/workspace/{externalId}/files`.
///
/// The API returns folders and files in two separate arrays; we surface
/// them as one `List<FmNode>` in server order because `FmRecursiveList`
/// renders a single flat list. Sort order is server-driven — UI does
/// not re-sort.
@immutable
class FmFolderContents {
  /// The key that produced this page — used by the notifier when
  /// invalidating siblings after a mutation.
  final FmFolderKey key;

  /// Workspace-root folder the API attached for header rendering
  /// (breadcrumb chip, project badge). May be null for common-event
  /// listings where the workspace concept doesn't apply.
  final FmFolder? workspace;

  /// Absolute path of this folder (`basePath` in the API payload).
  /// Trailing `/`. Used to compose child `filepath`s.
  final String basePath;

  /// Ordered list of children (folders first, then files, in the order
  /// the API returned them).
  final List<FmNode> items;

  const FmFolderContents({
    required this.key,
    required this.basePath,
    required this.items,
    this.workspace,
  });
}
