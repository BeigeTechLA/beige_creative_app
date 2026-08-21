import 'package:beige_creative_app/features/splash/presentation/providers/splash_notifier.dart';
import 'package:beige_creative_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('SplashScreen renders Scaffold + Lottie surface', (tester) async {
    await tester.pumpProviderApp(const SplashScreen());
    await tester.pump();

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(LottieBuilder), findsOneWidget);
  });

  test('SplashNotifier flips animationDone exactly once', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(splashNotifierProvider).animationDone, isFalse);

    container.read(splashNotifierProvider.notifier).markAnimationComplete();
    expect(container.read(splashNotifierProvider).animationDone, isTrue);

    container.read(splashNotifierProvider.notifier).markAnimationComplete();
    expect(container.read(splashNotifierProvider).animationDone, isTrue,
        reason: 'second call must be a no-op');
  });
}
