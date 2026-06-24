import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/colors.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_participant.dart';
import '../../domain/models/meeting_platform.dart';
import '../../domain/models/meeting_response.dart';
import '../../domain/models/meeting_status.dart';
import '../../domain/util/can_rsvp.dart';

/// Single meeting summary card — title, platform chip, date/time meta,
/// timezone, and a full-width Join CTA. Tap anywhere outside the CTA opens
/// the meeting-details bottom sheet (wired by parent).
///
/// Accept / Reject row renders above the Join CTA when [onAccept] and
/// [onReject] are both provided and the meeting is not yet completed.
class MeetingCard extends StatefulWidget {
  const MeetingCard({
    super.key,
    required this.meeting,
    required this.onTap,
    required this.onJoin,
    this.onAccept,
    this.onReject,
    this.rsvpPending = false,
  });

  final Meeting meeting;
  final VoidCallback onTap;
  final VoidCallback onJoin;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  /// True while an Accept/Reject network call for this meeting is in flight.
  /// Disables both RSVP buttons and renders a spinner on each.
  final bool rsvpPending;

  @override
  State<MeetingCard> createState() => _MeetingCardState();
}

class _MeetingCardState extends State<MeetingCard> {
  bool _syncMeeting = true;

  static final _date = DateFormat('dd MMM,yyyy');
  static final _time = DateFormat('hh:mm a');

  String get _dateLabel => _date.format(widget.meeting.startAt);
  String get _timeLabel =>
      '${_time.format(widget.meeting.startAt)} to ${_time.format(widget.meeting.endAt)}';

  bool get _showRsvp =>
      widget.onAccept != null &&
      widget.onReject != null &&
      canRsvpToMeeting(widget.meeting);

  Color _getStatusBgColor(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.initiated:
        return const Color(0xFFFEF5E5);
      case MeetingStatus.completed:
        return AppColors.softMint;
      case MeetingStatus.reviewer:
        return const Color(0xFFFFEAE0);
      case MeetingStatus.upcoming:
        return const Color(0xFFE0E7F8);
    }
  }

  Color _getStatusTextColor(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.initiated:
        return const Color(0xFF8A5C1F);
      case MeetingStatus.completed:
        return const Color(0xFF2F855A);
      case MeetingStatus.reviewer:
        return const Color(0xFFFF9D25);
      case MeetingStatus.upcoming:
        return const Color(0xFF2D66D2);
    }
  }

  Widget _buildOverlappingAvatars(List<MeetingParticipant> participants) {
    if (participants.isEmpty) return const SizedBox.shrink();
    const double avatarSize = 24.0;
    const double overlap = 8.0;
    final displayCount =
        participants.length > 4 ? participants.sublist(0, 4) : participants;
    final stackWidth = displayCount.isEmpty
        ? 0.0
        : displayCount.length * (avatarSize - overlap) + overlap;

    return SizedBox(
      width: stackWidth,
      height: avatarSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(displayCount.length, (index) {
          final p = displayCount[index];
          return Positioned(
            left: index * (avatarSize - overlap),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 1.5),
              ),
              child: AppAvatar(
                imageUrl: p.avatarUrl,
                name: p.name,
                size: AppAvatarSize.xs,
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Meeting ${widget.meeting.title} on $_dateLabel',
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(24.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(color: AppColors.dividerDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Title Row with Camera Icon
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.videocam_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.meeting.title,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.primary,
                        fontFamily: 'Outfit',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Status & Platform badges
              Row(
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(widget.meeting.status),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.meeting.status.label,
                      style: AppTextStyles.body11.copyWith(
                        color: _getStatusTextColor(widget.meeting.status),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Platform Badge
                  _PlatformBadge(platform: widget.meeting.platform),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.dividerDark, height: 1, thickness: 1),
              const SizedBox(height: 12),

              // 3. Calendar & Time rows
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _dateLabel,
                    style: AppTextStyles.body14.copyWith(
                      color: AppColors.white,
                      fontSize: 12,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_outlined,
                    size: 16,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _timeLabel,
                    style: AppTextStyles.body14.copyWith(
                      color: AppColors.white,
                      fontSize: 12,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.dividerDark, height: 1, thickness: 1),
              const SizedBox(height: 12),

              // 4. Participants Section
              Row(
                children: [
                  _buildOverlappingAvatars(widget.meeting.participants),
                  if (widget.meeting.participants.length > 4) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${widget.meeting.participants.length - 4} Participants',
                        style: AppTextStyles.body11.copyWith(
                          color: AppColors.textSecondary,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.dividerDark, height: 1, thickness: 1),
              const SizedBox(height: 12),

              // 5. Sync Meeting toggle
              Row(
                children: [
                  Text(
                    'Sync Meeting',
                    style: AppTextStyles.body14.copyWith(
                      color: AppColors.textPrimary,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _syncMeeting,
                    onChanged: (val) {
                      setState(() {
                        _syncMeeting = val;
                      });
                    },
                    activeTrackColor: AppColors.primary,
                    activeThumbColor: Colors.white,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: AppColors.white.withValues(alpha: 0.08),
                    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 6a. CP RSVP — status line + Accept / Reject buttons.
              // Once the CP has responded, hide the matching action button
              // (Accept once accepted, Reject once declined) and show a
              // "Your Response: ..." label so they can flip the answer with
              // the remaining button.
              if (_showRsvp) ...[
                if (widget.meeting.myResponse != null) ...[
                  _ResponseStatusLine(response: widget.meeting.myResponse!),
                  const SizedBox(height: 12),
                ],
                Builder(
                  builder: (_) {
                    final showAccept =
                        widget.meeting.myResponse != MeetingResponse.accepted;
                    final showReject =
                        widget.meeting.myResponse != MeetingResponse.declined;
                    final accept = _RsvpButton(
                      label: 'Accept',
                      backgroundColor: const Color(0xFFD8FDE6),
                      textColor: const Color(0xFF1DAA23),
                      onTap: widget.onAccept!,
                      loading: widget.rsvpPending,
                    );
                    final reject = _RsvpButton(
                      label: 'Reject',
                      backgroundColor: const Color(0xFFEECCC9),
                      textColor: const Color(0xFFD33732),
                      onTap: widget.onReject!,
                      loading: widget.rsvpPending,
                    );
                    // Single visible button always sits in the left half so
                    // it never drifts to the right column.
                    final Widget left = showAccept ? accept : reject;
                    final bool showBoth = showAccept && showReject;
                    return Row(
                      children: [
                        Expanded(child: left),
                        const SizedBox(width: 12),
                        Expanded(
                          child: showBoth ? reject : const SizedBox.shrink(),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],

              // 6b. Action buttons
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: widget.onJoin,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Join Meeting',
                              style: AppTextStyles.buttonMedium.copyWith(
                                color: AppColors.onPrimary,
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.open_in_new,
                              size: 16,
                              color: AppColors.onPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.north_east,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RsvpButton extends StatelessWidget {
  const _RsvpButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      enabled: !loading,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 28,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: loading
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              : Text(
                  label,
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: textColor,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ResponseStatusLine extends StatelessWidget {
  const _ResponseStatusLine({required this.response});

  final MeetingResponse response;

  @override
  Widget build(BuildContext context) {
    final isAccepted = response == MeetingResponse.accepted;
    final color = isAccepted
        ? const Color(0xFF1DAA23)
        : const Color(0xFFD33732);
    final label = isAccepted ? 'Accepted' : 'Rejected';
    return Row(
      children: [
        Icon(
          isAccepted ? Icons.check_circle_outline : Icons.cancel_outlined,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          'Your Response: ',
          style: AppTextStyles.body14.copyWith(
            color: AppColors.textSecondary,
            fontFamily: 'Outfit',
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.body14.copyWith(
            color: color,
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _PlatformBadge extends StatelessWidget {
  const _PlatformBadge({required this.platform});

  final MeetingPlatform platform;

  @override
  Widget build(BuildContext context) {
    Widget icon;
    switch (platform) {
      case MeetingPlatform.meet:
        icon = const _GoogleMeetLogo(size: 14);
        break;
      case MeetingPlatform.zoom:
        icon = const Icon(Icons.videocam, size: 14, color: Color(0xFF2D8CFF));
        break;
      case MeetingPlatform.teams:
        icon = const Icon(Icons.groups, size: 14, color: Color(0xFF4F46E5));
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          Text(
            platform.label,
            style: AppTextStyles.body11.copyWith(
              color: const Color(0xFF1D1D1B),
              fontWeight: FontWeight.w600,
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleMeetLogo extends StatelessWidget {
  const _GoogleMeetLogo({this.size = 14.0});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleMeetLogoPainter(),
      ),
    );
  }
}

class _GoogleMeetLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;

    // Body area is left 75% of size, lens is right 25%

    // 1. Blue (bottom-left)
    paint.color = const Color(0xFF1A73E8);
    final pathBlue = Path()
      ..moveTo(0, h * 0.5)
      ..lineTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.5, h)
      ..lineTo(w * 0.2, h)
      ..quadraticBezierTo(0, h, 0, h * 0.8)
      ..close();
    canvas.drawPath(pathBlue, paint);

    // 2. Green (top-left)
    paint.color = const Color(0xFF00A859);
    final pathGreen = Path()
      ..moveTo(0, h * 0.5)
      ..lineTo(0, h * 0.2)
      ..quadraticBezierTo(0, 0, w * 0.2, 0)
      ..lineTo(w * 0.5, 0)
      ..lineTo(w * 0.5, h * 0.5)
      ..close();
    canvas.drawPath(pathGreen, paint);

    // 3. Yellow (top-right corner of body)
    paint.color = const Color(0xFFFFBA00);
    final pathYellow = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w * 0.7, 0)
      ..quadraticBezierTo(w * 0.75, 0, w * 0.75, h * 0.15)
      ..lineTo(w * 0.75, h * 0.5)
      ..lineTo(w * 0.5, h * 0.5)
      ..close();
    canvas.drawPath(pathYellow, paint);

    // 4. Red (lens and bottom-right of body)
    paint.color = const Color(0xFFEA4335);
    final pathRedBody = Path()
      ..moveTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.75, h * 0.5)
      ..lineTo(w * 0.75, h * 0.85)
      ..quadraticBezierTo(w * 0.75, h, w * 0.65, h)
      ..lineTo(w * 0.5, h)
      ..close();
    canvas.drawPath(pathRedBody, paint);

    // Lens
    final pathLens = Path()
      ..moveTo(w * 0.75, h * 0.3)
      ..lineTo(w, h * 0.15)
      ..lineTo(w, h * 0.85)
      ..lineTo(w * 0.75, h * 0.7)
      ..close();
    canvas.drawPath(pathLens, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
