import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/spacing.dart';
import '../../domain/models/meeting_platform.dart';

/// Radio-style platform picker — zoom / meet / teams.
/// Renders as three fixed-size square buttons with mockup-matched brand icons.
class SelectMeetLinkPicker extends StatelessWidget {
  const SelectMeetLinkPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final MeetingPlatform selected;
  final ValueChanged<MeetingPlatform> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final p in MeetingPlatform.values) ...[
          _Option(
            platform: p,
            isActive: p == selected,
            onTap: () => onChanged(p),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.platform,
    required this.isActive,
    required this.onTap,
  });

  final MeetingPlatform platform;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget logo;
    switch (platform) {
      case MeetingPlatform.meet:
        logo = const _GoogleMeetLogo(size: 20);
        break;
      case MeetingPlatform.zoom:
        logo = const _ZoomLogo();
        break;
      case MeetingPlatform.teams:
        logo = const _TeamsLogo(size: 20);
        break;
    }

    return Semantics(
      button: true,
      selected: isActive,
      label: platform.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.surfaceInput,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.dividerDark,
              width: isActive ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: logo,
        ),
      ),
    );
  }
}

class _GoogleMeetLogo extends StatelessWidget {
  const _GoogleMeetLogo({this.size = 20.0});
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

class _ZoomLogo extends StatelessWidget {
  const _ZoomLogo();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'zoom',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 14,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.8,
        fontFamily: 'Outfit',
      ),
    );
  }
}

class _TeamsLogo extends StatelessWidget {
  const _TeamsLogo({this.size = 20.0});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TeamsLogoPainter(),
      ),
    );
  }
}

class _TeamsLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.45;

    // Center circle
    canvas.drawCircle(center, radius * 0.35, paint);

    // 8 rays around the circle (Capsule-like shapes)
    const numRays = 8;
    for (int i = 0; i < numRays; i++) {
      final angle = (i * 2 * 3.14159) / numRays;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final rect = Rect.fromLTWH(-2, -radius, 4, radius * 0.5);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
      canvas.drawRRect(rrect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
