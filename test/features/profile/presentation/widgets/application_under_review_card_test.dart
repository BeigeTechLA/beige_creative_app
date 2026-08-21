import 'package:beige_creative_app/config/env.dart';
import 'package:beige_creative_app/core/providers/core_providers.dart';
import 'package:beige_creative_app/core/session/session_store.dart';
import 'package:beige_creative_app/features/home/presentation/providers/home_notifier.dart';
import 'package:beige_creative_app/features/home/presentation/providers/home_state.dart';
import 'package:beige_creative_app/features/profile/presentation/widgets/application_under_review_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/mocks.dart';

class _FakeHomeNotifier extends AutoDisposeNotifier<HomeState>
    implements HomeNotifier {
  @override
  HomeState build() => HomeState();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() => Env.init(Environment.dev));

  CompositeSessionStore createSessionStore() {
    return CompositeSessionStore(
      secure: FakeSecureSessionBackend(),
      prefs: FakePrefsSessionBackend(),
    );
  }

  Widget buildTestApp(Widget child) {
    return ProviderScope(
      overrides: [
        homeNotifierProvider.overrideWith(_FakeHomeNotifier.new),
        sessionStoreProvider.overrideWithValue(createSessionStore()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: child),
        ),
      ),
    );
  }

  Widget buildDialogTestApp(void Function(BuildContext) trigger) {
    return ProviderScope(
      overrides: [
        homeNotifierProvider.overrideWith(_FakeHomeNotifier.new),
        sessionStoreProvider.overrideWithValue(createSessionStore()),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => trigger(context),
              child: const Text('Show review'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders ApplicationUnderReviewCard with texts and buttons', (
    tester,
  ) async {
    bool refreshed = false;
    bool completed = false;

    await tester.pumpWidget(
      buildTestApp(
        ApplicationUnderReviewCard(
          profileImageUrl: null,
          onRefreshStatus: () => refreshed = true,
          onCompleteProfile: () => completed = true,
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
    'hides bottom button when showBottomButton is false',
    (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const ApplicationUnderReviewCard(
            showBottomButton: false,
          ),
        ),
      );

      expect(find.text('Application Under Review'), findsOneWidget);
      expect(find.text('Complete Your Profile'), findsNothing);
    },
  );

  testWidgets('accepted status renders Profile Accepted + Go To Dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const ApplicationUnderReviewCard(
          status: ApplicationReviewStatus.accepted,
        ),
      ),
    );

    expect(find.text('Profile Accepted'), findsOneWidget);
    expect(find.text('Go To Dashboard'), findsOneWidget);
    expect(find.text('Refresh Status'), findsNothing);
    expect(find.text('Complete Your Profile'), findsNothing);
  });

  testWidgets('rejected status renders Profile Rejected + View Reason', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const ApplicationUnderReviewCard(
          status: ApplicationReviewStatus.rejected,
        ),
      ),
    );

    expect(find.text('Profile Rejected'), findsOneWidget);
    expect(find.text('View Reason'), findsOneWidget);
    expect(find.text('Refresh Status'), findsNothing);
  });

  testWidgets('non-dismissible dialog stays open on barrier and back', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildDialogTestApp(
        (context) => ApplicationUnderReviewDialog.show<void>(
          context,
          barrierDismissible: false,
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

  testWidgets('refresh morphs dialog to accepted state in place', (
    tester,
  ) async {
    var refreshCalls = 0;
    await tester.pumpWidget(
      buildDialogTestApp(
        (context) => ApplicationUnderReviewDialog.show<void>(
          context,
          barrierDismissible: false,
          onRefresh: () async {
            refreshCalls++;
            return 1;
          },
        ),
      ),
    );

    await tester.tap(find.text('Show review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Refresh Status'));
    await tester.pumpAndSettle();

    expect(refreshCalls, 1);
    expect(find.text('Profile Accepted'), findsOneWidget);
    expect(find.text('Go To Dashboard'), findsOneWidget);
    // Dialog still open, morphed in place.
    expect(find.text('Application Under Review'), findsOneWidget);
  });

  testWidgets('refresh morphs dialog to rejected state in place', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildDialogTestApp(
        (context) => ApplicationUnderReviewDialog.show<void>(
          context,
          barrierDismissible: false,
          onRefresh: () async => 2,
        ),
      ),
    );

    await tester.tap(find.text('Show review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Refresh Status'));
    await tester.pumpAndSettle();

    expect(find.text('Profile Rejected'), findsOneWidget);
    expect(find.text('View Reason'), findsOneWidget);
  });
}
