import 'package:beige_creative_app/features/file_manager/domain/entities/file_folder.dart';
import 'package:beige_creative_app/features/file_manager/domain/entities/file_item.dart';
import 'package:beige_creative_app/features/file_manager/domain/repositories/file_manager_repository.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/file_manager_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Notifier tests for the 4 file_manager Notifiers. The widget-level test
/// in `screens/file_manager_screen_test.dart` exercises the root Notifier's
/// search filter via the rendered UI; this file pins state transitions for
/// every public method on every Notifier (root + 3 sub-screen family
/// Notifiers) so a swap from the stub repo to a Dio-backed impl is a
/// drop-in change.

class _FakeRepo implements FileManagerRepository {
  int fetchAllCount = 0;
  int fetchRecentCount = 0;
  int fetchPreCount = 0;
  int fetchPostCount = 0;
  int fetchFolderCount = 0;
  String? lastFolderArg;

  List<FileFolder> all = const [];
  List<FileFolder> recent = const [];
  List<FileItem> preFiles = const [];
  List<FileFolder> postFolders = const [];
  FileFolder? folder;

  @override
  Future<List<FileFolder>> fetchAllFolders() async {
    fetchAllCount++;
    return all;
  }

  @override
  Future<List<FileFolder>> fetchRecentFolders() async {
    fetchRecentCount++;
    return recent;
  }

  @override
  Future<List<FileItem>> fetchPreProductionFiles(String folderId) async {
    fetchPreCount++;
    lastFolderArg = folderId;
    return preFiles;
  }

  @override
  Future<List<FileFolder>> fetchPostProductionFolders(String folderId) async {
    fetchPostCount++;
    lastFolderArg = folderId;
    return postFolders;
  }

  @override
  Future<FileFolder?> fetchFolder(String folderId) async {
    fetchFolderCount++;
    lastFolderArg = folderId;
    return folder;
  }
}

FileFolder _folder({
  String id = 'f1',
  String name = 'Lana #1',
  String category = 'Corporate',
}) =>
    FileFolder(
      id: id,
      name: name,
      fileCount: 2,
      category: category,
      ownerInitials: 'DP',
      openedAtLabel: 'Opened 1 hour ago',
    );

FileItem _file({
  String id = 'a-0',
  String name = 'Example.pdf',
  FileKind kind = FileKind.pdf,
}) =>
    FileItem(
      id: id,
      name: name,
      kind: kind,
      ownerInitials: 'DP',
      openedAtLabel: 'Opened 1 hour ago',
    );

Future<void> _drain(ProviderContainer c, bool Function() done) async {
  for (var i = 0; i < 30; i++) {
    if (done()) return;
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('FileManagerNotifier (root)', () {
    test('build → load hydrates all + recent and clears loading', () async {
      final repo = _FakeRepo()
        ..all = [_folder(id: 'a'), _folder(id: 'b')]
        ..recent = [_folder(id: 'r')];
      final c = ProviderContainer(
        overrides: [fileManagerRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      c.listen(fileManagerNotifierProvider, (_, _) {});

      await _drain(c, () => !c.read(fileManagerNotifierProvider).isLoading);

      final s = c.read(fileManagerNotifierProvider);
      expect(s.allFolders, hasLength(2));
      expect(s.recentFolders, hasLength(1));
      expect(s.isLoading, isFalse);
      expect(repo.fetchAllCount, 1);
      expect(repo.fetchRecentCount, 1);
    });

    test('setQuery filters allFolders + recentFolders by name and category',
        () async {
      final repo = _FakeRepo()
        ..all = [
          _folder(id: 'a', name: 'Wedding 1', category: 'Wedding'),
          _folder(id: 'b', name: 'Corporate gala', category: 'Corporate'),
          _folder(id: 'c', name: 'Birthday', category: 'Party'),
        ]
        ..recent = [
          _folder(id: 'r1', name: 'Corporate offsite', category: 'Corporate'),
        ];
      final c = ProviderContainer(
        overrides: [fileManagerRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      c.listen(fileManagerNotifierProvider, (_, _) {});
      await _drain(c, () => !c.read(fileManagerNotifierProvider).isLoading);

      c.read(fileManagerNotifierProvider.notifier).setQuery('corp');

      final s = c.read(fileManagerNotifierProvider);
      expect(s.filteredAll.map((f) => f.id).toList(), ['b']);
      expect(s.filteredRecent.map((f) => f.id).toList(), ['r1']);
    });

    test('empty query returns the full lists', () async {
      final repo = _FakeRepo()
        ..all = [_folder(id: 'a'), _folder(id: 'b')]
        ..recent = [_folder(id: 'r')];
      final c = ProviderContainer(
        overrides: [fileManagerRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      c.listen(fileManagerNotifierProvider, (_, _) {});
      await _drain(c, () => !c.read(fileManagerNotifierProvider).isLoading);

      c.read(fileManagerNotifierProvider.notifier).setQuery('');

      final s = c.read(fileManagerNotifierProvider);
      expect(s.filteredAll, hasLength(2));
      expect(s.filteredRecent, hasLength(1));
    });

    test('toggleView swaps card ↔ list', () async {
      final repo = _FakeRepo();
      final c = ProviderContainer(
        overrides: [fileManagerRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      c.listen(fileManagerNotifierProvider, (_, _) {});
      await _drain(c, () => !c.read(fileManagerNotifierProvider).isLoading);

      final notifier = c.read(fileManagerNotifierProvider.notifier);
      expect(c.read(fileManagerNotifierProvider).view, FileManagerView.card);
      notifier.toggleView();
      expect(c.read(fileManagerNotifierProvider).view, FileManagerView.list);
      notifier.toggleView();
      expect(c.read(fileManagerNotifierProvider).view, FileManagerView.card);
    });
  });

  group('PreProductionNotifier (family)', () {
    test('build → load hydrates files for given folderId', () async {
      final repo = _FakeRepo()
        ..preFiles = [
          _file(id: 'x-0', name: 'A.pdf'),
          _file(id: 'x-1', name: 'B.docx', kind: FileKind.doc),
        ];
      final c = ProviderContainer(
        overrides: [fileManagerRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      c.listen(preProductionNotifierProvider('folder-x'), (_, _) {});

      await _drain(
        c,
        () =>
            !c.read(preProductionNotifierProvider('folder-x')).isLoading,
      );

      final s = c.read(preProductionNotifierProvider('folder-x'));
      expect(s.files, hasLength(2));
      expect(s.isLoading, isFalse);
      expect(repo.lastFolderArg, 'folder-x');
      expect(repo.fetchPreCount, 1);
    });

    test('setQuery filters file names case-insensitively', () async {
      final repo = _FakeRepo()
        ..preFiles = [
          _file(id: '1', name: 'Brief.pdf'),
          _file(id: '2', name: 'Storyboard.docx', kind: FileKind.doc),
          _file(id: '3', name: 'Treatment.pdf'),
        ];
      final c = ProviderContainer(
        overrides: [fileManagerRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      c.listen(preProductionNotifierProvider('f'), (_, _) {});
      await _drain(
        c,
        () => !c.read(preProductionNotifierProvider('f')).isLoading,
      );

      c.read(preProductionNotifierProvider('f').notifier).setQuery('STORY');

      expect(
        c
            .read(preProductionNotifierProvider('f'))
            .filtered
            .map((f) => f.id)
            .toList(),
        ['2'],
      );
    });

    test('different folderId yields independent state', () async {
      final repo = _FakeRepo()..preFiles = [_file(id: 'shared')];
      final c = ProviderContainer(
        overrides: [fileManagerRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      c.listen(preProductionNotifierProvider('a'), (_, _) {});
      c.listen(preProductionNotifierProvider('b'), (_, _) {});
      await _drain(
        c,
        () =>
            !c.read(preProductionNotifierProvider('a')).isLoading &&
            !c.read(preProductionNotifierProvider('b')).isLoading,
      );

      c.read(preProductionNotifierProvider('a').notifier).setQuery('xyz');

      expect(c.read(preProductionNotifierProvider('a')).query, 'xyz');
      expect(c.read(preProductionNotifierProvider('b')).query, '');
      expect(repo.fetchPreCount, 2);
    });
  });

  group('PostProductionNotifier (family)', () {
    test('build → load hydrates folders for folderId', () async {
      final repo = _FakeRepo()
        ..postFolders = [_folder(id: 'p1'), _folder(id: 'p2')];
      final c = ProviderContainer(
        overrides: [fileManagerRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      c.listen(postProductionNotifierProvider('folder-y'), (_, _) {});
      await _drain(
        c,
        () =>
            !c.read(postProductionNotifierProvider('folder-y')).isLoading,
      );

      final s = c.read(postProductionNotifierProvider('folder-y'));
      expect(s.folders, hasLength(2));
      expect(s.isLoading, isFalse);
      expect(repo.lastFolderArg, 'folder-y');
    });

    test('setQuery filters folder names', () async {
      final repo = _FakeRepo()
        ..postFolders = [
          _folder(id: '1', name: 'Final cut'),
          _folder(id: '2', name: 'Drafts'),
        ];
      final c = ProviderContainer(
        overrides: [fileManagerRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      c.listen(postProductionNotifierProvider('f'), (_, _) {});
      await _drain(
        c,
        () => !c.read(postProductionNotifierProvider('f')).isLoading,
      );

      c.read(postProductionNotifierProvider('f').notifier).setQuery('final');

      expect(
        c
            .read(postProductionNotifierProvider('f'))
            .filtered
            .map((f) => f.id)
            .toList(),
        ['1'],
      );
    });

    test('empty query returns full list', () async {
      final repo = _FakeRepo()
        ..postFolders = [_folder(id: '1'), _folder(id: '2')];
      final c = ProviderContainer(
        overrides: [fileManagerRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      c.listen(postProductionNotifierProvider('f'), (_, _) {});
      await _drain(
        c,
        () => !c.read(postProductionNotifierProvider('f')).isLoading,
      );

      c.read(postProductionNotifierProvider('f').notifier).setQuery('');
      expect(c.read(postProductionNotifierProvider('f')).filtered, hasLength(2));
    });
  });

  group('ViewDetailsNotifier (family)', () {
    test('build → load hydrates folder for folderId', () async {
      final repo = _FakeRepo()..folder = _folder(id: 'vd', name: 'Lana Final');
      final c = ProviderContainer(
        overrides: [fileManagerRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      c.listen(viewDetailsNotifierProvider('vd'), (_, _) {});

      await _drain(
        c,
        () => !c.read(viewDetailsNotifierProvider('vd')).isLoading,
      );

      final s = c.read(viewDetailsNotifierProvider('vd'));
      expect(s.folder?.name, 'Lana Final');
      expect(s.isLoading, isFalse);
      expect(repo.lastFolderArg, 'vd');
    });

    test('null folder from repo leaves state.folder null but clears loading',
        () async {
      final repo = _FakeRepo()..folder = null;
      final c = ProviderContainer(
        overrides: [fileManagerRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      c.listen(viewDetailsNotifierProvider('missing'), (_, _) {});

      await _drain(
        c,
        () => !c.read(viewDetailsNotifierProvider('missing')).isLoading,
      );

      final s = c.read(viewDetailsNotifierProvider('missing'));
      expect(s.folder, isNull);
      expect(s.isLoading, isFalse);
    });

    test('different folderId reads independent state', () async {
      final repo = _FakeRepo()..folder = _folder(id: 'shared');
      final c = ProviderContainer(
        overrides: [fileManagerRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      c.listen(viewDetailsNotifierProvider('a'), (_, _) {});
      c.listen(viewDetailsNotifierProvider('b'), (_, _) {});

      await _drain(
        c,
        () =>
            !c.read(viewDetailsNotifierProvider('a')).isLoading &&
            !c.read(viewDetailsNotifierProvider('b')).isLoading,
      );

      expect(repo.fetchFolderCount, 2);
      expect(c.read(viewDetailsNotifierProvider('a')).folder, isNotNull);
      expect(c.read(viewDetailsNotifierProvider('b')).folder, isNotNull);
    });
  });
}
