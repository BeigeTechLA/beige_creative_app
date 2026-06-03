import 'package:beige_creative_app/features/file_manager/data/repositories/file_manager_stub_repository.dart';
import 'package:beige_creative_app/features/file_manager/domain/entities/file_item.dart';
import 'package:flutter_test/flutter_test.dart';

/// File-manager backend is not live yet (Phase 4 left it on
/// `FileManagerStubRepository`). These tests pin the shape the stub returns so
/// notifier + widget tests can rely on it, and so swapping to a Dio-backed
/// impl later forces a deliberate test update. Network branches (401 / 5xx /
/// cancel) live in 6.03's other two test files — there is nothing to mock
/// here.
void main() {
  late FileManagerStubRepository repo;

  setUp(() {
    repo = const FileManagerStubRepository();
  });

  group('fetchAllFolders', () {
    test('returns 20 hardcoded folders with the canonical shape', () async {
      final folders = await repo.fetchAllFolders();

      expect(folders, hasLength(20));
      expect(folders.first.id, 'lana-123456');
      expect(folders.first.name, 'Lana #123456');
      expect(folders.first.category, 'Corporate Event');
      expect(folders.first.fileCount, 2);
    });

    test('every folder is identical (stub yields the same instance)',
        () async {
      final folders = await repo.fetchAllFolders();
      final first = folders.first;

      for (final f in folders) {
        expect(f.id, first.id);
        expect(f.name, first.name);
      }
    });
  });

  group('fetchRecentFolders', () {
    test('returns 20 folders, mirroring fetchAllFolders', () async {
      final folders = await repo.fetchRecentFolders();

      expect(folders, hasLength(20));
      expect(folders.first.openedAtLabel, 'Opened 2 hours ago');
    });
  });

  group('fetchPreProductionFiles', () {
    test('returns 6 files alternating pdf / doc', () async {
      final files = await repo.fetchPreProductionFiles('folder-1');

      expect(files, hasLength(6));
      expect(files[0].kind, FileKind.pdf);
      expect(files[1].kind, FileKind.doc);
      expect(files[2].kind, FileKind.pdf);
      expect(files[3].kind, FileKind.doc);
    });

    test('file ids are namespaced by folderId', () async {
      final files = await repo.fetchPreProductionFiles('abc-9');

      expect(files.map((f) => f.id), [
        'abc-9-0',
        'abc-9-1',
        'abc-9-2',
        'abc-9-3',
        'abc-9-4',
        'abc-9-5',
      ]);
    });

    test('pdf files report isPdf=true; doc files report isPdf=false',
        () async {
      final files = await repo.fetchPreProductionFiles('x');

      expect(files.where((f) => f.isPdf).length, 3);
      expect(files.where((f) => !f.isPdf).length, 3);
    });
  });

  group('fetchPostProductionFolders', () {
    test('returns 20 folders for any folderId', () async {
      final folders = await repo.fetchPostProductionFolders('any-id');
      expect(folders, hasLength(20));
    });
  });

  group('fetchFolder', () {
    test('returns the canonical folder regardless of id', () async {
      final folder = await repo.fetchFolder('does-not-matter');

      expect(folder, isNotNull);
      expect(folder!.name, 'Lana #123456');
    });
  });
}
