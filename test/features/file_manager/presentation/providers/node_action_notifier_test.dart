import 'package:beige_creative_app/features/file_manager/domain/models/fm_node.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_page.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_tab.dart';
import 'package:beige_creative_app/features/file_manager/domain/repositories/file_manager_repository.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/file_manager_repository_provider.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/node_action_notifier.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/node_action_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements FileManagerRepository {
  int shareCalls = 0;
  int deleteCalls = 0;
  bool throwOnDelete = false;

  @override
  Future<FmPage<FmFolder>> listRoot({
    required FmTab tab,
    String? cursor,
    int limit = 20,
  }) async => const FmPage<FmFolder>(items: []);

  @override
  Future<FmPage<FmNode>> listFolder({
    required String folderId,
    String? cursor,
    int limit = 20,
  }) async => const FmPage<FmNode>(items: []);

  @override
  Future<String> getShareLink({
    required String nodeId,
    required FmNodeKind kind,
  }) async {
    shareCalls++;
    return 'https://share/$nodeId';
  }

  @override
  Future<void> deleteNode({
    required String nodeId,
    required FmNodeKind kind,
  }) async {
    deleteCalls++;
    if (throwOnDelete) throw Exception('boom');
  }

  @override
  Future<String> downloadFile({
    required String fileId,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async => '/tmp/$fileId';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NodeActionNotifier', () {
    test('share writes URL to clipboard + emits success signal', () async {
      String? clipboardText;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboardText = (call.arguments as Map)['text'] as String?;
        }
        return null;
      });

      final repo = _Repo();
      final container = ProviderContainer(overrides: [
        fileManagerRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(container.dispose);
      final sub = container.listen(
        nodeActionNotifierProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      await container
          .read(nodeActionNotifierProvider.notifier)
          .share(nodeId: 'fld_1', kind: FmNodeKind.folder);

      expect(repo.shareCalls, 1);
      expect(clipboardText, 'https://share/fld_1');
      final state = container.read(nodeActionNotifierProvider);
      expect(state.sharingIds.isEmpty, isTrue);
      expect(state.lastSignal?.kind, FmActionSignalKind.shareCopied);
    });

    test('delete success emits deleted signal + returns true', () async {
      final repo = _Repo();
      final container = ProviderContainer(overrides: [
        fileManagerRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(container.dispose);
      final sub = container.listen(
        nodeActionNotifierProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      final ok = await container
          .read(nodeActionNotifierProvider.notifier)
          .delete(nodeId: 'fld_1', kind: FmNodeKind.folder);

      expect(ok, isTrue);
      expect(repo.deleteCalls, 1);
      final state = container.read(nodeActionNotifierProvider);
      expect(state.deletingIds.isEmpty, isTrue);
      expect(state.lastSignal?.kind, FmActionSignalKind.deleted);
    });

    test('delete failure emits error signal + returns false', () async {
      final repo = _Repo()..throwOnDelete = true;
      final container = ProviderContainer(overrides: [
        fileManagerRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(container.dispose);
      final sub = container.listen(
        nodeActionNotifierProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      final ok = await container
          .read(nodeActionNotifierProvider.notifier)
          .delete(nodeId: 'fld_2', kind: FmNodeKind.file);

      expect(ok, isFalse);
      final state = container.read(nodeActionNotifierProvider);
      expect(state.lastSignal?.kind, FmActionSignalKind.error);
    });
  });
}
