import 'package:beige_creative_app/config/env.dart';
import 'package:beige_creative_app/features/profile/presentation/widgets/notification_category_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() => Env.init(Environment.dev));

  group('NotificationCategorySheet', () {
    testWidgets('renders categories and svg icons properly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: NotificationCategorySheet(),
            ),
          ),
        ),
      );

      expect(find.text('Select Categories'), findsOneWidget);
      expect(find.text('Shoots'), findsOneWidget);
      expect(find.text('Payments'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('Meetings'), findsOneWidget);
      expect(find.text('Proposals'), findsOneWidget);
      expect(find.text('Files'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);

      expect(find.byType(SvgPicture), findsNWidgets(7));
      expect(find.text('Save'), findsOneWidget);
    });
  });
}
