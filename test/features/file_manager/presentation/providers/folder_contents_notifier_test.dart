import 'package:beige_creative_app/features/file_manager/domain/models/file_type.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_node.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_page.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_tab.dart';
import 'package:beige_creative_app/features/file_manager/domain/repositories/file_manager_repository.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/file_manager_repository_provider.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/file_manager_root_state.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/folder_contents_notifier.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements FileManagerRepository {
  _Repo(this.children);
  final List<FmNode> children;

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
  }) async => FmPage<FmNode>(items: children, nextCursor: null);

  @override
  Future<String> getShareLink({required nodeId, required kind}) async =>
      throw UnimplementedError();
  @override
  Future<void> deleteNode({required nodeId, required kind}) async =>
      throw UnimplementedError();
  @override
  Future<String> downloadFile({
    required fileId,
    void Function(double)? onProgress,
    CancelToken? cancelToken,
  }) async => throw UnimplementedError();
}

void main() {
  test('FolderContentsNotifier loads then filters by search', () async {
    final repo = _Repo([
      FmFolder(id: 'sub', name: 'Pre Production', fileCount: 2),
      FmFile(
        id: 'fil_pdf',
        name: 'Brief.pdf',
        type: FileType.pdf,
        sizeBytes: 100,
        downloadUrl: 'https://x/brief.pdf',
      ),
      FmFile(
        id: 'fil_doc',
        name: 'Script.docx',
        type: FileType.doc,
        sizeBytes: 100,
        downloadUrl: 'https://x/script.docx',
      ),
    ]);

    final container = ProviderContainer(overrides: [
      fileManagerRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);

    const folderId = 'fld';
    final sub = container.listen(
      folderContentsNotifierProvider(folderId),
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    final notifier =
        container.read(folderContentsNotifierProvider(folderId).notifier);
    await notifier.refresh();
    var state = container.read(folderContentsNotifierProvider(folderId));
    expect(state.status, FmListStatus.ready);
    expect(state.items.length, 3);

    notifier.setSearchQuery('pdf');
    state = container.read(folderContentsNotifierProvider(folderId));
    expect(state.visibleItems.map((n) => n.id), ['fil_pdf']);

    notifier.setSearchQuery('');
    state = container.read(folderContentsNotifierProvider(folderId));
    expect(state.visibleItems.length, 3);
  });
}
