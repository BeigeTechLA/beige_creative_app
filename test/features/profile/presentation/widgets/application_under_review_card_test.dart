import 'package:beige_creative_app/features/profile/presentation/widgets/application_under_review_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders ApplicationUnderReviewCard with texts and buttons', (
    tester,
  ) async {
    bool refreshed = false;
    bool completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ApplicationUnderReviewCard(
              profileImageUrl: null,
              onRefreshStatus: () => refreshed = true,
              onCompleteProfile: () => completed = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Application Under Review'), findsOneWidget);
    expect(find.text('NEXT STEPS'), findsOneWidget);
    expect(find.text('Refresh Status'), findsOneWidget);
    expect(find.text('Complete Your Profile'), findsOneWidget);

    await tester.tap(find.text('Refresh Status'));
    await tester.pump();
    expect(refreshed, isTrue);

    await tester.tap(find.text('Complete Your Profile'));
    await tester.pump();
    expect(completed, isTrue);
  });

  testWidgets(
    'hides Complete Your Profile button when showCompleteProfileButton is false',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ApplicationUnderReviewCard(
                showCompleteProfileButton: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Application Under Review'), findsOneWidget);
      expect(find.text('Complete Your Profile'), findsNothing);
    },
  );

  testWidgets('non-dismissible dialog stays open on barrier and back', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => ApplicationUnderReviewDialog.show<void>(
                context,
                barrierDismissible: false,
                closeOnRefresh: false,
              ),
              child: const Text('Show review'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show review'));
    await tester.pumpAndSettle();
    expect(find.text('Application Under Review'), findsOneWidget);

    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(find.text('Application Under Review'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Application Under Review'), findsOneWidget);
  });

  testWidgets('refresh can keep non-dismissible dialog open', (tester) async {
    var refreshCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => ApplicationUnderReviewDialog.show<void>(
                context,
                barrierDismissible: false,
                closeOnRefresh: false,
                onRefreshStatus: () => refreshCalls++,
              ),
              child: const Text('Show review'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Refresh Status'));
    await tester.pumpAndSettle();

    expect(refreshCalls, 1);
    expect(find.text('Application Under Review'), findsOneWidget);
  });
}
