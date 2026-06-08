import 'package:beige_creative_app/app/colors.dart';
import 'package:beige_creative_app/shared/layouts/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppScaffold', () {
    testWidgets('defaults: SafeArea top=true bottom=false, bg=AppColors.background',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppScaffold(
            body: SizedBox(key: Key('body'), height: 10),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.background);
      expect(scaffold.resizeToAvoidBottomInset, true);
      expect(scaffold.extendBodyBehindAppBar, false);

      final safeArea = tester.widget<SafeArea>(find.byType(SafeArea));
      expect(safeArea.top, true);
      expect(safeArea.bottom, false);
      expect(safeArea.left, true);
      expect(safeArea.right, true);

      expect(find.byKey(const Key('body')), findsOneWidget);
    });

    testWidgets('safeTop:false + all sides off skips SafeArea entirely',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppScaffold(
            safeTop: false,
            safeBottom: false,
            safeLeft: false,
            safeRight: false,
            body: SizedBox(key: Key('bleed'), height: 10),
          ),
        ),
      );

      expect(find.byType(SafeArea), findsNothing);
      expect(find.byKey(const Key('bleed')), findsOneWidget);
    });

    testWidgets('backgroundColor override wins over default', (tester) async {
      const override = Color(0xFF112233);
      await tester.pumpWidget(
        const MaterialApp(
          home: AppScaffold(
            backgroundColor: override,
            body: SizedBox.shrink(),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, override);
    });

    testWidgets('forwards appBar, bottomNavigationBar, drawer, FAB',
        (tester) async {
      const appBar = PreferredSize(
        preferredSize: Size.fromHeight(48),
        child: SizedBox(key: Key('appBar')),
      );
      const bottomBar = SizedBox(key: Key('bottomBar'), height: 56);
      const drawer = Drawer(key: Key('drawer'));
      const fab = FloatingActionButton(
        key: Key('fab'),
        onPressed: null,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: AppScaffold(
            appBar: appBar,
            bottomNavigationBar: bottomBar,
            drawer: drawer,
            floatingActionButton: fab,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            body: SizedBox.shrink(),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.appBar, same(appBar));
      expect(scaffold.bottomNavigationBar, same(bottomBar));
      expect(scaffold.drawer, same(drawer));
      expect(scaffold.floatingActionButton, same(fab));
      expect(
        scaffold.floatingActionButtonLocation,
        FloatingActionButtonLocation.endFloat,
      );
    });

    testWidgets('resizeToAvoidBottomInset:false propagates', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppScaffold(
            resizeToAvoidBottomInset: false,
            body: SizedBox.shrink(),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.resizeToAvoidBottomInset, false);
    });
  });
}
