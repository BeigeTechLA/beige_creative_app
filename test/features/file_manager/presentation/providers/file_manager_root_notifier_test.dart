import 'package:beige_creative_app/features/file_manager/domain/models/fm_common_event.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_node.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_page.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_tab.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/link_state.dart';
import 'package:beige_creative_app/features/file_manager/domain/repositories/workspaces_repository.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/file_manager_root_notifier.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/file_manager_root_state.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/workspaces_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeWorkspacesRepo implements WorkspacesRepository {
  _FakeWorkspacesRepo({
    List<FmPage<FmFolder>>? pages,
    List<FmCommonEvent>? commonEvents,
  }) : _pages = pages ?? const [],
       _commonEvents = commonEvents ?? const [];

  final List<FmPage<FmFolder>> _pages;
  final List<FmCommonEvent> _commonEvents;

  @override
  Future<FmPage<FmFolder>> list({
    String? cursor,
    int limit = 20,
    String? workspaceType,
  }) async {
    final page = int.tryParse(cursor ?? '') ?? 1;
    final idx = page - 1;
    if (idx < 0 || idx >= _pages.length) {
      return const FmPage<FmFolder>(items: [], nextCursor: null);
    }
    return _pages[idx];
  }

  @override
  Future<List<FmCommonEvent>> listCommonEvents() async => _commonEvents;
}

FmFolder _folder(String id, String name, {LinkState? linkState}) =>
    FmFolder(id: id, name: name, fileCount: 1, linkState: linkState);

void main() {
  group('FileManagerRootNotifier', () {
    test('initial load populates items, cursor advances on loadMore',
        () async {
      final repo = _FakeWorkspacesRepo(pages: [
        FmPage<FmFolder>(
          items: [_folder('a', 'Alpha'), _folder('b', 'Beta')],
          nextCursor: '2',
        ),
        FmPage<FmFolder>(
          items: [_folder('c', 'Gamma')],
          nextCursor: null,
        ),
      ]);

      final container = ProviderContainer(overrides: [
        workspacesRepositoryProvider.overrideWithValue(repo),
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
    });

    test('selectTab(linked) filters to link_state == linked', () async {
      final repo = _FakeWorkspacesRepo(pages: [
        FmPage<FmFolder>(
          items: [
            _folder('a', 'Alpha', linkState: LinkState.linked),
            _folder('b', 'Beta'),
          ],
          nextCursor: null,
        ),
      ]);
      final container = ProviderContainer(overrides: [
        workspacesRepositoryProvider.overrideWithValue(repo),
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
      notifier.selectTab(FmTab.linked);
      await notifier.refresh();
      expect(
        container
            .read(fileManagerRootNotifierProvider)
            .items
            .map((f) => f.id),
        ['a'],
      );
    });

    test('commonEvents tab reads listCommonEvents', () async {
      final repo = _FakeWorkspacesRepo(
        commonEvents: [
          FmCommonEvent(
            eventId: 5,
            eventName: 'Common',
            eventSlug: 'common',
            externalId: 'event_common_1',
            rootPath: 'Event - Common/',
          ),
        ],
      );
      final container = ProviderContainer(overrides: [
        workspacesRepositoryProvider.overrideWithValue(repo),
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
      notifier.selectTab(FmTab.commonEvents);
      await notifier.refresh();
      final state = container.read(fileManagerRootNotifierProvider);
      expect(state.items.map((f) => f.id), ['event_common_1']);
      expect(state.items.first.name, 'Common');
      expect(state.hasMore, isFalse);
    });

    test('search query filters visibleItems without mutating items', () async {
      final repo = _FakeWorkspacesRepo(pages: [
        FmPage<FmFolder>(
          items: [
            _folder('a', 'Alpha'),
            _folder('b', 'Beta'),
            _folder('c', 'Banana'),
          ],
          nextCursor: null,
        ),
      ]);
      final container = ProviderContainer(overrides: [
        workspacesRepositoryProvider.overrideWithValue(repo),
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
