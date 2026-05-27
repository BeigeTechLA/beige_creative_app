import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beige_creative_app/main.dart';

void main() {
  testWidgets('App smoke test - verifies MaterialApp.router build', (WidgetTester tester) async {
    // Build our app and trigger a frame with isLoggedIn = false
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    // Verify that a MaterialApp exists in the tree
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
