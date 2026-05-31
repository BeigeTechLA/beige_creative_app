import 'dart:io';

import 'package:beige_creative_app/config/env.dart';
import 'package:beige_creative_app/features/profile/domain/repositories/profile_files_repository.dart';
import 'package:beige_creative_app/features/profile/presentation/providers/profile_files_providers.dart';
import 'package:beige_creative_app/model_class/myprofile_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements ProfileFilesRepository {
  int fetchCount = 0;
  int uploadResumeCount = 0;
  int uploadCertCount = 0;
  int uploadFeaturedCount = 0;
  int deleteCount = 0;
  String? lastFeaturedTitle;
  List<String>? lastFeaturedTags;
  int? lastDeletedId;

  List<CrewFile> resume = const [];
  List<CrewFile> certs = const [];
  List<CrewFile> featured = const [];

  bool throwOnFetch = false;
  bool throwOnUpload = false;

  MyProfileData _data() {
    final base = MyProfileData.fromJson(const {});
    return MyProfileData(
      stats: base.stats,
      equipmentOwnership: base.equipmentOwnership,
      bio: base.bio,
      primaryRole: base.primaryRole,
      crewMemberId: base.crewMemberId,
      firstName: base.firstName,
      lastName: base.lastName,
      email: base.email,
      phoneNumber: base.phoneNumber,
      location: base.location,
      workingDistance: base.workingDistance,
      yearsOfExperience: base.yearsOfExperience,
      hourlyRate: base.hourlyRate,
      isAvailable: base.isAvailable,
      availability: base.availability,
      featuredWorkFiles: featured,
      skills: base.skills,
      socialMediaLinks: base.socialMediaLinks,
      crewMemberFiles: base.crewMemberFiles,
      portfolioLinks: base.portfolioLinks,
      certificateFiles: certs,
      resumeFiles: resume,
      profileImageUrl: base.profileImageUrl,
      user: base.user,
    );
  }

  @override
  Future<MyProfileData> fetchProfile() async {
    fetchCount++;
    if (throwOnFetch) throw Exception('fetch failed');
    return _data();
  }

  @override
  Future<void> uploadResume(File file) async {
    uploadResumeCount++;
    if (throwOnUpload) throw Exception('upload failed');
    resume = [
      ...resume,
      CrewFile(
        fileType: 'pdf',
        filePath: file.path,
        tag: '',
        crewFilesId: 100 + uploadResumeCount,
        title: '',
      ),
    ];
  }

  @override
  Future<void> uploadCertificate(File file) async {
    uploadCertCount++;
    if (throwOnUpload) throw Exception('upload failed');
    certs = [
      ...certs,
      CrewFile(
        fileType: 'img',
        filePath: file.path,
        tag: '',
        crewFilesId: 200 + uploadCertCount,
        title: '',
      ),
    ];
  }

  @override
  Future<void> uploadFeaturedWork({
    required String title,
    required List<String> tags,
    required List<File> files,
  }) async {
    uploadFeaturedCount++;
    lastFeaturedTitle = title;
    lastFeaturedTags = tags;
    if (throwOnUpload) throw Exception('upload failed');
    featured = [
      ...featured,
      for (int i = 0; i < files.length; i++)
        CrewFile(
          fileType: 'img',
          filePath: files[i].path,
          tag: tags.join(','),
          crewFilesId: 300 + featured.length + i,
          title: title,
        ),
    ];
  }

  @override
  Future<void> deleteFile(int id) async {
    deleteCount++;
    lastDeletedId = id;
    resume = resume.where((c) => c.crewFilesId != id).toList();
    certs = certs.where((c) => c.crewFilesId != id).toList();
    featured = featured.where((c) => c.crewFilesId != id).toList();
  }
}

Future<void> _drain(
  ProviderContainer container,
  bool Function() done,
) async {
  for (var i = 0; i < 20; i++) {
    if (done()) return;
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  setUpAll(() => Env.init(Environment.dev));

  group('resumeNotifier', () {
    test('build → refresh → upload happy path', () async {
      final repo = _FakeRepo();
      final container = ProviderContainer(
        overrides: [profileFilesRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container.listen<FilesListState>(resumeNotifierProvider, (_, _) {});
      await _drain(
        container,
        () => !container.read(resumeNotifierProvider).isLoading,
      );
      expect(repo.fetchCount, 1);
      expect(container.read(resumeNotifierProvider).files, isEmpty);

      final ok = await container
          .read(resumeNotifierProvider.notifier)
          .upload(File('/tmp/cv.pdf'));
      expect(ok, isTrue);
      expect(repo.uploadResumeCount, 1);
      expect(container.read(resumeNotifierProvider).files, hasLength(1));
      expect(
        container.read(resumeNotifierProvider).files.first.filePath,
        '/tmp/cv.pdf',
      );
    });

    test('upload failure surfaces error', () async {
      final repo = _FakeRepo()..throwOnUpload = true;
      final container = ProviderContainer(
        overrides: [profileFilesRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container.listen<FilesListState>(resumeNotifierProvider, (_, _) {});
      await _drain(
        container,
        () => !container.read(resumeNotifierProvider).isLoading,
      );
      final ok = await container
          .read(resumeNotifierProvider.notifier)
          .upload(File('/tmp/cv.pdf'));
      expect(ok, isFalse);
      expect(container.read(resumeNotifierProvider).errorMessage, isNotNull);
    });
  });

  group('certificatesNotifier', () {
    test('upload + delete', () async {
      final repo = _FakeRepo();
      final container = ProviderContainer(
        overrides: [profileFilesRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container.listen<FilesListState>(certificatesNotifierProvider, (_, _) {});
      await _drain(
        container,
        () => !container.read(certificatesNotifierProvider).isLoading,
      );

      await container
          .read(certificatesNotifierProvider.notifier)
          .upload(File('/tmp/c.png'));
      expect(repo.uploadCertCount, 1);
      final files = container.read(certificatesNotifierProvider).files;
      expect(files, hasLength(1));

      final id = files.first.crewFilesId;
      final ok = await container
          .read(certificatesNotifierProvider.notifier)
          .delete(id);
      expect(ok, isTrue);
      expect(repo.lastDeletedId, id);
      expect(container.read(certificatesNotifierProvider).files, isEmpty);
    });
  });

  group('featuredWorkNotifier', () {
    test('upload bundles title + tags + files', () async {
      final repo = _FakeRepo();
      final container = ProviderContainer(
        overrides: [profileFilesRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container.listen<FeaturedWorkState>(featuredWorkNotifierProvider, (_, _) {});
      await _drain(
        container,
        () => !container.read(featuredWorkNotifierProvider).isLoading,
      );
      final ok = await container
          .read(featuredWorkNotifierProvider.notifier)
          .upload(
            title: 'Wedding shoot',
            tags: ['wedding', 'outdoor'],
            files: [File('/tmp/a.jpg'), File('/tmp/b.jpg')],
          );
      expect(ok, isTrue);
      expect(repo.lastFeaturedTitle, 'Wedding shoot');
      expect(repo.lastFeaturedTags, ['wedding', 'outdoor']);
      expect(container.read(featuredWorkNotifierProvider).files, hasLength(2));
    });

    test('deleteMany iterates ids', () async {
      final repo = _FakeRepo();
      final container = ProviderContainer(
        overrides: [profileFilesRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container.listen<FeaturedWorkState>(featuredWorkNotifierProvider, (_, _) {});
      await _drain(
        container,
        () => !container.read(featuredWorkNotifierProvider).isLoading,
      );
      await container.read(featuredWorkNotifierProvider.notifier).upload(
        title: 'A',
        tags: const [],
        files: [File('/tmp/x.jpg'), File('/tmp/y.jpg')],
      );
      final ids = container
          .read(featuredWorkNotifierProvider)
          .files
          .map((c) => c.crewFilesId)
          .toList();
      expect(ids, hasLength(2));
      final ok = await container
          .read(featuredWorkNotifierProvider.notifier)
          .deleteMany(ids);
      expect(ok, isTrue);
      expect(repo.deleteCount, 2);
      expect(container.read(featuredWorkNotifierProvider).files, isEmpty);
    });
  });
}
