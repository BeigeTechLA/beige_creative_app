import 'dart:io';

import 'package:beige_creative_app/core/firebase/analytics_events.dart';
import 'package:beige_creative_app/core/firebase/crashlytics_breadcrumbs.dart';
import 'package:beige_creative_app/core/firebase/crashlytics_keys.dart';
import 'package:beige_creative_app/core/firebase/telemetry_client.dart';
import 'package:beige_creative_app/config/env.dart';
import 'package:beige_creative_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:beige_creative_app/features/profile/presentation/providers/profile_details_providers.dart';
import 'package:beige_creative_app/model_class/edit_profile_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProfileRepo implements ProfileRepository {
  int fetchCount = 0;
  int updateCount = 0;
  int fetchRolesCount = 0;
  int fetchSkillsCount = 0;
  int uploadPhotoCount = 0;
  Map<String, dynamic>? lastBody;

  EditProfileModel response = EditProfileModel.fromJson(const {
    'first_name': 'A',
    'last_name': 'B',
    'email': 'a@b.com',
    'phone_number': '123',
    'location': 'loc',
    'working_distance': 'Upto 10 Miles',
    'primary_role': '1,2',
    'years_of_experience': 4,
    'hourly_rate': 50,
    'bio': 'bio',
  });

  Map<String, int> roleMap = const {'Videographer': 1, 'Photographer': 2};
  Map<String, int> skillMap = const {'Editing': 10, 'Color Grading': 11};

  bool throwOnFetch = false;
  bool throwOnUpdate = false;
  bool throwOnUploadPhoto = false;

  @override
  Future<EditProfileModel> fetchEditProfile() async {
    fetchCount++;
    if (throwOnFetch) throw Exception('fetch failed');
    return response;
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> body) async {
    updateCount++;
    lastBody = body;
    if (throwOnUpdate) throw Exception('update failed');
  }

  @override
  Future<Map<String, int>> fetchRoles() async {
    fetchRolesCount++;
    return roleMap;
  }

  @override
  Future<Map<String, int>> fetchSkills() async {
    fetchSkillsCount++;
    return skillMap;
  }

  @override
  Future<String> uploadPhoto(File file, {String? crewMemberId}) async {
    uploadPhotoCount++;
    if (throwOnUploadPhoto) throw Exception('photo failed');
    return 'uploads/${file.path.split('/').last}';
  }

  @override
  Future<void> updateSocialLinks(List<Map<String, String>> links) async {}

  @override
  Future<void> addPortfolioLinks(List<Map<String, dynamic>> links) async {}

  @override
  Future<void> editPortfolioLink({
    required int id,
    required String url,
    required String platform,
    required String title,
  }) async {}
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

  group('editPersonalNotifier', () {
    test('build → load hydrates initial + workingDistance', () async {
      final repo = _FakeProfileRepo();
      final container = ProviderContainer(
        overrides: [profileRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container.listen(editPersonalNotifierProvider, (_, _) {});
      await _drain(
        () => !container.read(editPersonalNotifierProvider).isLoadingInitial,
      );
      expect(repo.fetchCount, 1);
      final s = container.read(editPersonalNotifierProvider);
      expect(s.initial?.firstName, 'A');
      expect(s.workingDistance, 'Upto 10 Miles');
    });

    test('submit posts full body + flags savedOk', () async {
      final repo = _FakeProfileRepo();
      final container = ProviderContainer(
        overrides: [profileRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container.listen(editPersonalNotifierProvider, (_, _) {});
      await _drain(
        () => !container.read(editPersonalNotifierProvider).isLoadingInitial,
      );
      final ok = await container
          .read(editPersonalNotifierProvider.notifier)
          .submit(
            firstName: 'A',
            lastName: 'B',
            email: 'a@b.com',
            phone: '123',
            location: 'loc',
            experience: '5',
            hourlyRate: '60',
            bio: 'updated',
            age: '30',
          );
      expect(ok, isTrue);
      expect(repo.updateCount, 1);
      expect(repo.lastBody?['first_name'], 'A');
      expect(repo.lastBody?['bio'], 'updated');
      expect(container.read(editPersonalNotifierProvider).savedOk, isTrue);
    });

    test('submit rejects empty name', () async {
      final repo = _FakeProfileRepo();
      final container = ProviderContainer(
        overrides: [profileRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container.listen(editPersonalNotifierProvider, (_, _) {});
      await _drain(
        () => !container.read(editPersonalNotifierProvider).isLoadingInitial,
      );
      final ok = await container
          .read(editPersonalNotifierProvider.notifier)
          .submit(
            firstName: '',
            lastName: '',
            email: 'a@b.com',
            phone: '',
            location: 'loc',
            experience: '5',
            hourlyRate: '60',
            bio: '',
            age: '',
          );
      expect(ok, isFalse);
      expect(repo.updateCount, 0);
      expect(
        container.read(editPersonalNotifierProvider).validationMessage,
        'Enter full name',
      );
    });
  });

  group('enterProfessionalNotifier', () {
    test(
      'load hydrates initial + roles + skills + decoded selection',
      () async {
        final repo = _FakeProfileRepo();
        final container = ProviderContainer(
          overrides: [profileRepositoryProvider.overrideWithValue(repo)],
        );
        addTearDown(container.dispose);
        container.listen(enterProfessionalNotifierProvider, (_, _) {});
        await _drain(
          () => !container
              .read(enterProfessionalNotifierProvider)
              .isLoadingInitial,
        );
        final s = container.read(enterProfessionalNotifierProvider);
        expect(repo.fetchCount, 1);
        expect(repo.fetchRolesCount, 1);
        expect(repo.fetchSkillsCount, 1);
        expect(s.selectedRoles, containsAll(['Videographer', 'Photographer']));
        expect(s.roleList, containsAll(['Videographer', 'Photographer']));
      },
    );

    test('submit posts mapped role + skill ids', () async {
      final repo = _FakeProfileRepo();
      final container = ProviderContainer(
        overrides: [profileRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container.listen(enterProfessionalNotifierProvider, (_, _) {});
      await _drain(
        () =>
            !container.read(enterProfessionalNotifierProvider).isLoadingInitial,
      );
      container
          .read(enterProfessionalNotifierProvider.notifier)
          .setSelectedSkills(['Editing', 'Color Grading']);
      final ok = await container
          .read(enterProfessionalNotifierProvider.notifier)
          .submit(experience: '5', hourlyRate: '60', bio: 'b');
      expect(ok, isTrue);
      expect(repo.lastBody?['primary_role'], [1, 2]);
      expect(repo.lastBody?['skills'], [10, 11]);
    });

    test('submit rejects empty role selection', () async {
      final repo = _FakeProfileRepo()
        ..response = EditProfileModel.fromJson(const {});
      final container = ProviderContainer(
        overrides: [profileRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container.listen(enterProfessionalNotifierProvider, (_, _) {});
      await _drain(
        () =>
            !container.read(enterProfessionalNotifierProvider).isLoadingInitial,
      );
      final ok = await container
          .read(enterProfessionalNotifierProvider.notifier)
          .submit(experience: '5', hourlyRate: '60', bio: '');
      expect(ok, isFalse);
      expect(repo.updateCount, 0);
      expect(
        container.read(enterProfessionalNotifierProvider).validationMessage,
        'Please select role',
      );
    });

    test('uploadPhoto emits profile_photo_uploaded on success', () async {
      final repo = _FakeProfileRepo();
      final telemetry = _RecordingTelemetry();
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repo),
          telemetryClientProvider.overrideWithValue(telemetry),
        ],
      );
      addTearDown(container.dispose);
      container.listen(enterProfessionalNotifierProvider, (_, _) {});
      await _drain(
        () =>
            !container.read(enterProfessionalNotifierProvider).isLoadingInitial,
      );

      final ok = await container
          .read(enterProfessionalNotifierProvider.notifier)
          .uploadPhoto(
            File('/tmp/profile.png'),
            source: ProfilePhotoSource.camera,
          );
      expect(ok, isTrue);
      expect(repo.uploadPhotoCount, 1);
      final hits = telemetry.events
          .where((e) => e.name == AnalyticsEvents.profilePhotoUploaded)
          .toList();
      expect(hits, hasLength(1));
      expect(hits.single.parameters, {'source': 'camera'});

      expect(keys, [
        (key: CrashlyticsKeys.featureArea, value: 'profile.upload.photo'),
      ]);
      expect(logs, [
        'profile.upload.photo.start',
        'profile.upload.photo.success',
      ]);
    });

    test('uploadPhoto failure does not emit profile_photo_uploaded', () async {
      final repo = _FakeProfileRepo()..throwOnUploadPhoto = true;
      final telemetry = _RecordingTelemetry();
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repo),
          telemetryClientProvider.overrideWithValue(telemetry),
        ],
      );
      addTearDown(container.dispose);
      container.listen(enterProfessionalNotifierProvider, (_, _) {});
      await _drain(
        () =>
            !container.read(enterProfessionalNotifierProvider).isLoadingInitial,
      );

      final ok = await container
          .read(enterProfessionalNotifierProvider.notifier)
          .uploadPhoto(
            File('/tmp/profile.png'),
            source: ProfilePhotoSource.gallery,
          );
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
  });
}
