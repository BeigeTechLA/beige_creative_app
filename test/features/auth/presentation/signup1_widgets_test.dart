import 'package:beige_creative_app/features/auth/presentation/widgets/signup1_header.dart';
import 'package:beige_creative_app/features/auth/presentation/widgets/signup1_preview_card.dart';
import 'package:beige_creative_app/features/auth/presentation/widgets/signup1_profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SignUp1Header', () {
    testWidgets('renders title, subtitle, and step counter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SignUp1Header())),
      );
      expect(find.text('Build your Creative Profile'), findsOneWidget);
      expect(find.text('1/3'), findsOneWidget);
      expect(
        find.textContaining('Create your profile to get discovered'),
        findsOneWidget,
      );
    });
  });

  group('SignUp1ProfileCard', () {
    testWidgets('shows upload CTA and fires onPickImage tap', (tester) async {
      var taps = 0;
      // Swallow CircleAvatar's placeholder asset-load failure in the test
      // bundle — we only care about the labelled CTA + callback wiring.
      await tester.runAsync(() async {
        FlutterError.onError = (_) {};
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SignUp1ProfileCard(
                profileImage: null,
                onPickImage: () => taps++,
              ),
            ),
          ),
        );
      });
      expect(find.text('Profile Picture'), findsOneWidget);
      expect(find.text('Upload Profile Picture'), findsOneWidget);
      await tester.tap(find.text('Upload Profile Picture'));
      expect(taps, 1);
    });
  });

  group('SignUp1PreviewCard', () {
    testWidgets('renders fallback email + completion percent', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SignUp1PreviewCard(
              firstName: 'Ada',
              lastName: 'Lovelace',
              email: '',
              profileImage: null,
              location: 'London',
              workingDistance: 'Upto 50 Miles',
              completionPercent: 27,
            ),
          ),
        ),
      );
      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('Your Email'), findsOneWidget);
      expect(find.text('27% Completed'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);
    });
  });
}
