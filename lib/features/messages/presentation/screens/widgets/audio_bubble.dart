import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../app/colors.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';
import '../../../../../shared/widgets/app_avatar.dart';
import '../../../domain/entities/message.dart';

/// Voice-note bubble. Playback wiring lands later — this is presentation
/// only: play/pause button toggles a local bool, waveform is static.
class AudioBubble extends StatefulWidget {
  const AudioBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.showSenderHeader,
  });

  final Message message;
  final bool isMine;
  final bool showSenderHeader;

  @override
  State<AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<AudioBubble> {
  bool _playing = false;

  String _format(Duration d) {
    final mm = d.inMinutes.toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.message.file;
    final duration = Duration(milliseconds: file?.durationMs ?? 0);
    final bg = widget.isMine ? AppColors.primary : AppColors.surfaceCharcoal;
    final fg = widget.isMine ? AppColors.textDark : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: widget.isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!widget.isMine) ...[
            AppAvatar(name: widget.message.senderName, size: AppAvatarSize.xs),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: widget.isMine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (widget.showSenderHeader && !widget.isMine)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                    child: Text(
                      widget.message.senderName,
                      style: AppTextStyles.bodySmallMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.smd,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(widget.isMine ? 20 : 4),
                      bottomRight: Radius.circular(widget.isMine ? 4 : 20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        button: true,
                        label: _playing
                            ? 'Pause voice note'
                            : 'Play voice note',
                        child: InkResponse(
                          onTap: () => setState(() => _playing = !_playing),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: fg.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _playing ? Icons.pause : Icons.play_arrow,
                              color: fg,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        width: 120,
                        height: 24,
                        child: CustomPaint(
                          painter: _WaveformPainter(color: fg),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _format(duration),
                        style: AppTextStyles.body11.copyWith(color: fg),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({required this.color});

  final Color color;
  static const int _barCount = 28;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final spacing = size.width / _barCount;
    for (var i = 0; i < _barCount; i++) {
      final x = spacing * i + spacing / 2;
      final amp = (rng.nextDouble() * 0.7) + 0.15;
      final h = size.height * amp;
      final y0 = (size.height - h) / 2;
      canvas.drawLine(Offset(x, y0), Offset(x, y0 + h), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.color != color;
}
