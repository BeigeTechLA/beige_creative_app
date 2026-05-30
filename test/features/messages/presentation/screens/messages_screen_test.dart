import 'package:beige_creative_app/features/messages/presentation/screens/messages_screen.dart';
import 'package:beige_creative_app/shared/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MessagesScreen renders placeholder empty state', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: MessagesScreen()),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Inbox arriving soon.'), findsOneWidget);
    expect(find.byIcon(Icons.forum_outlined), findsOneWidget);
  });
}
