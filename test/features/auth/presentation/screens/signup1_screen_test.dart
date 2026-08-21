import 'package:beige_creative_app/app/spacing.dart';
import 'package:beige_creative_app/core/providers/auth_state_provider.dart';
import 'package:beige_creative_app/features/auth/presentation/providers/signup_notifier.dart';
import 'package:beige_creative_app/features/auth/presentation/providers/signup_state.dart';
import 'package:beige_creative_app/features/auth/presentation/screens/signup1_screen.dart';
import 'package:beige_creative_app/features/auth/presentation/widgets/signup1_preview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../helpers/pump_app.dart';

class _PrefilledSignupNotifier extends SignupNotifier {
  @override
  SignupState build() => const SignupState(
    firstName: 'Harsh',
    lastName: 'Patel',
    currentLatLng: LatLng(23.0225, 72.5714),
  );

  @override
  void reset() {}

  @override
  Future<bool> loadStep1Prefill() async => true;
}

Future<void> _loadAppFonts() async {
  final unbounded = FontLoader('Unbounded')
    ..addFont(rootBundle.load('assets/fonts/Unbounded-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Unbounded-Medium.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Unbounded-SemiBold.ttf'));
  final outfit = FontLoader('Outfit')
    ..addFont(rootBundle.load('assets/fonts/Outfit-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Outfit-Medium.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Outfit-SemiBold.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Outfit-Bold.ttf'));
  await Future.wait([unbounded.load(), outfit.load()]);
}

void main() {
  setUpAll(_loadAppFonts);

  for (final width in [360.0, 393.0]) {
    testWidgets(
      'preview card clears First Name field at ${width.toInt()}px width',
      (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpProviderApp(
          const SignUp1Screen(),
          overrides: [
            signupNotifierProvider.overrideWith(_PrefilledSignupNotifier.new),
            authStateProvider.overrideWith(
              () => AuthStateNotifier(initial: false),
            ),
          ],
        );
        await tester.pumpAndSettle();

        final preview = find.byType(SignUp1PreviewCard);
        final firstNameField = find.byType(TextFormField).first;
        expect(preview, findsOneWidget);
        expect(firstNameField, findsOneWidget);

        final previewBottom = tester.getBottomLeft(preview).dy;
        final fieldTop = tester.getTopLeft(firstNameField).dy;
        expect(fieldTop - previewBottom, greaterThanOrEqualTo(AppSpacing.base));
      },
    );
  }
}
