import 'package:beige_creative_app/features/file_manager/data/sources/file_ops_remote_source.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_phase.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late FileOpsRemoteSource source;
  late MockDio dio;
  late Map<String, dynamic> response;
  late Map<String, dynamic> body;

  setUp(() {
    dio = MockDio();
    final client = MockDioClient();
    when(() => client.dio).thenReturn(dio);
    source = FileOpsRemoteSource(client);
    response = {
      'success': true,
      'data': {'url': 'https://example.com/folder.zip', 'expiresIn': 60},
    };
    when(
      () => dio.post<dynamic>(
        'external-file-manager/folder-download-url',
        data: any(named: 'data'),
      ),
    ).thenAnswer((call) async {
      body = call.namedArguments[#data] as Map<String, dynamic>;
      return Response<dynamic>(
        requestOptions: RequestOptions(
          path: 'external-file-manager/folder-download-url',
        ),
        data: response,
      );
    });
  });

  test('whole workspace sends externalId only and parses signed URL', () async {
    final result = await source.folderDownloadUrl(externalId: '42');
    expect(body, {'externalId': '42'});
    expect(result.url, 'https://example.com/folder.zip');
    expect(result.expiresAt, isNotNull);
  });

  test('phase root sends externalId + phase', () async {
    await source.folderDownloadUrl(
      externalId: '42',
      phase: FmPhase.post,
    );
    expect(body, {
      'externalId': '42',
      'phase': 'post',
    });
  });

  test('nested folder sends externalId + phase + path', () async {
    await source.folderDownloadUrl(
      externalId: '42',
      phase: FmPhase.post,
      path: 'Edits/Version 1',
    );
    expect(body, {
      'externalId': '42',
      'phase': 'post',
      'path': 'Edits/Version 1',
    });
  });

  test('common-event folder sends externalId + path', () async {
    await source.folderDownloadUrl(
      externalId: 'event_new_common_1788171403257',
      phase: FmPhase.root,
      path: 'Rachana DevCP2',
    );
    expect(body, {
      'externalId': 'event_new_common_1788171403257',
      'path': 'Rachana DevCP2',
    });
  });

  test('unsuccessful envelope cannot return a download URL', () async {
    response['success'] = false;
    await expectLater(
      source.folderDownloadUrl(externalId: '42'),
      throwsStateError,
    );
  });
}
