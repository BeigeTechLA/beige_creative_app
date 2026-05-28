import 'package:beige_creative_app/shared/widgets/app_button.dart';
import 'package:beige_creative_app/shared/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppEmptyState renders title, description, CTA', (tester) async {
    var ctaTaps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppEmptyState(
            icon: Icons.inbox,
            title: 'Nothing here',
            description: 'No upcoming shoots yet',
            ctaLabel: 'Browse',
            onCta: () => ctaTaps++,
          ),
        ),
      ),
    );

    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('No upcoming shoots yet'), findsOneWidget);
    expect(find.text('Browse'), findsOneWidget);

    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(ctaTaps, 1);
  });

  testWidgets('AppEmptyState without CTA omits AppButton', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppEmptyState(
            icon: Icons.inbox,
            title: 'Nothing here',
          ),
        ),
      ),
    );

    expect(find.byType(AppButton), findsNothing);
  });
}
