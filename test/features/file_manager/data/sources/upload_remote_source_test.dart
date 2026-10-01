import 'package:beige_creative_app/features/file_manager/data/sources/upload_remote_source.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_upload_item.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late UploadRemoteSource source;
  late MockDio apiDio;
  late MockDio storageDio;

  setUp(() {
    apiDio = MockDio();
    storageDio = MockDio();
    final client = MockDioClient();
    when(() => client.dio).thenReturn(apiDio);
    source = UploadRemoteSource(client, storageDio);
  });

  group('UploadRemoteSource', () {
    test('getUploadPolicies sends correct payload and maps response', () async {
      when(
        () => apiDio.post<dynamic>(
          'external-file-manager/upload-policies/batch',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(
            path: 'external-file-manager/upload-policies/batch',
          ),
          data: {
            'success': true,
            'data': {
              'items': [
                {
                  'filepath': 'workspace_123/Pre-Production/photo.jpg',
                  'uploadUrl': 'https://storage.googleapis.com/upload-url',
                  'method': 'PUT',
                  'headers': {'Content-Type': 'image/jpeg'},
                }
              ]
            }
          },
        ),
      );

      final policies = await source.getUploadPolicies([
        const FmUploadItem(
          filepath: 'workspace_123/Pre-Production/photo.jpg',
          fileContentType: 'image/jpeg',
          fileSize: 1024,
        ),
      ]);

      expect(policies.length, 1);
      expect(policies.first.filepath, 'workspace_123/Pre-Production/photo.jpg');
      expect(policies.first.uploadUrl, 'https://storage.googleapis.com/upload-url');
      expect(policies.first.method, 'PUT');
    });

    test('confirmUploads sends batch confirmation payload', () async {
      Map<String, dynamic>? sentBody;
      when(
        () => apiDio.post<dynamic>(
          'external-file-manager/files-uploaded/batch',
          data: any(named: 'data'),
        ),
      ).thenAnswer((call) async {
        sentBody = call.namedArguments[#data] as Map<String, dynamic>;
        return Response<dynamic>(
          requestOptions: RequestOptions(
            path: 'external-file-manager/files-uploaded/batch',
          ),
          data: {'success': true},
        );
      });

      await source.confirmUploads([
        const FmUploadItem(
          filepath: 'workspace_123/Pre-Production/photo.jpg',
          fileContentType: 'image/jpeg',
          fileSize: 1024,
          fileName: 'photo.jpg',
        ),
      ]);

      expect(sentBody, isNotNull);
      expect(sentBody!['items'], isList);
      expect((sentBody!['items'] as List).length, 1);
    });
  });
}
