import 'package:beige_creative_app/features/file_manager/domain/models/fm_common_event.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_node.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_page.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/link_state.dart';
import 'package:beige_creative_app/features/file_manager/domain/repositories/workspaces_repository.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/workspaces_repository_provider.dart';
import 'package:beige_creative_app/features/file_manager/presentation/screens/file_manager_screen.dart';
import 'package:beige_creative_app/features/file_manager/presentation/widgets/fm_actions_sheet.dart';
import 'package:beige_creative_app/features/file_manager/presentation/widgets/fm_folder_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

class _WorkspacesRepo implements WorkspacesRepository {
  _WorkspacesRepo(this.roots);
  final List<FmFolder> roots;

  @override
  Future<FmPage<FmFolder>> list({
    String? cursor,
    int limit = 20,
    String? workspaceType,
  }) async {
    return FmPage<FmFolder>(items: roots, nextCursor: null);
  }

  @override
  Future<List<FmCommonEvent>> listCommonEvents() async => const [];
}

void main() {
  group('FileManagerScreen', () {
    testWidgets('renders root folders from repo', (tester) async {
      final repo = _WorkspacesRepo([
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
        overrides: [workspacesRepositoryProvider.overrideWithValue(repo)],
      );
      await tester.pumpAndSettle();

      expect(find.byType(FmFolderCard), findsNWidgets(2));
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('Linked tab filters via client-side link_state check',
        (tester) async {
      final repo = _WorkspacesRepo([
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
        overrides: [workspacesRepositoryProvider.overrideWithValue(repo)],
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
      final repo = _WorkspacesRepo([
        const FmFolder(id: 'a', name: 'Alpha', fileCount: 1),
      ]);
      await tester.pumpProviderApp(
        const Scaffold(body: FileManagerScreen()),
        overrides: [workspacesRepositoryProvider.overrideWithValue(repo)],
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzzzz');
      await tester.pumpAndSettle();

      expect(find.byType(FmFolderCard), findsNothing);
      expect(find.text('No matches'), findsOneWidget);
    });

    testWidgets('⋮ opens action sheet w/ Open · Share · Download · Delete',
        (tester) async {
      final repo = _WorkspacesRepo([
        const FmFolder(id: 'a', name: 'Alpha', fileCount: 1),
      ]);
      await tester.pumpProviderApp(
        const Scaffold(body: FileManagerScreen()),
        overrides: [workspacesRepositoryProvider.overrideWithValue(repo)],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      // Universal 4-item kebab per design §3.15. Folder download now
      // hits `/folder-download-url` (server-generated ZIP) — enabled
      // as of FM7.05.
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Download'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(FmNodeAction.values.length, 4);
    });
  });
}
