import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
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
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.verticalBase,
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(meetingDetailsProvider(meetingId)),
                        child: const Text('Retry'),
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

  static final _dateFmt = DateFormat('MMM d');
  static final _timeFmt = DateFormat('hh:mm a');

  String get _dateTimeLabel =>
      '${_dateFmt.format(meeting.startAt)}, ${_timeFmt.format(meeting.startAt)} - ${_timeFmt.format(meeting.endAt)}';

  void _onJoin(BuildContext context) {
    launchMeetingLink(context, meeting.link);
  }

  Future<void> _onCopyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: meeting.link));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  if (meeting.myResponse != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      meeting.myResponse == MeetingResponse.accepted
                          ? '(Accepted)'
                          : '(Rejected)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: meeting.myResponse == MeetingResponse.accepted
                            ? AppColors.greenBright
                            : const Color(0xFFD33732),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  AppSpacing.verticalBase,
                  _InfoCard(
                    children: [
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date & Time',
                        value: _dateTimeLabel,
                      ),
                      AppSpacing.verticalBase,
                      _InfoRow(
                        icon: Icons.videocam_outlined,
                        label: meeting.platform.label.toLowerCase(),
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
                          icon: Icons.work_outline,
                          label: 'Related Shoot',
                          value: meeting.project,
                        ),
                      ],
                    ],
                  ),
                  if (meeting.description.isNotEmpty ||
                      meeting.agenda.isNotEmpty) ...[
                    AppSpacing.verticalXl,
                    Text(
                      'Agenda',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.verticalSm,
                    _AgendaCard(
                      text: meeting.description.isNotEmpty
                          ? meeting.description
                          : meeting.agenda.join('\n'),
                    ),
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
            child: _JoinButton(onTap: () => _onJoin(context)),
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
      case MeetingStatus.initiated:
        return AppColors.lightGoldenBg;
      case MeetingStatus.completed:
        return AppColors.softMint;
      case MeetingStatus.reviewer:
        return const Color(0xFFFFEAE0);
      case MeetingStatus.upcoming:
        return AppColors.blueIce;
    }
  }

  Color get _fg {
    switch (status) {
      case MeetingStatus.initiated:
        return const Color(0xFF8A5C1F);
      case MeetingStatus.completed:
        return AppColors.greenForest;
      case MeetingStatus.reviewer:
        return AppColors.orangeBright;
      case MeetingStatus.upcoming:
        return AppColors.blueRoyal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: AppRadii.fullAll,
      ),
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
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
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
                  color: AppColors.textSecondary,
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

class _JoinButton extends StatelessWidget {
  const _JoinButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Join Meeting',
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.fullAll,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppRadii.fullAll,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Join Meeting',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.onPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.open_in_new,
                size: 18,
                color: AppColors.onPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}