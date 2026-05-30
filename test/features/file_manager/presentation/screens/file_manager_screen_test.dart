import 'package:beige_creative_app/features/file_manager/domain/entities/file_folder.dart';
import 'package:beige_creative_app/features/file_manager/domain/repositories/file_manager_repository.dart';
import 'package:beige_creative_app/features/file_manager/domain/entities/file_item.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/file_manager_providers.dart';
import 'package:beige_creative_app/features/file_manager/presentation/screens/file_manager_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements FileManagerRepository {
  static const _f = FileFolder(
    id: 'a',
    name: 'Alpha Project',
    fileCount: 3,
    category: 'Wedding',
    ownerInitials: 'AA',
    openedAtLabel: 'Opened just now',
  );
  static const _f2 = FileFolder(
    id: 'b',
    name: 'Beta Project',
    fileCount: 7,
    category: 'Corporate',
    ownerInitials: 'BB',
    openedAtLabel: 'Opened yesterday',
  );

  @override
  Future<List<FileFolder>> fetchAllFolders() async => const [_f, _f2];

  @override
  Future<List<FileFolder>> fetchRecentFolders() async => const [_f];

  @override
  Future<List<FileItem>> fetchPreProductionFiles(String folderId) async => [];

  @override
  Future<List<FileFolder>> fetchPostProductionFolders(String folderId) async =>
      [];

  @override
  Future<FileFolder?> fetchFolder(String folderId) async => _f;
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        fileManagerRepositoryProvider.overrideWithValue(_FakeRepo()),
      ],
      child: const MaterialApp(
        home: Scaffold(body: FileManagerScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('FileManagerScreen loads folders from repository and renders',
      (tester) async {
    await _pump(tester);

    expect(find.text('File Manager'), findsOneWidget);
    expect(find.text('Alpha Project'), findsOneWidget);
    expect(find.text('Beta Project'), findsOneWidget);
    expect(find.text('Wedding'), findsOneWidget);
  });

  testWidgets('FileManagerNotifier search filters by name', (tester) async {
    await _pump(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(FileManagerScreen)),
    );
    container.read(fileManagerNotifierProvider.notifier).setQuery('Beta');
    await tester.pumpAndSettle();

    expect(find.text('Alpha Project'), findsNothing);
    expect(find.text('Beta Project'), findsOneWidget);
  });

  testWidgets('FileManagerNotifier toggleView swaps card and list',
      (tester) async {
    await _pump(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(FileManagerScreen)),
    );
    expect(
      container.read(fileManagerNotifierProvider).view,
      FileManagerView.card,
    );

    container.read(fileManagerNotifierProvider.notifier).toggleView();
    expect(
      container.read(fileManagerNotifierProvider).view,
      FileManagerView.list,
    );
  });
}
