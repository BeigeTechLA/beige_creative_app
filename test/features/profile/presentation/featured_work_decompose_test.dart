import 'package:beige_creative_app/config/env.dart';
import 'package:beige_creative_app/features/profile/presentation/widgets/featured_work_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() => Env.init(Environment.dev));

  group('FeaturedWorkGrid', () {
    testWidgets('empty input renders placeholder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeaturedWorkGrid(
              featuredWorkFiles: const [],
              onEdit: (_, _) {},
              onDelete: (_) {},
              onNavigate: (_, _) {},
            ),
          ),
        ),
      );

      expect(find.text('No Featured Work'), findsOneWidget);
    });

    testWidgets('groups items by title', (tester) async {
      final items = [
        _Item('Wedding', 'a.jpg'),
        _Item('Wedding', 'b.jpg'),
        _Item('Corporate', 'c.jpg'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeaturedWorkGrid(
              featuredWorkFiles: items,
              onEdit: (_, _) {},
              onDelete: (_) {},
              onNavigate: (_, _) {},
            ),
          ),
        ),
      );

      expect(find.text('Wedding'), findsOneWidget);
      expect(find.text('Corporate'), findsOneWidget);
    });

    testWidgets('onEdit + onDelete fire on tap', (tester) async {
      String? editedTitle;
      List<dynamic>? deletedImages;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeaturedWorkGrid(
              featuredWorkFiles: [_Item('Solo', 'x.jpg')],
              onEdit: (title, _) => editedTitle = title,
              onDelete: (images) => deletedImages = images,
              onNavigate: (_, _) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();
      expect(editedTitle, 'Solo');

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();
      expect(deletedImages, isNotNull);
      expect(deletedImages!.length, 1);
    });
  });
}

class _Item {
  final String title;
  final String filePath;
  _Item(this.title, this.filePath);
}
