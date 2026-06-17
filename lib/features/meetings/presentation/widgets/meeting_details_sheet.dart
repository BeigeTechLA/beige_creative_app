import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/models/meeting.dart';
import '../providers/meeting_details_providers.dart';
import '../util/launch_meeting_link.dart';
import 'meeting_agenda_tile.dart';
import 'meeting_participant_tile.dart';

Future<void> showMeetingDetailsSheet(
  BuildContext context, {
  required String meetingId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MeetingDetailsSheet(meetingId: meetingId),
  );
}

class MeetingDetailsSheet extends ConsumerWidget {
  const MeetingDetailsSheet({super.key, required this.meetingId});

  final String meetingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(meetingDetailsProvider(meetingId));

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: AppRadii.topSheet,
          ),
          child: SafeArea(
            top: false,
            child: detailsAsync.when(
              data: (m) => _DetailsBody(
                meeting: m,
                scrollController: scrollController,
              ),
              loading: () => _SheetShell(
                scrollController: scrollController,
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
              error: (e, _) => _SheetShell(
                scrollController: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 40,
                        color: AppColors.textTertiary,
                      ),
                      AppSpacing.verticalBase,
                      Text(
                        'Could not load meeting',
                        style: AppTextStyles.titleSmall,
                      ),
                      AppSpacing.verticalSm,
                      Text(
                        '$e',
                        style: AppTextStyles.body14.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.verticalBase,
                      AppButton(
                        label: 'Retry',
                        onPressed: () =>
                            ref.invalidate(meetingDetailsProvider(meetingId)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.scrollController, required this.child});
  final ScrollController scrollController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      children: [
        const _Handle(),
        const _SheetHeader(),
        child,
      ],
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.meeting, required this.scrollController});

  final Meeting meeting;
  final ScrollController scrollController;

  static final _dateFmt = DateFormat('dd MMM yyyy');
  static final _timeFmt = DateFormat('hh:mm a');

  void _onEdit(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit meeting — coming soon')),
    );
  }

  void _onJoin(BuildContext context) {
    launchMeetingLink(context, meeting.link);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          controller: scrollController,
          padding: const EdgeInsets.only(bottom: 92),
          children: [
            const _Handle(),
            const _SheetHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          meeting.title,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit meeting',
                        onPressed: () => _onEdit(context),
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalMd,
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _MetaChip(
                        icon: Icons.calendar_today_outlined,
                        label: _dateFmt.format(meeting.startAt),
                      ),
                      _MetaChip(
                        icon: Icons.schedule_outlined,
                        label:
                            '${_timeFmt.format(meeting.startAt)} – ${_timeFmt.format(meeting.endAt)}',
                      ),
                    ],
                  ),
                  AppSpacing.verticalBase,
                  _LabeledRow(
                    label: 'Project',
                    value: meeting.project,
                  ),
                  AppSpacing.verticalXl,
                  _SectionHeader(label: 'Agenda', count: meeting.agenda.length),
                  AppSpacing.verticalSm,
                  for (var i = 0; i < meeting.agenda.length; i++)
                    MeetingAgendaTile(index: i, text: meeting.agenda[i]),
                  AppSpacing.verticalXl,
                  _SectionHeader(
                    label: 'Participants',
                    count: meeting.participants.length,
                  ),
                  AppSpacing.verticalSm,
                  for (final p in meeting.participants)
                    MeetingParticipantTile(participant: p),
                  AppSpacing.verticalXl,
                ],
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.dividerDark, width: 1),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.base,
            ),
            child: AppButton(
              label: 'Join Meeting',
              fullWidth: true,
              icon: Icons.videocam_outlined,
              onPressed: () => _onJoin(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Center(
        child: Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.dividerDark,
            borderRadius: AppRadii.fullAll,
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.base,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Text('Meeting Details', style: AppTextStyles.titleMedium),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.dividerDark, height: 1),
        AppSpacing.verticalBase,
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.smAll,
        border: Border.all(color: AppColors.dividerDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.body14.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _LabeledRow extends StatelessWidget {
  const _LabeledRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppTextStyles.body14.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body14.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.count});
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.body14Medium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '($count)',
          style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
