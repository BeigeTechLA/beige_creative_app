import 'package:beige_creative_app/features/file_manager/data/sources/folder_browse_remote_source.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_folder_key.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_node.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_phase.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockDio dio;
  late FolderBrowseRemoteSource source;
  final requests = <(String, Map<String, dynamic>?)>[];
  var payload = <String, dynamic>{};

  setUp(() {
    requests.clear();
    payload = {'folders': <dynamic>[], 'files': <dynamic>[]};
    dio = MockDio();
    final client = MockDioClient();
    when(() => client.dio).thenReturn(dio);
    source = FolderBrowseRemoteSource(client);
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((invocation) async {
      final path = invocation.positionalArguments.first as String;
      requests.add((
        path,
        invocation.namedArguments[#queryParameters] as Map<String, dynamic>?,
      ));
      return Response<dynamic>(
        requestOptions: RequestOptions(path: path),
        data: {'success': true, 'data': payload},
      );
    });
  });

  test(
    'workspace entry uses detail; root children use scoped contents',
    () async {
      payload = {
        'folders': [
          {'name': 'Creator'},
        ],
        'files': <dynamic>[],
      };
      final root = await source.open(const FmFolderKey(externalId: '42'));
      expect(requests.single, ('external-file-manager/workspace/42', null));
      final child = (root.items.single as FmFolder).nextKey!;
      final contents = await source.open(child);
      expect(requests.last.$1, 'external-file-manager/workspace/42/files');
      expect(requests.last.$2, {'phase': 'root', 'path': 'Creator'});
      expect(contents.key, child);
      expect(
        (contents.items.single as FmFolder).nextKey!.path,
        'Creator/Creator',
      );
    },
  );

  for (final phase in [FmPhase.pre, FmPhase.post]) {
    test('${phase.name} entry uses files endpoint with phase', () async {
      final key = FmFolderKey(externalId: '42', phase: phase);
      final contents = await source.open(key);
      expect(requests.single.$1, 'external-file-manager/workspace/42/files');
      expect(requests.single.$2, {'phase': phase.apiValue});
      expect(contents.key, key);
    });
  }

  test(
    'nested navigation retains request context when response omits it',
    () async {
      payload = {
        'folders': [
          {'name': 'Version1'},
        ],
        'files': <dynamic>[],
      };
      const key = FmFolderKey(
        externalId: '42',
        phase: FmPhase.post,
        path: 'Edits/Revisions',
      );
      final contents = await source.open(key);
      final child = (contents.items.single as FmFolder).nextKey!;
      expect(child, key.child('Version1'));
      payload = {
        'folders': <dynamic>[],
        'files': [
          {
            'name': 'clip.mp4',
            'path': 'project/Post-Production/Edits/Revisions/Version1/clip.mp4',
          },
        ],
      };
      final leaf = await source.open(child);
      expect(requests.last.$1, 'external-file-manager/workspace/42/files');
      expect(requests.last.$2, {
        'phase': 'post',
        'path': 'Edits/Revisions/Version1',
      });
      expect(leaf.items.single, isA<FmFile>());
      expect(leaf.items.single.name, 'clip.mp4');
    },
  );

  test('explicit response context takes precedence over fallback', () async {
    payload = {
      'phase': 'pre',
      'path': '',
      'folders': [
        {'name': 'Briefs'},
      ],
    };
    final contents = await source.open(
      const FmFolderKey(externalId: '42', phase: FmPhase.post, path: 'Old'),
    );
    expect(
      contents.key,
      const FmFolderKey(externalId: '42', phase: FmPhase.pre),
    );
    expect((contents.items.single as FmFolder).nextKey!.path, 'Briefs');
  });
}
