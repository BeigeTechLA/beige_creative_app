import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../app/assets.dart';
import '../../../../../app/colors.dart';
import '../../../../../app/radii.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';
import '../../../../../shared/widgets/top_message.dart';
import '../../domain/models/affiliate_summary.dart';
import '../providers/affiliate_notifier.dart';

/// Highlighted card showing the affiliate code and link with copy buttons.
///
/// Rendered as a "ticket" — a rounded card with semicircle notches cut into
/// the left/right edges at the divider between the code row and the note
/// row, plus a dashed separator line running through the notches.
class AffiliateCodeSection extends ConsumerStatefulWidget {
  const AffiliateCodeSection({super.key, this.summary});

  final AffiliateSummary? summary;

  static const double _notchRadius = 10;
  static const double _codeSectionHeight = 64;

  @override
  ConsumerState<AffiliateCodeSection> createState() =>
      _AffiliateCodeSectionState();
}

class _AffiliateCodeSectionState extends ConsumerState<AffiliateCodeSection> {
  bool _isEditing = false;
  bool _isSaving = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.summary?.affiliateCode ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant AffiliateCodeSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing &&
        widget.summary?.affiliateCode != oldWidget.summary?.affiliateCode) {
      _controller.text = widget.summary?.affiliateCode ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveCode() async {
    final newCode = _controller.text.trim().toUpperCase();
    if (newCode.length < 5 || newCode.length > 20) {
      TopMessage.show(
        context,
        'Code must be between 5 and 20 characters',
        type: TopMessageType.error,
      );
      return;
    }
    final currentCode = widget.summary?.affiliateCode ?? '';
    if (newCode == currentCode) {
      setState(() => _isEditing = false);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final success = await ref
          .read(affiliateNotifierProvider.notifier)
          .updateCode(newCode);
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isEditing = false;
        });
        if (success) {
          TopMessage.show(
            context,
            'Affiliate code updated successfully!',
            type: TopMessageType.success,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        TopMessage.show(
          context,
          e.toString().replaceAll('Exception: ', ''),
          type: TopMessageType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.summary?.affiliateCode ?? '';
    return ClipPath(
      clipper: _TicketClipper(
        notchRadius: AffiliateCodeSection._notchRadius,
        notchCenterY: AffiliateCodeSection._codeSectionHeight,
        cornerRadius: AppRadii.lg,
      ),
      child: Container(
        height: 134,
        color: AppColors.primary,
        child: Column(
          children: [
            // ── Code row ────────────────────────────────────────────────
            Container(
              height: AffiliateCodeSection._codeSectionHeight,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _isEditing
                        ? Row(
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth: 80,
                                  maxWidth: 180,
                                ),
                                child: IntrinsicWidth(
                                  child: TextField(
                                    controller: _controller,
                                    autofocus: true,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.black,
                                      fontSize: 22,
                                      fontFamily: AppAssets.fontOutfit,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 4,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.black,
                                    ),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (_isSaving)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.black,
                                  ),
                                )
                              else ...[
                                GestureDetector(
                                  onTap: _saveCode,
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: AppColors.affiliateCompletedForeground,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isEditing = false;
                                      _controller.text = code;
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: AppColors.affiliateCancelRed,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ],
                          )
                        : Row(
                            children: [
                              Flexible(
                                child: Text(
                                  code,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.black,
                                    fontSize: 22,
                                    fontFamily: AppAssets.fontOutfit,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ),
                              AppSpacing.gapHXs,
                              GestureDetector(
                                onTap: () {
                                  _controller.text = code;
                                  setState(() => _isEditing = true);
                                },
                                child: SvgPicture.asset(
                                  AppAssets.affiliateEditPen,
                                  width: 15,
                                  height: 15,
                                ),
                              ),
                            ],
                          ),
                  ),
                  if (!_isEditing)
                    Semantics(
                      label: 'Copy affiliate code',
                      button: true,
                      child: GestureDetector(
                        onTap: () => _copy(
                          context,
                          code,
                          'Code copied!',
                        ),
                        child: Container(
                          width: 60,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            color: AppColors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.smAll,
                            ),
                          ),
                          child: Text(
                            'Copy',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontFamily: AppAssets.fontOutfit,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Dashed divider (runs through the notches) ─────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AffiliateCodeSection._notchRadius,
              ),
              child: const SizedBox(
                height: 1,
                child: _DashedLine(color: AppColors.black40),
              ),
            ),

            // ── Note row ────────────────────────────────────────────────
            Container(
              width: 283,
              height: 32,
              margin: const EdgeInsets.only(top: 12),
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: AppColors.affiliateNoteBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.smAll,
                ),
              ),
              child: Text(
                'Note : Min 5, Max 20 Characters',
                textAlign: TextAlign.center,
                style: AppTextStyles.body12.copyWith(
                  color: AppColors.black,
                  fontSize: 12,
                  fontFamily: AppAssets.fontOutfit,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copy(
    BuildContext context,
    String text,
    String message,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    TopMessage.show(context, message, type: TopMessageType.success);
  }
}

class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper({
    required this.notchRadius,
    required this.notchCenterY,
    required this.cornerRadius,
  });

  final double notchRadius;
  final double notchCenterY;
  final double cornerRadius;

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final r = cornerRadius;

    path.moveTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.lineTo(w - r, 0);
    path.quadraticBezierTo(w, 0, w, r);

    path.lineTo(w, notchCenterY - notchRadius);
    path.arcToPoint(
      Offset(w, notchCenterY + notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );
    path.lineTo(w, h - r);
    path.quadraticBezierTo(w, h, w - r, h);

    path.lineTo(r, h);
    path.quadraticBezierTo(0, h, 0, h - r);

    path.lineTo(0, notchCenterY + notchRadius);
    path.arcToPoint(
      Offset(0, notchCenterY - notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant _TicketClipper oldClipper) {
    return oldClipper.notchRadius != notchRadius ||
        oldClipper.notchCenterY != notchCenterY ||
        oldClipper.cornerRadius != cornerRadius;
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DashedLinePainter(color: color),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;
  static const double _dashWidth = 4;
  static const double _dashGap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    var startX = 0.0;
    final dashCount = (size.width / (_dashWidth + _dashGap)).ceil();
    for (var i = 0; i < dashCount; i++) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(math.min(startX + _dashWidth, size.width), 0),
        paint,
      );
      startX += _dashWidth + _dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}