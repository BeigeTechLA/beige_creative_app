import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_main_toolbar.dart';

/// Drawer-only future screen shell.
///
/// Keeps new menu destinations routable and visually consistent while their
/// real feature implementations are still pending.
class MenuPlaceholderScreen extends StatelessWidget {
  final String title;
  final String description;

  const MenuPlaceholderScreen({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppMainToolbar(title: title),
          Expanded(
            child: Center(
              child: AppEmptyState(
                icon: Icons.forum_outlined,
                title: title,
                description: description,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
