import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/colors.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_participant.dart';
import '../../domain/models/meeting_platform.dart';
import '../../domain/models/meeting_status.dart';

/// Single meeting summary card — title, platform chip, date/time meta,
/// timezone, and a full-width Join CTA. Tap anywhere outside the CTA opens
/// the meeting-details bottom sheet (wired by parent).
class MeetingCard extends StatefulWidget {
  const MeetingCard({
    super.key,
    required this.meeting,
    required this.onTap,
    required this.onJoin,
  });

  final Meeting meeting;
  final VoidCallback onTap;
  final VoidCallback onJoin;

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

  Color _getStatusBgColor(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.initiated:
        return const Color(0xFFFEF5E5);
      case MeetingStatus.completed:
        return const Color(0xFFD8FDE6);
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
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _dateLabel,
                    style: AppTextStyles.body14.copyWith(
                      color: AppColors.textSecondary,
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
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _timeLabel,
                    style: AppTextStyles.body14.copyWith(
                      color: AppColors.textSecondary,
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

              // 6. Action buttons
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: widget.onJoin,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        height: 48,
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
                      width: 48,
                      height: 48,
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
