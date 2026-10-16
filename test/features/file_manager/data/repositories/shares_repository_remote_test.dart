import 'package:beige_creative_app/features/file_manager/data/repositories/shares_repository_remote.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_folder_key.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_phase.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_share.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  const target = FmShareTarget(
    key: FmFolderKey(externalId: '5406'),
    name: 'Project',
  );
  late SharesRepositoryRemote repo;
  late MockDio dio;
  late Map<String, dynamic> response;
  late Map<String, dynamic> body;
  late String path;

  setUp(() {
    dio = MockDio();
    final client = MockDioClient();
    when(() => client.dio).thenReturn(dio);
    repo = SharesRepositoryRemote(client);
    response = {
      'success': true,
      'data': {
        'shareToken': 'shr_token',
        'shareUrl': 'https://dev.beige.app/shared/file-manager/shr_token',
        'message': null,
        'permission': 'view_download',
      },
    };
    Future<Response<dynamic>> capture(Invocation call) async {
      path = call.positionalArguments.first as String;
      body =
          (call.namedArguments[#data] ?? call.namedArguments[#queryParameters])
              as Map<String, dynamic>;
      return Response<dynamic>(
        requestOptions: RequestOptions(path: path),
        data: response,
      );
    }

    when(
      () => dio.post<dynamic>(any(), data: any(named: 'data')),
    ).thenAnswer(capture);
    when(
      () => dio.delete<dynamic>(any(), data: any(named: 'data')),
    ).thenAnswer(capture);
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(capture);
  });

  test(
    'public share uses supplied contract and permits missing shareId',
    () async {
      final share = await repo.create(
        target,
        permission: FmSharePermission.canDownload,
      );
      expect(path, 'external-file-manager/share');
      expect(body, {
        'resourceType': 'workspace',
        'externalId': '5406',
        'accessMode': 'anyone_with_link',
        'permission': 'view_download',
        'message': '',
      });
      expect(share.shareId, isNull);
      expect(share.isPublic, isTrue);
      expect(share.shareLink, contains('shr_token'));
    },
  );

  for (final permission in FmSharePermission.values) {
    test('email share serializes ${permission.apiValue} and message', () async {
      (response['data'] as Map)['permission'] = permission.apiValue;
      final share = await repo.create(
        target,
        email: ' user@example.com ',
        permission: permission,
        message: 'Review this',
      );
      expect(body['accessMode'], 'email_only');
      expect(body['email'], 'user@example.com');
      expect(body['permission'], permission.apiValue);
      expect(body['message'], 'Review this');
      expect(share.email, 'user@example.com');
    });
  }

  test('phase root GET uses workspace externalId and phase', () async {
    response['data'] = {
      'shares': [
        {
          'shareId': 110,
          'accessMode': 'anyone_with_link',
          'permission': 'view_download',
        },
      ],
    };
    final shares = await repo.list(
      const FmShareTarget(
        key: FmFolderKey(externalId: '4833', phase: FmPhase.pre),
        name: 'Pre',
      ),
    );
    expect(body, {
      'resourceType': 'folder',
      'externalId': '4833',
      'phase': 'pre',
    });
    expect(shares.single.shareId, 110);
  });

  test('revoke uses numeric shareId in DELETE body', () async {
    response = {'success': true, 'message': 'Share revoked successfully'};
    await repo.revoke(110);
    expect(path, 'external-file-manager/share');
    expect(body, {'shareId': 110});
  });

  test('failed envelope does not report revocation success', () async {
    response = {'success': false, 'message': 'Not allowed'};
    await expectLater(repo.revoke(110), throwsStateError);
  });

  test('unsupported GET shape is an error, not an empty access list', () async {
    response['data'] = {'unknown': []};
    await expectLater(repo.list(target), throwsFormatException);
  });

  test('access logs use same target query and dedicated endpoint', () async {
    response['data'] = {
      'logs': [
        {
          'action': 'download',
          'email': 'user@example.com',
          'createdAt': '2026-09-21T10:00:00Z',
        },
      ],
    };
    final logs = await repo.accessLogs(target);
    expect(path, 'external-file-manager/share/access-logs');
    expect(body, {'resourceType': 'workspace', 'externalId': '5406'});
    expect(logs.single.action, 'download');
    expect(logs.single.createdAt, isNotNull);
  });

  test('nested scope is rejected before network request', () async {
    const nested = FmShareTarget(
      key: FmFolderKey(externalId: '5406', phase: FmPhase.post, path: 'Edits'),
      name: 'Edits',
    );
    await expectLater(
      repo.create(nested, permission: FmSharePermission.canDownload),
      throwsStateError,
    );
    verifyNever(() => dio.post<dynamic>(any(), data: any(named: 'data')));
  });

  test('malformed returned URL cannot be copied', () async {
    (response['data'] as Map)['shareUrl'] = 'not-a-url';
    await expectLater(
      repo.create(target, permission: FmSharePermission.canDownload),
      throwsFormatException,
    );
  });

  test('public upload permission is rejected before network request', () async {
    await expectLater(
      repo.create(target, permission: FmSharePermission.canUploadAndDownload),
      throwsArgumentError,
    );
    verifyNever(() => dio.post<dynamic>(any(), data: any(named: 'data')));
  });
}
