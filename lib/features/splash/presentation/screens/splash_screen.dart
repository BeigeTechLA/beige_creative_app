import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/routes.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/onboarding_seen_provider.dart';
import '../../../../core/restoration/restoration_keys.dart';
import '../../../../core/restoration/restoration_providers.dart';
import '../providers/splash_notifier.dart';
import '../providers/splash_state.dart';

/// Presentation-only splash. Animation drives the boot delay; on completion
/// the screen reads `authStateProvider` and navigates accordingly. Router
/// `redirect:` (Task 3.17) is the second line of defence — if auth state
/// flips between mount and animation-complete, the redirect catches it.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _routeOnComplete() {
    if (!mounted) return;
    final isAuthed = ref.read(authStateProvider);

    if (isAuthed) {
      // Phase B — try to restore a persisted route first. Decision helper
      // gates on `kRestorationEnabled`, login state, and a forbid list.
      final restoration = ref.read(routeRestorationServiceProvider);
      final restorer = ref.read(splashRestorerProvider);
      final restored = restoration.readRestorable();
      if (restorer.shouldRestore(
        isEnabled: kRestorationEnabled,
        isLoggedIn: true,
        persistedRoute: restored?.location,
      )) {
        context.go(restored!.toUri());
        return;
      }
      context.goNamed(Routes.home.name);
      return;
    }
    final seen = ref.read(onboardingSeenProvider);
    context.goNamed(seen ? Routes.login.name : Routes.onboarding.name);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SplashState>(splashNotifierProvider, (previous, next) {
      if (next.animationDone && previous?.animationDone != true) {
        _routeOnComplete();
      }
    });

    return Scaffold(
      body: Container(
        color: AppColors.textHeading,
        child: Center(
          child: Lottie.asset(
            AppAssets.lottie2,
            controller: _controller,
            width: 250,
            fit: BoxFit.contain,
            onLoaded: (composition) {
              _controller
                ..duration = composition.duration
                ..forward().whenComplete(() {
                  ref
                      .read(splashNotifierProvider.notifier)
                      .markAnimationComplete();
                });
            },
          ),
        ),
      ),
    );
  }
}
