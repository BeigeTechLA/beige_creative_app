import 'package:beige_creative_app/features/messages/presentation/screens/messages_screen.dart';
import 'package:beige_creative_app/shared/widgets/app_empty_state.dart';
import 'package:beige_creative_app/shared/widgets/app_main_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MessagesScreen renders placeholder empty state', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            drawer: Drawer(child: Text('drawer-open')),
            body: MessagesScreen(),
          ),
        ),
      ),
    );

    expect(find.byType(AppMainToolbar), findsOneWidget);
    expect(find.text('messages'), findsOneWidget);
    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Inbox arriving soon.'), findsOneWidget);
    expect(find.byIcon(Icons.forum_outlined), findsOneWidget);
  });

  testWidgets('MessagesScreen toolbar menu opens app drawer', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            drawer: Drawer(child: Text('drawer-open')),
            body: MessagesScreen(),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();

    expect(find.text('drawer-open'), findsOneWidget);
  });
}
