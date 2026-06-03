import 'dart:io';

import 'package:beige_creative_app/core/firebase/analytics_events.dart';
import 'package:beige_creative_app/core/firebase/crashlytics_breadcrumbs.dart';
import 'package:beige_creative_app/core/firebase/crashlytics_keys.dart';
import 'package:beige_creative_app/core/firebase/telemetry_client.dart';
import 'package:beige_creative_app/config/env.dart';
import 'package:beige_creative_app/features/profile/domain/repositories/profile_files_repository.dart';
import 'package:beige_creative_app/features/profile/presentation/providers/profile_details_providers.dart';
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

class _RecordingTelemetry implements TelemetryClient {
  final List<({String name, Map<String, Object>? parameters})> events =
      <({String name, Map<String, Object>? parameters})>[];

  @override
  Future<void> setUserIdentity({
    required String userId,
    String? userRole,
    String loginMethod = 'password',
  }) async {}

  @override
  Future<void> clearUserIdentity({bool emitLogoutEvent = false}) async {}

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    events.add((name: name, parameters: parameters));
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {}
}

Future<void> _drain(ProviderContainer container, bool Function() done) async {
  for (var i = 0; i < 20; i++) {
    if (done()) return;
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  setUpAll(() => Env.init(Environment.dev));

  final keys = <({String key, Object value})>[];
  final logs = <String>[];

  setUp(() {
    keys.clear();
    logs.clear();
    CrashlyticsBreadcrumbs.setCustomKey = (key, value) async {
      keys.add((key: key, value: value));
    };
    CrashlyticsBreadcrumbs.log = (message) async {
      logs.add(message);
    };
  });

  tearDown(CrashlyticsBreadcrumbs.resetForTesting);

  group('resumeNotifier', () {
    test('build → refresh → upload happy path', () async {
      final repo = _FakeRepo();
      final telemetry = _RecordingTelemetry();
      final container = ProviderContainer(
        overrides: [
          profileFilesRepositoryProvider.overrideWithValue(repo),
          telemetryClientProvider.overrideWithValue(telemetry),
        ],
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
      final hits = telemetry.events
          .where((e) => e.name == AnalyticsEvents.resumeUploaded)
          .toList();
      expect(hits, hasLength(1));
      expect(hits.single.parameters, {'file_count': 1});

      expect(keys, [
        (key: CrashlyticsKeys.featureArea, value: 'profile.upload.resume'),
      ]);
      expect(logs, [
        'profile.upload.resume.start',
        'profile.upload.resume.success',
      ]);
    });

    test('upload failure surfaces error', () async {
      final repo = _FakeRepo()..throwOnUpload = true;
      final telemetry = _RecordingTelemetry();
      final container = ProviderContainer(
        overrides: [
          profileFilesRepositoryProvider.overrideWithValue(repo),
          telemetryClientProvider.overrideWithValue(telemetry),
        ],
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
      expect(
        telemetry.events.where((e) => e.name == AnalyticsEvents.resumeUploaded),
        isEmpty,
      );

      expect(keys, [
        (key: CrashlyticsKeys.featureArea, value: 'profile.upload.resume'),
      ]);
      expect(logs, [
        'profile.upload.resume.start',
        'profile.upload.resume.failure',
      ]);
    });
  });

  group('certificatesNotifier', () {
    test('upload + delete', () async {
      final repo = _FakeRepo();
      final telemetry = _RecordingTelemetry();
      final container = ProviderContainer(
        overrides: [
          profileFilesRepositoryProvider.overrideWithValue(repo),
          telemetryClientProvider.overrideWithValue(telemetry),
        ],
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
      final hits = telemetry.events
          .where((e) => e.name == AnalyticsEvents.certificationsUploaded)
          .toList();
      expect(hits, hasLength(1));
      expect(hits.single.parameters, {'file_count': 1});

      final id = files.first.crewFilesId;
      final ok = await container
          .read(certificatesNotifierProvider.notifier)
          .delete(id);
      expect(ok, isTrue);
      expect(repo.lastDeletedId, id);
      expect(container.read(certificatesNotifierProvider).files, isEmpty);

      expect(keys, [
        (key: CrashlyticsKeys.featureArea, value: 'profile.upload.certifications'),
      ]);
      expect(logs, [
        'profile.upload.certifications.start',
        'profile.upload.certifications.success',
      ]);
    });

    test('upload failure does not emit certifications_uploaded', () async {
      final repo = _FakeRepo()..throwOnUpload = true;
      final telemetry = _RecordingTelemetry();
      final container = ProviderContainer(
        overrides: [
          profileFilesRepositoryProvider.overrideWithValue(repo),
          telemetryClientProvider.overrideWithValue(telemetry),
        ],
      );
      addTearDown(container.dispose);
      container.listen<FilesListState>(certificatesNotifierProvider, (_, _) {});
      await _drain(
        container,
        () => !container.read(certificatesNotifierProvider).isLoading,
      );

      final ok = await container
          .read(certificatesNotifierProvider.notifier)
          .upload(File('/tmp/c.png'));
      expect(ok, isFalse);
      expect(
        telemetry.events.where(
          (e) => e.name == AnalyticsEvents.certificationsUploaded,
        ),
        isEmpty,
      );

      expect(keys, [
        (key: CrashlyticsKeys.featureArea, value: 'profile.upload.certifications'),
      ]);
      expect(logs, [
        'profile.upload.certifications.start',
        'profile.upload.certifications.failure',
      ]);
    });
  });

  group('featuredWorkNotifier', () {
    test('upload bundles title + tags + files', () async {
      final repo = _FakeRepo();
      final telemetry = _RecordingTelemetry();
      final container = ProviderContainer(
        overrides: [
          profileFilesRepositoryProvider.overrideWithValue(repo),
          telemetryClientProvider.overrideWithValue(telemetry),
        ],
      );
      addTearDown(container.dispose);
      container.listen<FeaturedWorkState>(
        featuredWorkNotifierProvider,
        (_, _) {},
      );
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
      final hits = telemetry.events
          .where((e) => e.name == AnalyticsEvents.featuredWorkUploaded)
          .toList();
      expect(hits, hasLength(1));
      expect(hits.single.parameters, {'file_count': 2});

      expect(keys, [
        (key: CrashlyticsKeys.featureArea, value: 'profile.upload.featured_work'),
      ]);
      expect(logs, [
        'profile.upload.featured_work.start count=2',
        'profile.upload.featured_work.success count=2',
      ]);
    });

    test('upload failure does not emit featured_work_uploaded', () async {
      final repo = _FakeRepo()..throwOnUpload = true;
      final telemetry = _RecordingTelemetry();
      final container = ProviderContainer(
        overrides: [
          profileFilesRepositoryProvider.overrideWithValue(repo),
          telemetryClientProvider.overrideWithValue(telemetry),
        ],
      );
      addTearDown(container.dispose);
      container.listen<FeaturedWorkState>(
        featuredWorkNotifierProvider,
        (_, _) {},
      );
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
      expect(ok, isFalse);
      expect(
        telemetry.events.where(
          (e) => e.name == AnalyticsEvents.featuredWorkUploaded,
        ),
        isEmpty,
      );

      expect(keys, [
        (key: CrashlyticsKeys.featureArea, value: 'profile.upload.featured_work'),
      ]);
      expect(logs, [
        'profile.upload.featured_work.start count=2',
        'profile.upload.featured_work.failure count=2',
      ]);
    });

    test('deleteMany iterates ids', () async {
      final repo = _FakeRepo();
      final container = ProviderContainer(
        overrides: [profileFilesRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container.listen<FeaturedWorkState>(
        featuredWorkNotifierProvider,
        (_, _) {},
      );
      await _drain(
        container,
        () => !container.read(featuredWorkNotifierProvider).isLoading,
      );
      await container
          .read(featuredWorkNotifierProvider.notifier)
          .upload(
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

  group('profileDetailsViewNotifier', () {
    test('build → refresh hydrates profile + clears loading', () async {
      final repo = _FakeRepo();
      final container = ProviderContainer(
        overrides: [profileFilesRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container.listen<ProfileDetailsViewState>(
        profileDetailsViewProvider,
        (_, _) {},
      );
      await _drain(
        container,
        () => !container.read(profileDetailsViewProvider).isLoading,
      );

      final s = container.read(profileDetailsViewProvider);
      expect(s.isLoading, isFalse);
      expect(s.profile, isNotNull);
      expect(s.errorMessage, isNull);
      expect(repo.fetchCount, 1);
    });

    test('refresh failure surfaces errorMessage and clears loading',
        () async {
      final repo = _FakeRepo()..throwOnFetch = true;
      final container = ProviderContainer(
        overrides: [profileFilesRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container.listen<ProfileDetailsViewState>(
        profileDetailsViewProvider,
        (_, _) {},
      );
      await _drain(
        container,
        () => container.read(profileDetailsViewProvider).errorMessage != null,
      );

      final s = container.read(profileDetailsViewProvider);
      expect(s.isLoading, isFalse);
      expect(s.profile, isNull);
      expect(s.errorMessage, 'Failed to load profile');
    });

    test('selectTab updates selectedTab without re-fetching', () async {
      final repo = _FakeRepo();
      final container = ProviderContainer(
        overrides: [profileFilesRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container.listen<ProfileDetailsViewState>(
        profileDetailsViewProvider,
        (_, _) {},
      );
      await _drain(
        container,
        () => !container.read(profileDetailsViewProvider).isLoading,
      );
      final fetchBefore = repo.fetchCount;

      container.read(profileDetailsViewProvider.notifier).selectTab(2);

      expect(container.read(profileDetailsViewProvider).selectedTab, 2);
      expect(repo.fetchCount, fetchBefore);
    });
  });
}
