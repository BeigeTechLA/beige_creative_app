import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/loading.dart';

/// Celebratory success screen with a clean checkmark, mock confetti,
/// and a prominent deep-linking action button.
class SuccessScreen extends StatefulWidget {
  final String title;
  final String message;
  final String ctaText;
  final VoidCallback onCtaPressed;

  const SuccessScreen({
    super.key,
    required this.title,
    required this.message,
    required this.ctaText,
    required this.onCtaPressed,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(),
              // Celebratory Icon and Confetti
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Mock Confetti Particles
                    ..._buildConfettiParticles(),

                    // Main Checkmark Circle (Success Lottie animation)
                    const AppSuccessAnimation(
                      height: 160,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Title Headline
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.displaySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Message Body
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
              const Spacer(flex: 2),

              // Primary Action CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onCtaPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    widget.ctaText,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildConfettiParticles() {
    final List<({double x, double y, Color color, double size})> particles = [
      (x: -60, y: -40, color: const Color(0xFF34D399), size: 10.0), // Green
      (x: 70, y: -30, color: const Color(0xFFFBBF24), size: 8.0),  // Yellow
      (x: -50, y: 50, color: const Color(0xFF60A5FA), size: 12.0), // Blue
      (x: 55, y: 45, color: const Color(0xFFA78BFA), size: 9.0),   // Purple
      (x: -20, y: -75, color: const Color(0xFFF472B6), size: 7.0),  // Pink
      (x: 25, y: -80, color: const Color(0xFF34D399), size: 11.0), // Green
    ];

    return particles.map((p) {
      return Transform.translate(
        offset: Offset(p.x, p.y),
        child: Container(
          width: p.size,
          height: p.size,
          decoration: BoxDecoration(
            color: p.color,
            shape: BoxShape.circle,
          ),
        ),
      );
    }).toList();
  }
}
