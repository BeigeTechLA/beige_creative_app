import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../app/assets.dart';
import '../../../../../app/colors.dart';

/// "How It Works" explainer section — 3 numbered steps with icons.
class AffiliateHowItWorks extends StatelessWidget {
  const AffiliateHowItWorks({super.key});

  static const _steps = [
    _Step(
      svgPath: AppAssets.affiliateShare,
      title: '1. Share Code',
      description: 'Send your unique code to potential clients.',
    ),
    _Step(
      svgPath: AppAssets.affiliateCalendar,
      title: '2. They Book',
      description: 'They use the code at checkout for a shoot.',
    ),
    _Step(
      svgPath: AppAssets.affiliateMoney,
      title: '3. You Earn',
      description: 'Get 10% for every completed booking.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _steps.mapIndexed((index, step) {
        final isLast = index == _steps.length - 1;
        return _StepRow(step: step, isLast: isLast);
      }).toList(growable: false),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.isLast,
  });

  final _Step step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step indicator column with 60x60 circle and connecting dashed line
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: const ShapeDecoration(
                    color: AppColors.surfaceMid,
                    shape: OvalBorder(),
                  ),
                  child: SvgPicture.asset(
                    step.svgPath,
                    width: 24,
                    height: 24,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: SizedBox(
                      width: 2,
                      child: CustomPaint(
                        painter: _DashedVerticalLinePainter(
                          color: AppColors.affiliateDashedLine,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : 28.0,
                top: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                      fontFamily: AppAssets.fontOutfit,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.description,
                    style: const TextStyle(
                      color: AppColors.neutralGrey,
                      fontSize: 10,
                      fontFamily: AppAssets.fontOutfit,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedVerticalLinePainter extends CustomPainter {
  _DashedVerticalLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    var startY = 4.0;
    const dashHeight = 4.0;
    const dashGap = 4.0;

    while (startY < size.height - 2.0) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, math.min(startY + dashHeight, size.height)),
        paint,
      );
      startY += dashHeight + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedVerticalLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _Step {
  const _Step({
    required this.svgPath,
    required this.title,
    required this.description,
  });

  final String svgPath;
  final String title;
  final String description;
}

// Minimal indexed map extension used only within this file.
extension _ListIndexedMap<T> on List<T> {
  Iterable<R> mapIndexed<R>(R Function(int index, T item) fn) sync* {
    for (var i = 0; i < length; i++) {
      yield fn(i, this[i]);
    }
  }
}
