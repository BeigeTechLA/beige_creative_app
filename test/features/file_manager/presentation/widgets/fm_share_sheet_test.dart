import 'package:beige_creative_app/features/file_manager/domain/models/fm_folder_key.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/shares_notifier.dart';
import 'package:beige_creative_app/features/file_manager/presentation/widgets/fm_share_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../providers/shares_notifier_test.dart' show FakeSharesRepository;

void main() {
  const target = FmShareTarget(
    key: FmFolderKey(externalId: '5406'),
    name: 'Project',
  );

  Future<void> mount(WidgetTester tester, FakeSharesRepository repo) async {
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharesRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(
          home: Scaffold(body: FmShareSheet(target: target)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('failed invite keeps entered email and does not add a person', (
    tester,
  ) async {
    final repo = FakeSharesRepository()..failCreate = true;
    await mount(tester, repo);
    await tester.enterText(find.byType(TextField).first, 'new@example.com');
    await tester.pump();
    await tester.tap(find.text('Invite'));
    await tester.pumpAndSettle();
    expect(
      find.text('Could not create the share. Please try again.'),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'new@example.com',
    );
    expect(repo.shares, isEmpty);
  });

  testWidgets('public link creation shows copy and revoke actions', (
    tester,
  ) async {
    final repo = FakeSharesRepository();
    await mount(tester, repo);
    await tester.tap(find.text('Create link'));
    await tester.pumpAndSettle();
    expect(find.text('Copy Link'), findsOneWidget);
    expect(find.text('Create link'), findsNothing);
    await tester.tap(find.byTooltip('Remove access'));
    await tester.pumpAndSettle();
    expect(find.text('Create link'), findsOneWidget);
    expect(repo.shares, isEmpty);
  });

  testWidgets('activity log opens with empty state', (tester) async {
    await mount(tester, FakeSharesRepository());
    await tester.tap(find.text('Activity Log'));
    await tester.pumpAndSettle();
    expect(find.text('No activity yet.'), findsOneWidget);
  });
}
