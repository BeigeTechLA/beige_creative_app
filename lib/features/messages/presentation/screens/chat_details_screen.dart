import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/loading.dart';
import '../../domain/entities/chat_details.dart';
import '../../domain/entities/participant.dart';
import '../../domain/role_label.dart';
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
        loading: () => const AppScreenLoader(),
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
          child: DetailsHeroHeader(roomName: details.roomName, onBack: onBack),
        ),
        SliverToBoxAdapter(
          child: DetailsSectionCard(
            leading: SvgPicture.asset(
              AppAssets.icGroupChat,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            title: 'Participants',
            trailingCount: details.participants.length,
            initiallyExpanded: true,
            collapsible: false,
            backgroundColor: AppColors.participantBoxBg,
            titleColor: AppColors.primary,
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

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length > 1) {
      final first = parts[0].isNotEmpty ? parts[0][0] : '';
      final second = parts[1].isNotEmpty ? parts[1][0] : '';
      return (first + second).toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }

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
                  radius: 18,
                  backgroundColor: AppColors.primary20,
                  child: Text(
                    _getInitials(p.name),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    p.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (roleLabel(p.role).isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    roleLabel(p.role),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
