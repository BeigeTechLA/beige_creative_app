import 'package:beige_creative_app/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

void main() {
  testWidgets('AppButton renders label and fires onPressed', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppButton(
              label: 'Tap me',
              onPressed: () => tapped++,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Tap me'), findsOneWidget);
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(tapped, 1);
  });

  testWidgets('AppButton with isLoading suppresses onPressed', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppButton(
              label: 'Tap me',
              isLoading: true,
              onPressed: () => tapped++,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(tapped, 0, reason: 'loading state must block taps');
    expect(find.byType(LottieBuilder), findsOneWidget);
  });
}
