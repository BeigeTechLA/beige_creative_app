import 'package:beige_creative_app/features/file_manager/data/dtos/fm_file_node_dto.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/file_type.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_node.dart';
import 'package:beige_creative_app/features/file_manager/domain/models/fm_signed_url.dart';
import 'package:beige_creative_app/features/file_manager/domain/repositories/file_ops_repository.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/file_image_preview_provider.dart';
import 'package:beige_creative_app/features/file_manager/presentation/providers/file_ops_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements FileOpsRepository {}

void main() {
  test('image extensions accept mixed case, paths, and signed URLs', () {
    for (final value in [
      'photo.JPG',
      'folder/a.heic',
      'scan.TIFF',
      'https://host/photo.webp?token=123#preview',
      'file.avif',
      'file.svg',
    ]) {
      expect(isImageFile(value), isTrue, reason: value);
      expect(FileTypeX.fromExtension(value), FileType.image);
    }
    for (final value in [
      null,
      '',
      'jpg',
      'folder.png/document.pdf',
      'a.jpg.mp4',
    ]) {
      expect(isImageFile(value), isFalse, reason: '$value');
    }
  });

  test('image extension overrides generic backend MIME', () {
    final file = FmFileNodeDto.fromJson({
      'name': 'photo.JPG',
      'contentType': 'application/octet-stream',
    });
    expect(file.type, FileType.image);
  });

  late _Repo repo;
  late ProviderContainer container;
  setUp(() {
    repo = _Repo();
    container = ProviderContainer(
      overrides: [fileOpsRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
  });

  FmFile file({
    String name = 'photo.JPG',
    String? preview,
    String? path,
    String download = '',
  }) => FmFile(
    id: '1',
    name: name,
    type: FileType.other,
    sizeBytes: 1,
    downloadUrl: download,
    previewUrl: preview,
    filepath: path,
  );

  test('provided preview avoids signed URL request', () async {
    final result = await container.read(
      fileImagePreviewProvider(
        file(preview: 'https://host/thumb.jpg', path: 'project/photo.JPG'),
      ).future,
    );
    expect(result, 'https://host/thumb.jpg');
    verifyNever(() => repo.viewUrl(any()));
  });

  test('image path obtains a signed view URL', () async {
    when(
      () => repo.viewUrl('project/photo.JPG'),
    ).thenAnswer((_) async => const FmSignedUrl(url: 'https://host/signed'));
    final result = await container.read(
      fileImagePreviewProvider(file(path: 'project/photo.JPG')).future,
    );
    expect(result, 'https://host/signed');
    verify(() => repo.viewUrl('project/photo.JPG')).called(1);
  });

  test('legacy image can use download URL; non-images do not load', () async {
    expect(
      await container.read(
        fileImagePreviewProvider(
          file(download: 'https://host/photo.jpg'),
        ).future,
      ),
      'https://host/photo.jpg',
    );
    expect(
      await container.read(
        fileImagePreviewProvider(
          file(name: 'document.pdf', path: 'project/document.pdf'),
        ).future,
      ),
      isNull,
    );
    verifyNever(() => repo.viewUrl(any()));
  });

  test(
    'scroll away and return with recreated file reuses signed URL',
    () async {
      when(() => repo.viewUrl('project/photo.JPG')).thenAnswer(
        (_) async => const FmSignedUrl(url: 'https://host/signed?token=one'),
      );
      final first = fileImagePreviewProvider(file(path: 'project/photo.JPG'));
      final subscription = container.listen(first, (_, _) {});
      await container.read(first.future);
      subscription.close();
      await container.pump();

      final returned = fileImagePreviewProvider(
        file(path: 'project/photo.JPG'),
      );
      expect(returned, first);
      final returnedSubscription = container.listen(returned, (_, _) {});
      addTearDown(returnedSubscription.close);
      expect(container.read(returned).value, 'https://host/signed?token=one');
      await container.read(returned.future);
      verify(() => repo.viewUrl('project/photo.JPG')).called(1);
    },
  );

  test('failed request is not retained after scrolling away', () async {
    when(
      () => repo.viewUrl('project/photo.JPG'),
    ).thenThrow(Exception('offline'));
    final provider = fileImagePreviewProvider(file(path: 'project/photo.JPG'));
    final subscription = container.listen(provider, (_, _) {});
    await expectLater(container.read(provider.future), throwsException);
    subscription.close();
    await container.pump();
    when(
      () => repo.viewUrl('project/photo.JPG'),
    ).thenAnswer((_) async => const FmSignedUrl(url: 'https://host/recovered'));
    expect(await container.read(provider.future), 'https://host/recovered');
    verify(() => repo.viewUrl('project/photo.JPG')).called(2);
  });

  test('expired URL is not retained after scrolling away', () async {
    when(() => repo.viewUrl('project/photo.JPG')).thenAnswer(
      (_) async => FmSignedUrl(
        url: 'https://host/expired',
        expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
      ),
    );
    final provider = fileImagePreviewProvider(file(path: 'project/photo.JPG'));
    final subscription = container.listen(provider, (_, _) {});
    await container.read(provider.future);
    subscription.close();
    await container.pump();
    await container.read(provider.future);
    verify(() => repo.viewUrl('project/photo.JPG')).called(2);
  });

  test('image byte cache ignores signatures but distinguishes versions', () {
    final first = file(
      path: 'project/photo.JPG',
      preview: 'https://host/a?sig=1',
    );
    final second = file(
      path: 'project/photo.JPG',
      preview: 'https://host/a?sig=2',
    );
    expect(fileImageCacheKey(first), fileImageCacheKey(second));
    final revised = FmFile(
      id: first.id,
      name: first.name,
      type: first.type,
      sizeBytes: first.sizeBytes,
      downloadUrl: '',
      filepath: first.filepath,
      version: 2,
    );
    expect(fileImageCacheKey(first), isNot(fileImageCacheKey(revised)));
    expect(
      fileImageCacheKey(first),
      isNot(fileImageCacheKey(file(path: 'another/photo.JPG'))),
    );
  });
}
