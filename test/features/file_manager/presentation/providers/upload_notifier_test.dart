import 'dart:io';

import 'package:beige_creative_app/features/file_manager/domain/models/fm_folder_key.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_phase.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_upload_policy.dart';
import 'package:beige_creative_app/features/file_manager/domain/repositories/upload_repository.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/upload_notifier.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/upload_repository_provider.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/upload_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:beige_creative_app/features/file_manager/presentation/providers/file_manager_repository_provider.dart';

class MockUploadRepository extends Mock implements UploadRepository {}

class FakeFile extends Fake implements File {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  late MockUploadRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockUploadRepository();
    container = ProviderContainer(
      overrides: [
        useDummyFileManagerProvider.overrideWith((ref) => true),
        uploadRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('UploadNotifier', () {
    test('initial state is idle', () {
      final state = container.read(uploadNotifierProvider);
      expect(state.status, UploadBatchStatus.idle);
      expect(state.items, isEmpty);
      expect(state.isUploading, isFalse);
    });

    test('startUpload executes policies, storage PUT, and confirmation', () async {
      final item = const UploadTaskItem(
        id: '1',
        name: 'test.jpg',
        localPath: '/tmp/test.jpg',
        remoteFilePath: 'ws/test.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 2048,
      );

      when(() => mockRepo.getUploadPolicies(any())).thenAnswer(
        (_) async => [
          const FmUploadPolicy(
            filepath: 'ws/test.jpg',
            uploadUrl: 'https://storage.googleapis.com/ws/test.jpg',
            headers: {'Content-Type': 'image/jpeg'},
          ),
        ],
      );

      when(
        () => mockRepo.uploadFileToStorage(
          uploadUrl: any(named: 'uploadUrl'),
          file: any(named: 'file'),
          headers: any(named: 'headers'),
          method: any(named: 'method'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((call) async {
        final onProgress = call.namedArguments[#onProgress] as void Function(int, int)?;
        onProgress?.call(2048, 2048);
      });

      when(() => mockRepo.confirmUploadBatch(any())).thenAnswer((_) async {});

      final success = await container.read(uploadNotifierProvider.notifier).startUpload(
        items: [item],
        folderKey: const FmFolderKey(externalId: 'ws', phase: FmPhase.pre),
      );

      expect(success, isTrue);
      final finalState = container.read(uploadNotifierProvider);
      expect(finalState.status, UploadBatchStatus.completed);
      expect(finalState.uploadedCount, 1);
      expect(finalState.overallProgress, 1.0);

      verify(() => mockRepo.getUploadPolicies(any())).called(1);
      verify(() => mockRepo.confirmUploadBatch(any())).called(1);
    });
  });
}
