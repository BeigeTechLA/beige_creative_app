import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_empty_state.dart';

/// Thin wrapper over [AppEmptyState] so screens can swap copy by context
/// without rewriting layout. Defaults match "no folders" for the root tab.
class FmEmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;

  const FmEmptyView({
    super.key,
    this.icon = Icons.folder_off_outlined,
    this.title = 'No folders yet',
    this.description,
  });

  const FmEmptyView.search({super.key, required String query})
    : icon = Icons.search_off,
      title = 'No matches',
      description = 'Try a different search term.';

  const FmEmptyView.folder({super.key})
    : icon = Icons.folder_open,
      title = 'Folder is empty',
      description = 'No files or subfolders here yet.';

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(icon: icon, title: title, description: description);
  }
}
