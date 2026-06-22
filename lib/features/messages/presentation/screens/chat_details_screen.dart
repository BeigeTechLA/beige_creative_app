import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../domain/entities/chat_details.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/shared_file.dart';
import '../providers/chat_details_providers.dart';
import 'widgets/details_hero_header.dart';
import 'widgets/details_section_card.dart';
import 'widgets/shared_file_row.dart';

class ChatDetailsScreen extends ConsumerStatefulWidget {
  const ChatDetailsScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends ConsumerState<ChatDetailsScreen> {
  late final TextEditingController _searchCtrl;
  String _searchQuery = '';

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

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(chatDetailsProvider(widget.conversationId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: detailsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: AppEmptyState(
            icon: Icons.error_outline,
            title: 'Could not load',
            description: e.toString(),
            ctaLabel: 'Retry',
            onCta: () =>
                ref.invalidate(chatDetailsProvider(widget.conversationId)),
          ),
        ),
        data: (details) {
          return _Body(
            details: details,
            searchCtrl: _searchCtrl,
            searchQuery: _searchQuery,
            onSearchChanged: (v) => setState(() => _searchQuery = v),
            onBack: () => Navigator.of(context).maybePop(),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.details,
    required this.searchCtrl,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onBack,
  });

  final ChatDetails details;
  final TextEditingController searchCtrl;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: DetailsHeroHeader(
            contact: details.contact,
            onBack: onBack,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.lg,
              AppSpacing.screenH,
              AppSpacing.sm,
            ),
            child: _SearchField(
              controller: searchCtrl,
              onChanged: onSearchChanged,
              query: searchQuery,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: DetailsSectionCard(
            icon: Icons.people_outline,
            title: 'Participants',
            trailingCount: details.participants.length,
            body: _ParticipantsBody(items: details.participants),
          ),
        ),
        SliverToBoxAdapter(
          child: DetailsSectionCard(
            icon: Icons.folder_outlined,
            title: 'Shared Files',
            trailingCount: details.sharedFiles.length,
            initiallyExpanded: true,
            body: details.sharedFiles.isEmpty
                ? const _EmptyText('No files shared yet.')
                : _SharedFilesBody(items: details.sharedFiles),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.query,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String query;

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
          const Icon(Icons.search, color: AppColors.textTertiary, size: 20),
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
                hintText: 'Search in conversation',
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

class _ParticipantsBody extends StatelessWidget {
  const _ParticipantsBody({required this.items});
  final List<Participant> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final p in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.surfaceInput,
                  child: Text(
                    p.name.isEmpty ? '?' : p.name.characters.first,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    p.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  p.role,
                  style: AppTextStyles.body11.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SharedFilesBody extends StatelessWidget {
  const _SharedFilesBody({required this.items});
  final List<SharedFile> items;

  @override
  Widget build(BuildContext context) {
    return Column(children: [for (final f in items) SharedFileRow(file: f)]);
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Text(
        text,
        style: AppTextStyles.body13.copyWith(color: AppColors.textTertiary),
      ),
    );
  }
}

