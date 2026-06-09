import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_main_toolbar.dart';
import '../../domain/models/meeting_status.dart';
import '../providers/meetings_list_notifier.dart';
import '../providers/meetings_list_state.dart';
import '../widgets/meeting_card.dart';
import '../widgets/meeting_details_sheet.dart';
import '../widgets/meeting_filter_sheet.dart';
import '../widgets/meetings_tab_bar.dart';

class MeetingsScreen extends ConsumerWidget {
  const MeetingsScreen({super.key});

  Future<void> _openFilter(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(meetingsListNotifierProvider.notifier);
    final current = ref.read(meetingsListNotifierProvider).filter;
    final result = await showMeetingFilterSheet(context, current: current);
    if (result == null) return;
    notifier.applyFilter(result);
  }

  void _onJoin(BuildContext context, String link) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Join link: $link')),
    );
  }

  void _onCardTap(BuildContext context, String meetingId) {
    showMeetingDetailsSheet(context, meetingId: meetingId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(meetingsListNotifierProvider);
    final notifier = ref.read(meetingsListNotifierProvider.notifier);

    return SafeArea(
      child: Column(
        children: [
          AppMainToolbar(
            title: 'Meetings',
            trailing: Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  tooltip: 'Filter meetings',
                  onPressed: () => _openFilter(context, ref),
                  icon: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (state.isFiltered)
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: _FilterDot(),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
            ),
            child: MeetingsTabBar(
              selected: state.tab,
              onChanged: notifier.selectTab,
            ),
          ),
          AppSpacing.verticalBase,
          Expanded(
            child: RefreshIndicator(
              onRefresh: notifier.refresh,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: _ListBody(
                state: state,
                onTap: _onCardTap,
                onJoin: _onJoin,
                onRetry: notifier.refresh,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.sm,
              AppSpacing.base,
              AppSpacing.base,
            ),
            child: AppButton(
              label: 'Create Meeting',
              fullWidth: true,
              icon: Icons.add,
              onPressed: () =>
                  context.pushNamed(Routes.meetingCreate.name),
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
    required this.onTap,
    required this.onJoin,
    required this.onRetry,
  });

  final MeetingsListState state;
  final void Function(BuildContext, String meetingId) onTap;
  final void Function(BuildContext, String link) onJoin;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.status == MeetingsListStatus.loading && state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ],
      );
    }
    if (state.status == MeetingsListStatus.error && state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.textTertiary,
                  ),
                  AppSpacing.verticalBase,
                  Text(
                    'Could not load meetings',
                    style: AppTextStyles.titleSmall,
                  ),
                  AppSpacing.verticalSm,
                  Text(
                    state.error ?? 'Unknown error',
                    style: AppTextStyles.body14.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.verticalBase,
                  AppButton(label: 'Retry', onPressed: onRetry),
                ],
              ),
            ),
          ),
        ],
      );
    }
    if (state.items.isEmpty) {
      final tabLabel = state.tab == MeetingStatus.completed
          ? 'No completed meetings yet.'
          : 'No upcoming meetings yet.';
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 60),
          AppEmptyState(
            icon: Icons.event_outlined,
            title: 'Nothing here',
            description: state.isFiltered
                ? 'No meetings match the current filter.'
                : tabLabel,
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.xs,
        AppSpacing.base,
        AppSpacing.xs,
      ),
      itemCount: state.items.length,
      separatorBuilder: (_, _) => AppSpacing.verticalMd,
      itemBuilder: (context, i) {
        final m = state.items[i];
        return MeetingCard(
          meeting: m,
          onTap: () => onTap(context, m.id),
          onJoin: () => onJoin(context, m.link),
        );
      },
    );
  }
}

class _FilterDot extends StatelessWidget {
  const _FilterDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}
