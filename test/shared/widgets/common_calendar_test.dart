import 'package:beige_creative_app/shared/widgets/common_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CommonCalendar keeps event labels readable at 320px width', (
    tester,
  ) async {
    final focusedDay = DateTime(2026, 7, 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: CommonCalendar(
                focusedDay: focusedDay,
                events: {DateTime(2026, 7, 1): 'Available'},
                selectedEvent: 'All Events',
                onPageChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    final label = tester.widget<Text>(find.text('Available'));
    expect(label.style?.fontSize, greaterThanOrEqualTo(11));
  });
}
