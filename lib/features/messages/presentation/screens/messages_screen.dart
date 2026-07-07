import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_main_toolbar.dart';
import '../../../../shared/widgets/loading.dart';
import '../providers/conversation_list_providers.dart';
import '../routes/messages_args.dart';
import 'widgets/conversation_tile.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openChat(String conversationId, String contactName) {
    context.pushNamed(
      Routes.chat.name,
      extra: ChatArgs(
        conversationId: conversationId,
        contactName: contactName,
      ).toExtra(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationListProvider);
    final notifier = ref.read(conversationListProvider.notifier);

    return SafeArea(
      child: Column(
        children: [
          const AppMainToolbar(title: 'Message'),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
            child: _SearchRow(
              controller: _searchCtrl,
              onChanged: notifier.updateSearch,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: notifier.refresh,
              child: _ListBody(
                state: state,
                onOpen: _openChat,
                onRetry: notifier.refresh,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.dividerDark),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: AppColors.textTertiary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
                hintText: 'Search conversation...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListBody extends StatelessWidget {
  const _ListBody({
    required this.state,
    required this.onOpen,
    required this.onRetry,
  });

  final ConversationListState state;
  final void Function(String conversationId, String contactName) onOpen;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.items.isEmpty) {
      return const AppScreenLoader();
    }
    if (state.errorMessage != null && state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          AppEmptyState(
            icon: Icons.error_outline,
            title: 'Could not load',
            description: state.errorMessage,
            ctaLabel: 'Retry',
            onCta: () => onRetry(),
          ),
        ],
      );
    }
    if (state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 80),
          AppEmptyState(
            icon: Icons.forum_outlined,
            title: 'No conversations',
            description: 'New messages will appear here.',
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.items.length,
      separatorBuilder: (_, _) => const Divider(
        color: AppColors.dividerDark,
        height: 1,
        indent: AppSpacing.screenH,
        endIndent: AppSpacing.screenH,
      ),
      itemBuilder: (context, index) {
        final c = state.items[index];
        return ConversationTile(
          conversation: c,
          onTap: () => onOpen(c.id, c.title),
        );
      },
    );
  }
}
