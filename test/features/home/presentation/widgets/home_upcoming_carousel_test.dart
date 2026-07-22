import 'package:beige_creative_app/config/env.dart';
import 'package:beige_creative_app/features/home/presentation/widgets/home_upcoming_carousel.dart';
import 'package:beige_creative_app/model_class/upcoming_shoots_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AnimationController animationController;

  setUpAll(() {
    Env.init(Environment.dev);
  });

  Widget buildTestWidget({
    required List<UpcomingShootDatum> upcomingShoots,
    required bool hasOriginalShoots,
    required TickerProvider vsync,
  }) {
    animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 100),
    );
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: HomeUpcomingCarousel(
            upcomingShoots: upcomingShoots,
            hasOriginalShoots: hasOriginalShoots,
            currentIndex: 0,
            controller: animationController,
            onCardTap: () {},
            onSwipeNext: () {},
            onSwipePrevious: () {},
          ),
        ),
      ),
    );
  }

  testWidgets(
    'HomeUpcomingCarousel renders header and cards when hasOriginalShoots is true',
    (tester) async {
      final shoots = [
        UpcomingShootDatum(
          shootType: 'Studio',
          shootTypeImageUrl: '',
          projectId: 1,
          projectName: 'Wedding Shoot',
          eventDate: DateTime(2026, 6, 15),
          startTime: '10:00',
          endTime: '14:00',
          eventLocation: 'Los Angeles, CA',
          budget: 500,
          isCompleted: false,
        ),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          upcomingShoots: shoots,
          hasOriginalShoots: true,
          vsync: tester,
        ),
      );

      // Verify Header and chevron
      expect(find.text('Upcoming Shoots'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_right), findsOneWidget);

      // Verify Card items
      expect(find.text('Wedding Shoot'), findsOneWidget);

      animationController.dispose();
    },
  );

  testWidgets(
    'HomeUpcomingCarousel displays empty message when shoots list is empty but hasOriginalShoots is true',
    (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          upcomingShoots: [],
          hasOriginalShoots: true,
          vsync: tester,
        ),
      );

      expect(find.text('Upcoming Shoots'), findsOneWidget);
      expect(find.text('No upcoming shoots match filters.'), findsOneWidget);

      animationController.dispose();
    },
  );

  testWidgets(
    'HomeUpcomingCarousel returns shrinked sized box when hasOriginalShoots is false',
    (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          upcomingShoots: [],
          hasOriginalShoots: false,
          vsync: tester,
        ),
      );

      expect(find.text('Upcoming Shoots'), findsNothing);

      animationController.dispose();
    },
  );
}
