import 'package:beige_creative_app/config/env.dart';
import 'package:beige_creative_app/features/home/presentation/widgets/home_dashboard_summary.dart';
import 'package:beige_creative_app/features/home/presentation/widgets/home_pending_shoot_card.dart';
import 'package:beige_creative_app/features/home/presentation/widgets/home_shoot_categories_panel.dart';
import 'package:beige_creative_app/features/home/presentation/widgets/home_shoot_status_panel.dart';
import 'package:beige_creative_app/features/home/presentation/widgets/home_status_item.dart';
import 'package:beige_creative_app/features/home/presentation/widgets/home_welcome_header.dart';
import 'package:beige_creative_app/model_class/create_dashboard_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

PendingRequestCard _fixturePendingShoot() {
  return PendingRequestCard(
    id: 1,
    projectId: 42,
    crewMemberId: 7,
    projectName: 'Studio Sunset Test',
    eventDate: DateTime(2026, 6, 1),
    startTime: '09:00:00',
    endTime: '17:00:00',
    eventLocation: 'Brooklyn, NY',
    contentType: 'photo',
    shootTypeId: 1,
    totalAmount: 500,
    budget: 500,
    status: 'pending',
    crewAccept: 0,
    canTakeAction: true,
    shootType: 'Studio',
    shootTypeImageUrl: '',
    cta: Cta(primary: 'Accept', secondary: 'Reject'),
  );
}

void main() {
  setUpAll(() => Env.init(Environment.dev));

  group('HomeScreen decompose characterization', () {
    testWidgets(
      'HomeWelcomeHeader renders welcome text + avatar fallback',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HomeWelcomeHeader(
                firstName: 'Casey',
                profileImageUrl: '',
                onAvatarTap: () {},
              ),
            ),
          ),
        );
        expect(find.text('Welcome Back, Casey'), findsOneWidget);
        expect(find.byType(CircleAvatar), findsOneWidget);
      },
    );

    testWidgets(
      'HomeDashboardSummary renders all 3 summary cards with counts',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HomeDashboardSummary(
                completedShoots: 12,
                upcomingShoots: 4,
                pendingRequests: 7,
                selectedIndex: 0,
                onSelect: (_) {},
              ),
            ),
          ),
        );
        expect(find.text('Your Dashboard'), findsOneWidget);
        expect(find.text('Completed shoots'), findsOneWidget);
        expect(find.text('Upcoming shoots'), findsOneWidget);
        expect(find.text('Pending Requests'), findsOneWidget);
        expect(find.text('12'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
        expect(find.text('7'), findsOneWidget);
      },
    );

    testWidgets(
      'HomeShootStatusPanel renders header + 4 status rows',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: HomeShootStatusPanel(
                  successfulShoots: 3,
                  pendingShoots: 1,
                  rejectedShoots: 2,
                  shootRequests: 5,
                  selectedRange: 'Month',
                  rangeOptions: const ['Week', 'Month', 'Year'],
                  onRangeChanged: (_) {},
                ),
              ),
            ),
          ),
        );
        expect(find.text('Shoot Status'), findsOneWidget);
        expect(find.text('Successful shoots'), findsOneWidget);
        expect(find.text('Pending shoots'), findsOneWidget);
        expect(find.text('Rejected shoots'), findsOneWidget);
        expect(find.text('Shoot Requests'), findsOneWidget);
        // Aggregate count "3+1+2+5 = 11" in the centre of the chart.
        expect(find.text('11'), findsOneWidget);
        expect(find.byType(HomeStatusItem), findsNWidgets(4));
      },
    );

    testWidgets(
      'HomeShootCategoriesPanel renders Photo/Video tabs + status rows',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: HomeShootCategoriesPanel(
                  selectedTab: 0,
                  categoryPhotoTotal: 9,
                  categoryVideoTotal: 0,
                  acceptPhotographyShoots: 5,
                  acceptVideographyShoots: 0,
                  rejectedPhoto: 1,
                  rejectedVideo: 0,
                  requestPhoto: 3,
                  requestVideo: 0,
                  onTabChanged: (_) {},
                ),
              ),
            ),
          ),
        );
        expect(find.text('Shoot Categories'), findsOneWidget);
        expect(find.text('Photo'), findsOneWidget);
        expect(find.text('Video'), findsOneWidget);
        expect(find.text('Photography shoots'), findsOneWidget);
        expect(find.text('Videography shoots'), findsOneWidget);
        // Photo total renders in centre when selectedTab == 0.
        expect(find.text('9'), findsOneWidget);
      },
    );

    testWidgets(
      'HomePendingShootCard renders project name + accept/reject CTAs',
      (tester) async {
        final shoot = _fixturePendingShoot();
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => Scaffold(
                body: SingleChildScrollView(
                  child: HomePendingShootCard(
                    pendingShoot: shoot,
                    onAccept: (_) {},
                    onRejectComplete: () {},
                  ),
                ),
              ),
            ),
          ],
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        // Don't pumpAndSettle — network image will throw.
        expect(find.text('Studio Sunset Test'), findsOneWidget);
        expect(find.text('View Details'), findsOneWidget);
        expect(find.text('Accept'), findsOneWidget);
        expect(find.text('Reject'), findsOneWidget);
        expect(find.text('Brooklyn, NY'), findsOneWidget);
      },
    );
  });
}
