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
    required String searchQuery,
    required ValueChanged<String> onSearchChanged,
    required VoidCallback onFilterTap,
    required bool isFilterActive,
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
            searchQuery: searchQuery,
            onSearchChanged: onSearchChanged,
            onFilterTap: onFilterTap,
            isFilterActive: isFilterActive,
          ),
        ),
      ),
    );
  }

  testWidgets(
    'HomeUpcomingCarousel renders search bar and filter button when hasOriginalShoots is true',
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

      String updatedSearch = '';
      bool filterTapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          upcomingShoots: shoots,
          hasOriginalShoots: true,
          searchQuery: '',
          onSearchChanged: (val) => updatedSearch = val,
          onFilterTap: () => filterTapped = true,
          isFilterActive: false,
          vsync: tester,
        ),
      );

      // Verify Header and chevron
      expect(find.text('Upcoming Shoots'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_right), findsOneWidget);

      // Verify Search TextField and Hint
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search events or crew...'), findsOneWidget);

      // Verify Filter Button
      expect(find.text('Filter'), findsOneWidget);

      // Verify Card items
      expect(find.text('Wedding Shoot'), findsOneWidget);

      // Test Search interaction
      await tester.enterText(find.byType(TextField), 'Wedding');
      expect(updatedSearch, equals('Wedding'));

      // Test Filter interaction
      await tester.tap(find.text('Filter'));
      expect(filterTapped, isTrue);

      animationController.dispose();
    },
  );

  testWidgets(
    'HomeUpcomingCarousel displays empty message when filtered shoots list is empty but hasOriginalShoots is true',
    (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          upcomingShoots: [],
          hasOriginalShoots: true,
          searchQuery: 'Non-existent',
          onSearchChanged: (_) {},
          onFilterTap: () {},
          isFilterActive: true,
          vsync: tester,
        ),
      );

      expect(find.text('Upcoming Shoots'), findsOneWidget);
      expect(find.text('No upcoming shoots match filters.'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Filter'), findsOneWidget);

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
          searchQuery: '',
          onSearchChanged: (_) {},
          onFilterTap: () {},
          isFilterActive: false,
          vsync: tester,
        ),
      );

      expect(find.text('Upcoming Shoots'), findsNothing);
      expect(find.byType(TextField), findsNothing);

      animationController.dispose();
    },
  );
}
