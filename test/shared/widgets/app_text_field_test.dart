import 'package:beige_creative_app/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppTextField renders label and forwards changes',
      (tester) async {
    String captured = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(
            label: 'Email',
            hint: 'you@beige.app',
            onChanged: (v) => captured = v,
          ),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('you@beige.app'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'me@beige.app');
    expect(captured, 'me@beige.app');
  });
}
