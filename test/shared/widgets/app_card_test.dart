import 'package:beige_creative_app/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppCard renders child and fires onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppCard(
              onTap: () => taps++,
              child: const Text('Card body'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Card body'), findsOneWidget);
    await tester.tap(find.byType(AppCard));
    await tester.pump();
    expect(taps, 1);
  });
}
