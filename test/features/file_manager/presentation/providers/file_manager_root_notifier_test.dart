import 'package:beige_creative_app/features/file_manager/domain/models/fm_node.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_page.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_tab.dart';
import 'package:beige_creative_app/features/file_manager/domain/repositories/file_manager_repository.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/file_manager_repository_provider.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/file_manager_root_notifier.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/file_manager_root_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements FileManagerRepository {
  _FakeRepo({required this.pages});

  final Map<FmTab, List<FmPage<FmFolder>>> pages;
  int callsByTab = 0;
  final Map<FmTab, int> _cursorByTab = {};

  @override
  Future<FmPage<FmFolder>> listRoot({
    required FmTab tab,
    String? cursor,
    int limit = 20,
  }) async {
    callsByTab++;
    final pageIdx = int.tryParse(cursor ?? '0') ?? 0;
    _cursorByTab[tab] = pageIdx;
    final tabPages = pages[tab] ?? const <FmPage<FmFolder>>[];
    if (pageIdx >= tabPages.length) {
      return const FmPage<FmFolder>(items: [], nextCursor: null);
    }
    return tabPages[pageIdx];
  }

  @override
  Future<FmPage<FmNode>> listFolder({
    required String folderId,
    String? cursor,
    int limit = 20,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String> getShareLink({
    required String nodeId,
    required FmNodeKind kind,
  }) async => throw UnimplementedError();

  @override
  Future<void> deleteNode({
    required String nodeId,
    required FmNodeKind kind,
  }) async => throw UnimplementedError();

  @override
  Future<String> downloadFile({
    required String fileId,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async => throw UnimplementedError();
}

FmFolder _folder(String id, String name) =>
    FmFolder(id: id, name: name, fileCount: 1);

void main() {
  group('FileManagerRootNotifier', () {
    test('initial load populates items, cursor advances on loadMore',
        (() async {
      final repo = _FakeRepo(pages: {
        FmTab.all: [
          FmPage<FmFolder>(
            items: [_folder('a', 'Alpha'), _folder('b', 'Beta')],
            nextCursor: '1',
          ),
          const FmPage<FmFolder>(items: [], nextCursor: null),
        ],
      });
      // Page 2 swapped to a real second batch:
      repo.pages[FmTab.all]![1] = FmPage<FmFolder>(
        items: [_folder('c', 'Gamma')],
        nextCursor: null,
      );

      final container = ProviderContainer(overrides: [
        fileManagerRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(container.dispose);
      final sub = container.listen(
        fileManagerRootNotifierProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      final notifier =
          container.read(fileManagerRootNotifierProvider.notifier);
      await notifier.refresh();
      var state = container.read(fileManagerRootNotifierProvider);
      expect(state.items.map((f) => f.id), ['a', 'b']);
      expect(state.hasMore, isTrue);
      expect(state.status, FmListStatus.ready);

      await notifier.loadMore();
      state = container.read(fileManagerRootNotifierProvider);
      expect(state.items.map((f) => f.id), ['a', 'b', 'c']);
      expect(state.hasMore, isFalse);
    }));

    test('selectTab reloads against the new tab', () async {
      final repo = _FakeRepo(pages: {
        FmTab.all: [
          FmPage<FmFolder>(
            items: [_folder('a', 'Alpha')],
            nextCursor: null,
          ),
        ],
        FmTab.linked: [
          FmPage<FmFolder>(
            items: [_folder('z', 'Zed')],
            nextCursor: null,
          ),
        ],
      });

      final container = ProviderContainer(overrides: [
        fileManagerRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(container.dispose);
      final sub = container.listen(
        fileManagerRootNotifierProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      final notifier =
          container.read(fileManagerRootNotifierProvider.notifier);
      await notifier.refresh();
      expect(
        container
            .read(fileManagerRootNotifierProvider)
            .items
            .map((f) => f.id),
        ['a'],
      );

      notifier.selectTab(FmTab.linked);
      await notifier.refresh();
      expect(
        container
            .read(fileManagerRootNotifierProvider)
            .items
            .map((f) => f.id),
        ['z'],
      );
    });

    test('search query filters visibleItems without mutating items', () async {
      final repo = _FakeRepo(pages: {
        FmTab.all: [
          FmPage<FmFolder>(
            items: [
              _folder('a', 'Alpha'),
              _folder('b', 'Beta'),
              _folder('c', 'Banana'),
            ],
            nextCursor: null,
          ),
        ],
      });
      final container = ProviderContainer(overrides: [
        fileManagerRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(container.dispose);
      final sub = container.listen(
        fileManagerRootNotifierProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      final notifier =
          container.read(fileManagerRootNotifierProvider.notifier);
      await notifier.refresh();
      notifier.setSearchQuery('be');
      var state = container.read(fileManagerRootNotifierProvider);
      expect(state.items.length, 3, reason: 'raw list untouched');
      expect(state.visibleItems.map((f) => f.id), ['b']);

      notifier.setSearchQuery('an');
      state = container.read(fileManagerRootNotifierProvider);
      expect(state.visibleItems.map((f) => f.id), ['c']);
    });
  });
}
