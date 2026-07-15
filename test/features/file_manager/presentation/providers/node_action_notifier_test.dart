import 'package:beige_creative_app/features/file_manager/domain/models/fm_copy_result.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_delete_result.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_phase.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_revision_action.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_revision_result.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_signed_url.dart';
import 'package:beige_creative_app/features/file_manager/domain/repositories/file_ops_repository.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/file_ops_repository_provider.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/node_action_notifier.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/node_action_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements FileOpsRepository {
  int viewCalls = 0;
  int downloadCalls = 0;
  int folderDownloadCalls = 0;
  int deleteCalls = 0;
  bool throwOnDelete = false;
  bool deleteSucceeds = true;

  @override
  Future<FmSignedUrl> viewUrl(String filepath) async {
    viewCalls++;
    return FmSignedUrl(url: 'https://view/$filepath');
  }

  @override
  Future<FmSignedUrl> downloadUrl(String filepath) async {
    downloadCalls++;
    return FmSignedUrl(url: 'https://download/$filepath');
  }

  @override
  Future<FmSignedUrl> folderDownloadUrl({
    required String externalId,
    FmPhase? phase,
    String? path,
  }) async {
    folderDownloadCalls++;
    return FmSignedUrl(url: 'https://zip/$externalId');
  }

  @override
  Future<FmDeleteResult> delete(String filepath) async {
    deleteCalls++;
    if (throwOnDelete) throw Exception('boom');
    return FmDeleteResult(deleted: deleteSucceeds, deletedCount: deleteSucceeds ? 1 : 0);
  }

  @override
  Future<FmCopyResult> copyFiles({
    required String externalId,
    required FmPhase phase,
    required String targetPath,
    required List<String> sourcePaths,
  }) async {
    return FmCopyResult(
      total: sourcePaths.length,
      successCount: sourcePaths.length,
      failedCount: 0,
      items: const [],
    );
  }

  @override
  Future<FmRevisionResult> reviewRevision({
    required String externalId,
    required String filepath,
    required FmRevisionAction action,
  }) async {
    return FmRevisionResult(action: action, versionNumber: 1);
  }
}

/// Stubs the platform-side plugins the notifier hands URLs to. We can't
/// actually launch a browser or open a share sheet in a unit test, so
/// we accept every method-channel call as success.
void _stubPlatformChannels() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  const urlLauncher = MethodChannel('plugins.flutter.io/url_launcher');
  messenger.setMockMethodCallHandler(urlLauncher, (call) async {
    if (call.method == 'canLaunch' || call.method == 'launch') return true;
    return null;
  });

  const urlLauncherAndroid = MethodChannel('plugins.flutter.io/url_launcher_android');
  messenger.setMockMethodCallHandler(urlLauncherAndroid, (call) async => true);

  const share = MethodChannel('dev.fluttercommunity.plus/share');
  messenger.setMockMethodCallHandler(share, (call) async => 'ok');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  _stubPlatformChannels();

  group('NodeActionNotifier', () {
    test('shareFile fetches view URL + emits shareCopied signal', () async {
      final repo = _Repo();
      final container = ProviderContainer(overrides: [
        fileOpsRepositoryProvider.overrideWithValue(repo),
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
          .shareFile(filepath: 'foo/bar.jpg');

      expect(repo.viewCalls, 1);
      final state = container.read(nodeActionNotifierProvider);
      expect(state.sharingIds.isEmpty, isTrue);
      expect(state.lastSignal?.kind, FmActionSignalKind.shareCopied);
    });

    test('downloadFile fetches download URL + emits downloaded signal',
        () async {
      final repo = _Repo();
      final container = ProviderContainer(overrides: [
        fileOpsRepositoryProvider.overrideWithValue(repo),
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
          .downloadFile('foo/bar.jpg');

      expect(repo.downloadCalls, 1);
      final state = container.read(nodeActionNotifierProvider);
      expect(state.downloadProgress, isEmpty);
      expect(state.lastSignal?.kind, FmActionSignalKind.downloaded);
    });

    test('delete success emits deleted signal + returns true', () async {
      final repo = _Repo();
      final container = ProviderContainer(overrides: [
        fileOpsRepositoryProvider.overrideWithValue(repo),
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
          .delete(filepath: 'fld_1/');

      expect(ok, isTrue);
      expect(repo.deleteCalls, 1);
      final state = container.read(nodeActionNotifierProvider);
      expect(state.deletingIds.isEmpty, isTrue);
      expect(state.lastSignal?.kind, FmActionSignalKind.deleted);
    });

    test('delete failure emits error signal + returns false', () async {
      final repo = _Repo()..throwOnDelete = true;
      final container = ProviderContainer(overrides: [
        fileOpsRepositoryProvider.overrideWithValue(repo),
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
          .delete(filepath: 'fld_2/');

      expect(ok, isFalse);
      final state = container.read(nodeActionNotifierProvider);
      expect(state.lastSignal?.kind, FmActionSignalKind.error);
    });
  });
}
