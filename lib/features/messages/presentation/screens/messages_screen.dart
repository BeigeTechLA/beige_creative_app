import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_main_toolbar.dart';

// TODO(messaging): wire real transport once backend lead confirms websocket vs
// polling vs REST list. Until then this stays a presentation-only placeholder.
// Decision logged in MIGRATION_LOG.md (2026-05-29, Task 4.03).
class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SafeArea(
      child: Column(
        children: [
          AppMainToolbar(title: 'Messages'),
          Expanded(
            child: Center(
              child: AppEmptyState(
                icon: Icons.forum_outlined,
                title: 'Messages',
                description: 'Inbox arriving soon.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
