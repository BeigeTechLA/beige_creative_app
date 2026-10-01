import 'package:beige_creative_app/features/affiliate/presentation/widgets/affiliate_how_it_works.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AffiliateHowItWorks renders 3 step rows with 28x28 icons',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AffiliateHowItWorks(),
          ),
        ),
      ),
    );

    expect(find.text('1. Share Code'), findsOneWidget);
    expect(find.text('2. They Book'), findsOneWidget);
    expect(find.text('3. You Earn'), findsOneWidget);

    final svgFinders = find.byType(SvgPicture);
    expect(svgFinders, findsNWidgets(3));

    for (final element in tester.widgetList<SvgPicture>(svgFinders)) {
      expect(element.width, 28);
      expect(element.height, 28);
    }
  });
}
