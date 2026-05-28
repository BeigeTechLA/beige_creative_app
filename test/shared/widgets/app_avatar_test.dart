import 'package:beige_creative_app/shared/widgets/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppAvatar falls back to initials when imageUrl is null',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppAvatar(name: 'Bob Marley'),
          ),
        ),
      ),
    );

    expect(find.text('BM'), findsOneWidget);
  });

  testWidgets('AppAvatar single-name initial is one letter', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppAvatar(name: 'Cher'),
          ),
        ),
      ),
    );

    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('AppAvatar shows ? for empty name', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppAvatar(),
          ),
        ),
      ),
    );

    expect(find.text('?'), findsOneWidget);
  });
}
