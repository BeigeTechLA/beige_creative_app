import 'package:beige_creative_app/shared/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppCircularLoader renders CircularProgressIndicator', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppCircularLoader()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AppCircularLoader forces sized square when size is passed', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppCircularLoader(size: 24)),
      ),
    );

    final box = tester.firstWidget<SizedBox>(find.byType(SizedBox));
    expect(box.width, 24);
    expect(box.height, 24);
  });

  testWidgets('AppLoader renders Lottie asset', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppLoader()),
      ),
    );

    expect(find.byType(AppLoader), findsOneWidget);
  });

  testWidgets('AppScreenLoader renders Lottie asset', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppScreenLoader()),
      ),
    );

    expect(find.byType(AppScreenLoader), findsOneWidget);
  });

  testWidgets('AppSuccessAnimation renders success Lottie', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppSuccessAnimation()),
      ),
    );

    expect(find.byType(AppSuccessAnimation), findsOneWidget);
  });

  testWidgets('AppImageLoader renders loader Lottie', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppImageLoader()),
      ),
    );

    expect(find.byType(AppImageLoader), findsOneWidget);
  });

  testWidgets('AppLoadingOverlay renders Lottie overlay', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Text('Background content'),
              AppLoadingOverlay(),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(AppLoadingOverlay), findsOneWidget);
  });
}
