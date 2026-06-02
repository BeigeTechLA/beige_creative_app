import 'dart:io';

import 'package:beige_creative_app/core/firebase/analytics_events.dart';
import 'package:beige_creative_app/core/firebase/crashlytics_breadcrumbs.dart';
import 'package:beige_creative_app/core/firebase/crashlytics_keys.dart';
import 'package:beige_creative_app/core/firebase/telemetry_client.dart';
import 'package:beige_creative_app/config/env.dart';
import 'package:beige_creative_app/features/profile/domain/repositories/profile_files_repository.dart';
import 'package:beige_creative_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:beige_creative_app/features/profile/presentation/providers/my_profile_providers.dart';
import 'package:beige_creative_app/features/profile/presentation/providers/profile_details_providers.dart';
import 'package:beige_creative_app/features/profile/presentation/providers/profile_files_providers.dart';
import 'package:beige_creative_app/model_class/edit_profile_model.dart';
import 'package:beige_creative_app/model_class/myprofile_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFilesRepo implements ProfileFilesRepository {
  int fetchCount = 0;
  int deleteCount = 0;
  int? lastDeletedId;

  List<CrewFile> resume = const [];
  List<CrewFile> certs = const [];
  List<CrewFile> featured = const [];
  List<CrewFile> portfolio = const [];

  MyProfileData _data() {
    final base = MyProfileData.fromJson(const {});
    return MyProfileData(
      stats: base.stats,
      equipmentOwnership: base.equipmentOwnership,
      bio: 'sample bio',
      primaryRole: base.primaryRole,
      crewMemberId: 42,
      firstName: 'Alice',
      lastName: 'Doe',
      email: 'alice@example.com',
      phoneNumber: base.phoneNumber,
      location: 'NYC',
      workingDistance: 'Upto 10 Miles',
      yearsOfExperience: 3,
      hourlyRate: '55',
      isAvailable: 1,
      availability: base.availability,
      featuredWorkFiles: featured,
      skills: base.skills,
      socialMediaLinks: const {
        'facebook': 'https://fb.com/a',
        'instagram': 'https://ig.com/a',
      },
      crewMemberFiles: const [],
      portfolioLinks: portfolio,
      certificateFiles: certs,
      resumeFiles: resume,
      profileImageUrl: '',
      user: base.user,
    );
  }

  @override
  Future<MyProfileData> fetchProfile() async {
    fetchCount++;
    return _data();
  }

  @override
  Future<void> uploadResume(File file) async {}
  @override
  Future<void> uploadCertificate(File file) async {}
  @override
  Future<void> uploadFeaturedWork({
    required String title,
    required List<String> tags,
    required List<File> files,
  }) async {}

  @override
  Future<void> deleteFile(int id) async {
    deleteCount++;
    lastDeletedId = id;
  }
}

class _FakeProfileRepo implements ProfileRepository {
  int updateSocialCount = 0;
  int addPortfolioCount = 0;
  int editPortfolioCount = 0;
  int uploadPhotoCount = 0;
  List<Map<String, String>>? lastSocialPayload;
  List<Map<String, dynamic>>? lastPortfolioPayload;
  Map<String, dynamic>? lastEditPayload;
  String? lastCrewMemberId;

  bool throwOnUpdateSocial = false;
  bool throwOnUploadPhoto = false;

  @override
  Future<EditProfileModel> fetchEditProfile() async =>
      EditProfileModel.fromJson(const {});

  @override
  Future<void> updateProfile(Map<String, dynamic> body) async {}

  @override
  Future<Map<String, int>> fetchRoles() async => const {};

  @override
  Future<Map<String, int>> fetchSkills() async => const {};

  @override
  Future<String> uploadPhoto(File file, {String? crewMemberId}) async {
    uploadPhotoCount++;
    lastCrewMemberId = crewMemberId;
    if (throwOnUploadPhoto) throw Exception('photo failed');
    return 'uploads/${file.path.split('/').last}';
  }

  @override
  Future<void> updateSocialLinks(List<Map<String, String>> links) async {
    updateSocialCount++;
    lastSocialPayload = links;
    if (throwOnUpdateSocial) throw Exception('boom');
  }

  @override
  Future<void> addPortfolioLinks(List<Map<String, dynamic>> links) async {
    addPortfolioCount++;
    lastPortfolioPayload = links;
  }

  @override
  Future<void> editPortfolioLink({
    required int id,
    required String url,
    required String platform,
    required String title,
  }) async {
    editPortfolioCount++;
    lastEditPayload = {
      'id': id,
      'url': url,
      'platform': platform,
      'title': title,
    };
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

Future<void> _drain(bool Function() done) async {
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

  ProviderContainer make({
    _FakeFilesRepo? files,
    _FakeProfileRepo? profile,
    _RecordingTelemetry? telemetry,
  }) {
    final c = ProviderContainer(
      overrides: [
        profileFilesRepositoryProvider.overrideWithValue(
          files ?? _FakeFilesRepo(),
        ),
        profileRepositoryProvider.overrideWithValue(
          profile ?? _FakeProfileRepo(),
        ),
        if (telemetry != null)
          telemetryClientProvider.overrideWithValue(telemetry),
      ],
    );
    return c;
  }

  test('refresh hydrates profile + social links from API map', () async {
    final filesRepo = _FakeFilesRepo();
    final c = make(files: filesRepo);
    addTearDown(c.dispose);
    c.listen(myProfileNotifierProvider, (_, _) {});
    await _drain(() => !c.read(myProfileNotifierProvider).isLoading);
    expect(filesRepo.fetchCount, 1);
    final s = c.read(myProfileNotifierProvider);
    expect(s.profile?.firstName, 'Alice');
    expect(s.socialLinks, hasLength(2));
    expect(s.socialLinks.any((m) => m['name'] == 'Facebook'), isTrue);
    expect(s.socialLinks.any((m) => m['name'] == 'Instagram'), isTrue);
  });

  test('uploadPhoto passes crewMemberId through repo', () async {
    final profileRepo = _FakeProfileRepo();
    final telemetry = _RecordingTelemetry();
    final c = make(profile: profileRepo, telemetry: telemetry);
    addTearDown(c.dispose);
    c.listen(myProfileNotifierProvider, (_, _) {});
    await _drain(() => !c.read(myProfileNotifierProvider).isLoading);
    final ok = await c
        .read(myProfileNotifierProvider.notifier)
        .uploadPhoto(File('/tmp/x.png'), source: ProfilePhotoSource.gallery);
    expect(ok, isTrue);
    expect(profileRepo.uploadPhotoCount, 1);
    expect(profileRepo.lastCrewMemberId, '42');
    final hits = telemetry.events
        .where((e) => e.name == AnalyticsEvents.profilePhotoUploaded)
        .toList();
    expect(hits, hasLength(1));
    expect(hits.single.parameters, {'source': 'gallery'});

    expect(keys, [
      (key: CrashlyticsKeys.featureArea, value: 'profile.upload.photo'),
    ]);
    expect(logs, [
      'profile.upload.photo.start',
      'profile.upload.photo.success',
    ]);
  });

  test('uploadPhoto failure does not emit profile_photo_uploaded', () async {
    final profileRepo = _FakeProfileRepo()..throwOnUploadPhoto = true;
    final telemetry = _RecordingTelemetry();
    final c = make(profile: profileRepo, telemetry: telemetry);
    addTearDown(c.dispose);
    c.listen(myProfileNotifierProvider, (_, _) {});
    await _drain(() => !c.read(myProfileNotifierProvider).isLoading);

    final ok = await c
        .read(myProfileNotifierProvider.notifier)
        .uploadPhoto(File('/tmp/x.png'), source: ProfilePhotoSource.camera);
    expect(ok, isFalse);
    expect(
      telemetry.events.where(
        (e) => e.name == AnalyticsEvents.profilePhotoUploaded,
      ),
      isEmpty,
    );

    expect(keys, [
      (key: CrashlyticsKeys.featureArea, value: 'profile.upload.photo'),
    ]);
    expect(logs, [
      'profile.upload.photo.start',
      'profile.upload.photo.failure',
    ]);
  });

  test('saveSocialLinksToApi posts payload + signals sheet dismiss', () async {
    final profileRepo = _FakeProfileRepo();
    final c = make(profile: profileRepo);
    addTearDown(c.dispose);
    c.listen(myProfileNotifierProvider, (_, _) {});
    await _drain(() => !c.read(myProfileNotifierProvider).isLoading);
    final before = c.read(myProfileNotifierProvider).dismissSheetSignal;
    await c.read(myProfileNotifierProvider.notifier).saveSocialLinksToApi();
    expect(profileRepo.updateSocialCount, 1);
    expect(profileRepo.lastSocialPayload, isNotNull);
    expect(
      c.read(myProfileNotifierProvider).dismissSheetSignal,
      greaterThan(before),
    );
  });

  test('saveSocialLinksToApi surfaces toast on empty list', () async {
    final c = make();
    addTearDown(c.dispose);
    c.listen(myProfileNotifierProvider, (_, _) {});
    await _drain(() => !c.read(myProfileNotifierProvider).isLoading);
    // Clear hydrated links first.
    c.read(myProfileNotifierProvider.notifier).mutableSocialLinks.clear();
    c.read(myProfileNotifierProvider.notifier).commitSocial();
    await c.read(myProfileNotifierProvider.notifier).saveSocialLinksToApi();
    expect(
      c.read(myProfileNotifierProvider).toastMessage,
      'Add at least one link',
    );
  });

  test('editPortfolioLinkApi posts payload + signals sheet dismiss', () async {
    final profileRepo = _FakeProfileRepo();
    final c = make(profile: profileRepo);
    addTearDown(c.dispose);
    c.listen(myProfileNotifierProvider, (_, _) {});
    await _drain(() => !c.read(myProfileNotifierProvider).isLoading);
    final before = c.read(myProfileNotifierProvider).dismissSheetSignal;
    final ok = await c
        .read(myProfileNotifierProvider.notifier)
        .editPortfolioLinkApi(
          id: 7,
          url: 'https://youtu.be/x',
          platform: 'youtube',
          title: 'YouTube',
        );
    expect(ok, isTrue);
    expect(profileRepo.editPortfolioCount, 1);
    expect(profileRepo.lastEditPayload?['id'], 7);
    expect(
      c.read(myProfileNotifierProvider).dismissSheetSignal,
      greaterThan(before),
    );
  });

  test('deletePortfolioFile clears matching id + refreshes', () async {
    final filesRepo = _FakeFilesRepo();
    final c = make(files: filesRepo);
    addTearDown(c.dispose);
    c.listen(myProfileNotifierProvider, (_, _) {});
    await _drain(() => !c.read(myProfileNotifierProvider).isLoading);
    final notifier = c.read(myProfileNotifierProvider.notifier);
    notifier.mutablePortfolioLinks.add({
      'id': '99',
      'name': 'YouTube',
      'url': 'https://youtu.be/x',
      'icon': 'icon',
    });
    notifier.commitPortfolio();
    await notifier.deletePortfolioFile(99);
    expect(filesRepo.deleteCount, 1);
    expect(filesRepo.lastDeletedId, 99);
    expect(notifier.mutablePortfolioLinks.any((e) => e['id'] == '99'), isFalse);
  });
}
