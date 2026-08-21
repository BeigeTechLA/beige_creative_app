import 'package:beige_creative_app/core/providers/core_providers.dart';
import 'package:beige_creative_app/core/session/session_store.dart';
import 'package:beige_creative_app/features/file_manager/data/repositories/comments_repository_dummy.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_comment.dart';
import 'package:beige_creative_app/features/file_manager/domain/repositories/comments_repository.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/comments_notifier.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/comments_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSession implements SessionStore {
  _FakeSession(this.user);
  final UserSnapshot? user;

  @override
  Future<UserSnapshot?> readUser() async => user;
  @override
  UserSnapshot? readUserSync() => user;

  // Everything else — unused by CommentsNotifier.
  @override
  Future<void> writeToken(String token) async {}
  @override
  Future<void> writeUser(UserSnapshot u) async {}
  @override
  Future<void> writeLastLoginAt(DateTime when) async {}
  @override
  Future<String?> readToken() async => null;
  @override
  Future<void> clearToken() async {}
  @override
  Future<String?> readRefreshToken() async => null;
  @override
  Future<void> writeRefreshToken(String token) async {}
  @override
  Future<void> clearRefreshToken() async {}
  @override
  Future<void> clearUser() async {}
  @override
  Future<DateTime?> readLastLoginAt() async => null;
  @override
  Future<bool> readOnboardingSeen() async => false;
  @override
  Future<void> writeOnboardingSeen(bool seen) async {}
  @override
  Future<bool> isLoggedIn() async => user != null;
  @override
  Future<void> clearSession() async {}
}

ProviderContainer _container({
  required CommentsRepository repo,
  UserSnapshot? user = const UserSnapshot(id: '626', name: 'test crew'),
}) {
  final container = ProviderContainer(overrides: [
    commentsRepositoryProvider.overrideWithValue(repo),
    sessionStoreProvider.overrideWithValue(_FakeSession(user)),
  ]);
  return container;
}

void main() {
  const fileMetaId = 'proj_x/Post-Production/Edits/Version1/5.jpeg';

  group('CommentsNotifier', () {
    setUp(() {
      // Reset dummy static state between tests.
      CommentsRepositoryDummy();
    });

    test('build loads current comments from the repo', () async {
      final repo = CommentsRepositoryDummy();
      await repo.add(fileMetaId: fileMetaId, userId: '999', body: 'seed');

      final container = _container(repo: repo);
      addTearDown(container.dispose);

      final async = await container.read(
        commentsNotifierProvider(fileMetaId).future,
      );
      expect(async.length, greaterThanOrEqualTo(1));
      expect(async.any((c) => c.body == 'seed'), isTrue);
    });

    test('post appends comment to state', () async {
      final repo = CommentsRepositoryDummy();
      final container = _container(repo: repo);
      addTearDown(container.dispose);
      final sub = container.listen(
        commentsNotifierProvider(fileMetaId),
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);
      await container.read(commentsNotifierProvider(fileMetaId).future);

      final posted = await container
          .read(commentsNotifierProvider(fileMetaId).notifier)
          .post('hello world');

      expect(posted.body, 'hello world');
      final state = container.read(commentsNotifierProvider(fileMetaId));
      expect(state.value!.any((c) => c.body == 'hello world'), isTrue);
    });

    test('reply nests under parent in state', () async {
      final repo = CommentsRepositoryDummy();
      final container = _container(repo: repo);
      addTearDown(container.dispose);
      final sub = container.listen(
        commentsNotifierProvider(fileMetaId),
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);
      await container.read(commentsNotifierProvider(fileMetaId).future);
      final notifier =
          container.read(commentsNotifierProvider(fileMetaId).notifier);
      final parent = await notifier.post('parent');

      final reply = await notifier.reply(parent.id, 'child');

      expect(reply.parentId, parent.id);
      final state = container.read(commentsNotifierProvider(fileMetaId));
      final parentAfter =
          state.value!.firstWhere((c) => c.id == parent.id);
      expect(parentAfter.replies.length, 1);
      expect(parentAfter.replies.first.body, 'child');
    });

    test('delete removes comment from state', () async {
      final repo = CommentsRepositoryDummy();
      final container = _container(repo: repo);
      addTearDown(container.dispose);
      final sub = container.listen(
        commentsNotifierProvider(fileMetaId),
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);
      await container.read(commentsNotifierProvider(fileMetaId).future);
      final notifier =
          container.read(commentsNotifierProvider(fileMetaId).notifier);
      final c = await notifier.post('to be deleted');

      await notifier.delete(c.id);

      final state = container.read(commentsNotifierProvider(fileMetaId));
      expect(state.value!.any((x) => x.id == c.id), isFalse);
    });

    test('post throws when no session user', () async {
      final repo = CommentsRepositoryDummy();
      final container = _container(repo: repo, user: null);
      addTearDown(container.dispose);
      await container.read(commentsNotifierProvider(fileMetaId).future);

      expect(
        () => container
            .read(commentsNotifierProvider(fileMetaId).notifier)
            .post('nope'),
        throwsA(isA<StateError>()),
      );
    });
  });

  test('post via notifier persists a FmComment with author from session',
      () async {
    final repo = CommentsRepositoryDummy();
    final container = _container(repo: repo);
    addTearDown(container.dispose);
    await container.read(commentsNotifierProvider(fileMetaId).future);

    final c = await container
        .read(commentsNotifierProvider(fileMetaId).notifier)
        .post('roundtrip');
    expect(c, isA<FmComment>());
    expect(c.author.id, '626');
  });
}
