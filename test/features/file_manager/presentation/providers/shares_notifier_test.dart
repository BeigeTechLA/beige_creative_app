import 'dart:async';

import 'package:beige_creative_app/features/file_manager/domain/models/fm_folder_key.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_share.dart';
import 'package:beige_creative_app/features/file_manager/domain/repositories/shares_repository.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/shares_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSharesRepository implements SharesRepository {
  List<FmShareRecipient> shares = [];
  bool failList = false;
  bool failCreate = false;
  bool failRevoke = false;
  Completer<void>? createGate;
  int creates = 0;
  @override
  Future<List<FmShareRecipient>> list(FmShareTarget target) async {
    if (failList) throw StateError('offline');
    return List.of(shares);
  }

  @override
  Future<FmShareRecipient> create(
    FmShareTarget target, {
    String? email,
    required FmSharePermission permission,
    String message = '',
  }) async {
    creates++;
    await createGate?.future;
    if (failCreate) throw StateError('denied');
    final created = FmShareRecipient(
      email: email,
      permission: permission,
      shareToken: 'shared_token',
      shareLink: 'https://example.com/shared',
    );
    shares.add(
      FmShareRecipient(
        shareId: shares.length + 1,
        email: email,
        permission: permission,
        shareToken: created.shareToken,
      ),
    );
    return created;
  }

  @override
  Future<void> revoke(int shareId) async {
    if (failRevoke) throw StateError('denied');
    shares.removeWhere((s) => s.shareId == shareId);
  }

  @override
  Future<List<FmShareAccessLog>> accessLogs(FmShareTarget target) async => [];
}

void main() {
  const target = FmShareTarget(
    key: FmFolderKey(externalId: '5406'),
    name: 'Project',
  );
  const existing = FmShareRecipient(
    shareId: 1,
    permission: FmSharePermission.canDownload,
    shareToken: 'shared_token',
  );
  late FakeSharesRepository repo;
  late ProviderContainer container;
  final provider = sharesNotifierProvider(target);
  SharesState state() => container.read(provider);
  SharesNotifier notifier() => container.read(provider.notifier);

  setUp(() async {
    repo = FakeSharesRepository();
    repo.shares = [existing];
    container = ProviderContainer(
      overrides: [sharesRepositoryProvider.overrideWithValue(repo)],
    );
    container.listen(provider, (_, _) {});
    await Future<void>.delayed(Duration.zero);
  });
  tearDown(() => container.dispose());

  test('failed invite preserves existing recipients', () async {
    repo.failCreate = true;
    expect(
      await notifier().create(
        email: 'new@example.com',
        permission: FmSharePermission.canDownload,
      ),
      isFalse,
    );
    expect(state().shares, [existing]);
    expect(state().error, isNotNull);
    expect(state().busy, isFalse);
  });
  test(
    'same token public and email grants remain separate; ID and URL merge',
    () async {
      await notifier().create(
        email: 'new@example.com',
        permission: FmSharePermission.canDownload,
      );
      expect(state().shares.length, 2);
      final emailShare = state().shares.last;
      expect(emailShare.email, 'new@example.com');
      expect(emailShare.shareId, 2);
      expect(emailShare.shareLink, 'https://example.com/shared');
      expect(state().shares.first.isPublic, isTrue);
    },
  );
  test(
    'refresh failure after create keeps link without inventing revoke ID',
    () async {
      repo.failList = true;
      expect(
        await notifier().create(
          email: 'new@example.com',
          permission: FmSharePermission.canDownload,
        ),
        isTrue,
      );
      expect(state().shares.length, 2);
      expect(state().shares.last.shareId, isNull);
      expect(state().shares.last.shareLink, isNotNull);
      expect(state().error, contains('Share created'));
    },
  );
  test('failed revoke retains access; successful retry removes it', () async {
    repo.failRevoke = true;
    await notifier().revoke(existing);
    expect(state().shares, [existing]);
    repo.failRevoke = false;
    await notifier().revoke(existing);
    expect(state().shares, isEmpty);
  });
  test('duplicate taps create only one request', () async {
    repo.createGate = Completer<void>();
    final pending = notifier().create(
      email: 'new@example.com',
      permission: FmSharePermission.canDownload,
    );
    expect(state().busy, isTrue);
    expect(
      await notifier().create(
        email: 'new@example.com',
        permission: FmSharePermission.canDownload,
      ),
      isFalse,
    );
    expect(repo.creates, 1);
    repo.createGate!.complete();
    await pending;
    expect(state().busy, isFalse);
  });
}
