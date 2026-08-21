import 'package:beige_creative_app/shared/widgets/app_icon_tap_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppIconTapTarget enforces 44x44 minimum and taps', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppIconTapTarget(
              semanticLabel: 'Back',
              onTap: () => tapped = true,
              icon: const SizedBox(width: 24, height: 24),
            ),
          ),
        ),
      ),
    );

    final targetSize = tester.getSize(find.byType(AppIconTapTarget));
    expect(targetSize.width, 44);
    expect(targetSize.height, 44);

    await tester.tap(find.byType(AppIconTapTarget));
    expect(tapped, true);
  });
}
