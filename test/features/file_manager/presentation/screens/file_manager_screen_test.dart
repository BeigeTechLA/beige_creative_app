import 'package:beige_creative_app/features/file_manager/domain/models/fm_node.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_page.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_tab.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/link_state.dart';
import 'package:beige_creative_app/features/file_manager/domain/repositories/file_manager_repository.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/file_manager_repository_provider.dart';
import 'package:beige_creative_app/features/file_manager/presentation/screens/file_manager_screen.dart';
import 'package:beige_creative_app/features/file_manager/presentation/widgets/fm_actions_sheet.dart';
import 'package:beige_creative_app/features/file_manager/presentation/widgets/fm_folder_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

class _Repo implements FileManagerRepository {
  _Repo(this.roots);
  final List<FmFolder> roots;

  @override
  Future<FmPage<FmFolder>> listRoot({
    required FmTab tab,
    String? cursor,
    int limit = 20,
  }) async {
    if (tab == FmTab.linked) {
      return FmPage<FmFolder>(
        items: roots.where((f) => f.linkState == LinkState.linked).toList(),
        nextCursor: null,
      );
    }
    return FmPage<FmFolder>(items: roots, nextCursor: null);
  }

  @override
  Future<FmPage<FmNode>> listFolder({
    required String folderId,
    String? cursor,
    int limit = 20,
  }) async => const FmPage<FmNode>(items: []);

  @override
  Future<String> getShareLink({required nodeId, required kind}) async => '';
  @override
  Future<void> deleteNode({required nodeId, required kind}) async {}
  @override
  Future<String> downloadFile({
    required fileId,
    void Function(double)? onProgress,
    CancelToken? cancelToken,
  }) async => '';
}

void main() {
  group('FileManagerScreen', () {
    testWidgets('renders root folders from repo', (tester) async {
      final repo = _Repo([
        const FmFolder(
          id: 'a',
          name: 'Alpha',
          fileCount: 2,
          linkState: LinkState.linked,
        ),
        const FmFolder(
          id: 'b',
          name: 'Beta',
          fileCount: 1,
        ),
      ]);
      await tester.pumpProviderApp(
        const Scaffold(body: FileManagerScreen()),
        overrides: [fileManagerRepositoryProvider.overrideWithValue(repo)],
      );
      await tester.pumpAndSettle();

      expect(find.byType(FmFolderCard), findsNWidgets(2));
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('Linked tab filters via repo', (tester) async {
      final repo = _Repo([
        const FmFolder(
          id: 'a',
          name: 'Alpha',
          fileCount: 2,
          linkState: LinkState.linked,
        ),
        const FmFolder(id: 'b', name: 'Beta', fileCount: 1),
      ]);
      await tester.pumpProviderApp(
        const Scaffold(body: FileManagerScreen()),
        overrides: [fileManagerRepositoryProvider.overrideWithValue(repo)],
      );
      await tester.pumpAndSettle();
      expect(find.byType(FmFolderCard), findsNWidgets(2));

      await tester.tap(find.text('Linked Files'));
      await tester.pumpAndSettle();
      expect(find.byType(FmFolderCard), findsOneWidget);
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsNothing);
    });

    testWidgets('search clears list to empty state', (tester) async {
      final repo = _Repo([
        const FmFolder(id: 'a', name: 'Alpha', fileCount: 1),
      ]);
      await tester.pumpProviderApp(
        const Scaffold(body: FileManagerScreen()),
        overrides: [fileManagerRepositoryProvider.overrideWithValue(repo)],
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzzzz');
      await tester.pumpAndSettle();

      expect(find.byType(FmFolderCard), findsNothing);
      expect(find.text('No matches'), findsOneWidget);
    });

    testWidgets('⋮ opens action sheet w/ folder variant (no Download)',
        (tester) async {
      final repo = _Repo([
        const FmFolder(id: 'a', name: 'Alpha', fileCount: 1),
      ]);
      await tester.pumpProviderApp(
        const Scaffold(body: FileManagerScreen()),
        overrides: [fileManagerRepositoryProvider.overrideWithValue(repo)],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Download'), findsNothing);
      // also confirms the sheet widget itself exists
      expect(find.byType(BottomSheet), findsOneWidget);
      // FmNodeAction is the enum returned from showFmActionsSheet
      expect(FmNodeAction.values.length, 4);
    });
  });
}
