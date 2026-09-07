import 'package:beige_creative_app/shared/widgets/app_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppSearchField renders hint and updates text on input',
      (tester) async {
    String captured = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppSearchField(
            hintText: 'Search events or crew...',
            onChanged: (val) => captured = val,
          ),
        ),
      ),
    );

    expect(find.text('Search events or crew...'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Wedding');
    await tester.pump();
    expect(captured, 'Wedding');
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });

  testWidgets('AppSearchField clears text on clear button tap',
      (tester) async {
    String captured = '';
    final controller = TextEditingController(text: 'Initial');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppSearchField(
            controller: controller,
            hintText: 'Search',
            onChanged: (val) => captured = val,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    expect(controller.text, '');
    expect(captured, '');
    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });
}
