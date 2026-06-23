import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colors.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../domain/entities/chat_details.dart';
import '../../domain/entities/participant.dart';
import '../providers/chat_details_providers.dart';
import 'widgets/details_hero_header.dart';
import 'widgets/details_section_card.dart';

class ChatDetailsScreen extends ConsumerWidget {
  const ChatDetailsScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(chatDetailsProvider(conversationId));

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
            onCta: () => ref.invalidate(chatDetailsProvider(conversationId)),
          ),
        ),
        data: (details) => _Body(
          details: details,
          onBack: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.details, required this.onBack});

  final ChatDetails details;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: DetailsHeroHeader(
            roomName: details.roomName,
            onBack: onBack,
          ),
        ),
        SliverToBoxAdapter(
          child: DetailsSectionCard(
            icon: Icons.people_outline,
            title: 'Participants',
            trailingCount: details.participants.length,
            initiallyExpanded: true,
            collapsible: false,
            body: _ParticipantsBody(items: details.participants),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
      ],
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
