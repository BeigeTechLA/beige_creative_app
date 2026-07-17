import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../../../shared/widgets/loading.dart';
import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_platform.dart';
import '../../domain/models/meeting_response.dart';
import '../../domain/models/meeting_status.dart';
import '../providers/meeting_details_providers.dart';
import '../util/launch_meeting_link.dart';
import 'meeting_participant_tile.dart';

Future<void> showMeetingDetailsSheet(
  BuildContext context, {
  required String meetingId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: false,
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
              data: (m) =>
                  _DetailsBody(meeting: m, scrollController: scrollController),
              loading: () => _SheetShell(
                scrollController: scrollController,
                child: const Center(child: AppScreenLoader(size: 40)),
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
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.verticalBase,
                      AppButton(
                        label: 'Retry',
                        variant: AppButtonVariant.outline,
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
      children: [const _Handle(), const _SheetHeader(), child],
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.meeting, required this.scrollController});

  final Meeting meeting;
  final ScrollController scrollController;

  static final _timeFmt = DateFormat('hh:mm a');

  String get _dateTimeLabel =>
      '${DateTimeUtils.formatMeetingDate(meeting.startAt)}, '
      '${_timeFmt.format(meeting.startAt)} - ${_timeFmt.format(meeting.endAt)}';

  /// Current user's RSVP — precomputed at the DTO boundary from the
  /// meeting-level `participant_responses[]` array against the session id.
  /// `null` when the user has not responded yet.
  MeetingResponse? get _myRsvp => meeting.myResponse;

  void _onJoin(BuildContext context) {
    launchMeetingLink(context, meeting.link);
  }

  Future<void> _onCopyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: meeting.link));
    if (!context.mounted) return;
    TopMessage.show(context, 'Link copied', type: TopMessageType.success);
  }

  @override
  Widget build(BuildContext context) {
    final myRsvp = _myRsvp;
    final agendaText = meeting.description.isNotEmpty
        ? meeting.description
        : meeting.agenda.join('\n');

    return Stack(
      children: [
        ListView(
          controller: scrollController,
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            const _Handle(),
            const _SheetHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusPill(status: meeting.status),
                  AppSpacing.verticalBase,
                  Text(
                    meeting.title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (myRsvp == MeetingResponse.accepted ||
                      myRsvp == MeetingResponse.declined) ...[
                    const SizedBox(height: 4),
                    Text(
                      myRsvp == MeetingResponse.accepted
                          ? '(Accepted)'
                          : '(Rejected)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: myRsvp == MeetingResponse.accepted
                            ? AppColors.greenBright
                            : AppColors.meetingRejected,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  AppSpacing.verticalBase,
                  _InfoCard(
                    children: [
                      _InfoRow(
                        iconAsset: AppAssets.icMeetingDatetime,
                        label: 'Date & Time',
                        value: _dateTimeLabel,
                      ),
                      AppSpacing.verticalBase,
                      _InfoRow(
                        iconAsset: AppAssets.icMeetingLink,
                        label: meeting.platform.label,
                        value: meeting.link,
                        trailing: _SquareIconButton(
                          icon: Icons.copy_outlined,
                          color: AppColors.textPrimary,
                          onTap: () => _onCopyLink(context),
                        ),
                      ),
                      if (meeting.project.isNotEmpty) ...[
                        AppSpacing.verticalBase,
                        _InfoRow(
                          iconAsset: AppAssets.icRelatedShoot,
                          label: 'Related Shoot',
                          value: meeting.project,
                          valueColor: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                  if (agendaText.isNotEmpty) ...[
                    AppSpacing.verticalXl,
                    Text(
                      'Agenda',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.verticalSm,
                    _AgendaCard(text: agendaText),
                  ],
                  AppSpacing.verticalXl,
                  Text(
                    'Participants (${meeting.participants.length})',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.verticalSm,
                  for (final p in meeting.participants) ...[
                    MeetingParticipantTile(participant: p),
                    AppSpacing.verticalSm,
                  ],
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
              Text(
                'Meeting Details',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final MeetingStatus status;

  Color get _bg {
    switch (status) {
      case MeetingStatus.pending:
      case MeetingStatus.upcoming:
      case MeetingStatus.scheduled:
        return AppColors.meetingPendingBg;
      case MeetingStatus.initiated:
        return AppColors.meetingOngoingBg;
      case MeetingStatus.completed:
        return AppColors.meetingCompletedBg;
      case MeetingStatus.rescheduled:
      case MeetingStatus.revision:
        return AppColors.meetingRescheduledBg;
      case MeetingStatus.cancelled:
        return AppColors.meetingCancelledBg;
    }
  }

  Color get _fg {
    switch (status) {
      case MeetingStatus.pending:
      case MeetingStatus.upcoming:
      case MeetingStatus.scheduled:
        return AppColors.meetingPendingFg;
      case MeetingStatus.initiated:
        return AppColors.meetingOngoingFg;
      case MeetingStatus.completed:
        return AppColors.meetingCompletedFg;
      case MeetingStatus.rescheduled:
      case MeetingStatus.revision:
        return AppColors.meetingRescheduledFg;
      case MeetingStatus.cancelled:
        return AppColors.meetingCancelledFg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(color: _bg, borderRadius: AppRadii.fullAll),
      child: Text(
        status.label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: _fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.icon,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.mdAll,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.mdAll,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.xlAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.iconAsset,
    required this.label,
    required this.value,
    this.trailing,
    this.valueColor,
  });

  final String iconAsset;
  final String label;
  final String value;
  final Widget? trailing;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SvgPicture.asset(
            iconAsset,
            width: 18,
            height: 18,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: valueColor ?? AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}

class _AgendaCard extends StatelessWidget {
  const _AgendaCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.xlAll,
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
