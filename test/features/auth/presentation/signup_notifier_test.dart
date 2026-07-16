import 'dart:io';

import 'package:beige_creative_app/core/firebase/analytics_events.dart';
import 'package:beige_creative_app/core/firebase/telemetry_client.dart';
import 'package:beige_creative_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:beige_creative_app/features/auth/presentation/providers/signup_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class _FakeAuthRepo implements AuthRepository {
  Step1Payload? capturedStep1;
  Step2Payload? capturedStep2;
  Step3Payload? capturedStep3;
  int step1Result = 42;
  Object? throwOnStep1;
  Object? throwOnStep2;
  Object? throwOnStep3;
  Object? throwOnFetch;
  List<LookupOption> roles = const [
    LookupOption(id: 1, name: 'Director of Photography'),
    LookupOption(id: 2, name: 'Editor'),
  ];
  List<LookupOption> skills = const [
    LookupOption(id: 10, name: 'Lighting'),
    LookupOption(id: 11, name: 'Color Grading'),
  ];
  List<LookupOption> equipments = const [
    LookupOption(id: 100, name: 'RED Komodo'),
  ];

  @override
  Future<int> registerStep1(Step1Payload payload) async {
    capturedStep1 = payload;
    final err = throwOnStep1;
    if (err != null) throw err;
    return step1Result;
  }

  @override
  Future<void> registerStep2(Step2Payload payload) async {
    capturedStep2 = payload;
    final err = throwOnStep2;
    if (err != null) throw err;
  }

  @override
  Future<void> registerStep3(Step3Payload payload) async {
    capturedStep3 = payload;
    final err = throwOnStep3;
    if (err != null) throw err;
  }

  @override
  Future<List<LookupOption>> fetchRoles() async {
    final err = throwOnFetch;
    if (err != null) throw err;
    return roles;
  }

  @override
  Future<List<LookupOption>> fetchSkills() async => skills;

  @override
  Future<List<LookupOption>> searchEquipments(String query) async => equipments;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async =>
      throw UnimplementedError();
  @override
  Future<void> requestPasswordReset(String email) async {}
  @override
  Future<void> verifyResetOtp({
    required String email,
    required String otp,
  }) async {}
  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
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

ProviderContainer _container(
  _FakeAuthRepo repo, {
  _RecordingTelemetry? telemetry,
}) {
  final c = ProviderContainer(
    overrides: [
      signupRepositoryProvider.overrideWithValue(repo),
      if (telemetry != null)
        telemetryClientProvider.overrideWithValue(telemetry),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('SignupNotifier.submitStep1 validation', () {
    test('rejects mismatched passwords', () async {
      final c = _container(_FakeAuthRepo());
      final ok = await c.read(signupNotifierProvider.notifier).submitStep1(
            firstName: 'A',
            lastName: 'B',
            email: 'a@b.com',
            phone: '1234567890',
            password: 'one',
            confirmPassword: 'two',
            location: 'Mumbai',
          );
      expect(ok, isFalse);
      expect(
        c.read(signupNotifierProvider).errorMessage,
        'Password and Confirm Password do not match',
      );
    });

    test('rejects invalid email', () async {
      final c = _container(_FakeAuthRepo());
      final ok = await c.read(signupNotifierProvider.notifier).submitStep1(
            firstName: 'A',
            lastName: 'B',
            email: 'not-an-email',
            phone: '1234567890',
            password: 'pw',
            confirmPassword: 'pw',
            location: 'Mumbai',
          );
      expect(ok, isFalse);
      expect(
        c.read(signupNotifierProvider).errorMessage,
        'Please enter a valid email address',
      );
    });

    test('rejects when terms not accepted', () async {
      final c = _container(_FakeAuthRepo());
      final ok = await c.read(signupNotifierProvider.notifier).submitStep1(
            firstName: 'A',
            lastName: 'B',
            email: 'a@b.com',
            phone: '1234567890',
            password: 'pw',
            confirmPassword: 'pw',
            location: 'Mumbai',
          );
      expect(ok, isFalse);
      expect(
        c.read(signupNotifierProvider).errorMessage,
        'Please accept Terms & Conditions',
      );
    });

    test('rejects when no profile image', () async {
      final c = _container(_FakeAuthRepo());
      c.read(signupNotifierProvider.notifier).setAcceptedTerms(true);
      final ok = await c.read(signupNotifierProvider.notifier).submitStep1(
            firstName: 'A',
            lastName: 'B',
            email: 'a@b.com',
            phone: '1234567890',
            password: 'pw',
            confirmPassword: 'pw',
            location: 'Mumbai',
          );
      expect(ok, isFalse);
      expect(
        c.read(signupNotifierProvider).errorMessage,
        'Please upload profile picture',
      );
    });
  });

  group('SignupNotifier.submitStep1 happy path', () {
    test('persists crew id + frozen step1 snapshot', () async {
      final repo = _FakeAuthRepo()..step1Result = 99;
      final c = _container(repo);
      final notifier = c.read(signupNotifierProvider.notifier);
      notifier.setProfileImage(File('/tmp/avatar.png'));
      notifier.setSelectedDistance('Upto 50 Miles');
      notifier.setAcceptedTerms(true);
      notifier.setCurrentLatLng(const LatLng(19.07, 72.87));

      final ok = await notifier.submitStep1(
        firstName: 'Ada',
        lastName: 'Lovelace',
        email: 'ada@example.com',
        phone: '9999999999',
        password: 'pw1234',
        confirmPassword: 'pw1234',
        location: 'Mumbai',
      );
      expect(ok, isTrue);
      expect(repo.capturedStep1?.firstName, 'Ada');
      expect(repo.capturedStep1?.workingDistance, 'Upto 50 Miles');
      final state = c.read(signupNotifierProvider);
      expect(state.crewMemberId, 99);
      expect(state.step1Success, isTrue);
      expect(state.firstName, 'Ada');
      expect(state.email, 'ada@example.com');
      expect(state.step1Progress, greaterThan(0));
      expect(state.errorMessage, isNull);
    });
  });

  group('SignupNotifier step 2 lookups + selections', () {
    test('loadStep2Lookups hydrates roles and skills', () async {
      final c = _container(_FakeAuthRepo());
      await c.read(signupNotifierProvider.notifier).loadStep2Lookups();
      final state = c.read(signupNotifierProvider);
      expect(state.roles.length, 2);
      expect(state.skills.length, 2);
      expect(state.isLoadingLookups, isFalse);
    });

    test('toggleRole + toggleSkill mutate selections', () async {
      final c = _container(_FakeAuthRepo());
      final notifier = c.read(signupNotifierProvider.notifier);
      notifier.toggleRole('Editor', selected: true);
      notifier.toggleSkill('Lighting', selected: true);
      expect(c.read(signupNotifierProvider).selectedRoles, ['Editor']);
      expect(c.read(signupNotifierProvider).selectedSkills, ['Lighting']);
      notifier.toggleRole('Editor', selected: false);
      expect(c.read(signupNotifierProvider).selectedRoles, isEmpty);
    });

    test('searchEquipments empty query clears suggestions', () async {
      final c = _container(_FakeAuthRepo());
      await c
          .read(signupNotifierProvider.notifier)
          .searchEquipments('   ');
      expect(c.read(signupNotifierProvider).equipmentSuggestions, isEmpty);
    });

    test('addEquipment + removeEquipment manage chips', () async {
      final c = _container(_FakeAuthRepo());
      final notifier = c.read(signupNotifierProvider.notifier);
      notifier.addEquipment('Tripod');
      notifier.addEquipment('Tripod'); // dedupe
      notifier.addEquipment('Boom mic');
      expect(
        c.read(signupNotifierProvider).selectedEquipments,
        ['Tripod', 'Boom mic'],
      );
      notifier.removeEquipment('Tripod');
      expect(
        c.read(signupNotifierProvider).selectedEquipments,
        ['Boom mic'],
      );
    });
  });

  group('SignupNotifier.submitStep2', () {
    test('rejects when crewMemberId missing', () async {
      final c = _container(_FakeAuthRepo());
      final ok = await c
          .read(signupNotifierProvider.notifier)
          .submitStep2(yearsOfExperience: '5', hourlyRate: '100', bio: 'hi');
      expect(ok, isFalse);
      expect(
        c.read(signupNotifierProvider).errorMessage,
        'Missing crew member id',
      );
    });

    test('happy path sends mapped ids', () async {
      final repo = _FakeAuthRepo();
      final c = _container(repo);
      final notifier = c.read(signupNotifierProvider.notifier);
      // Prime crewMemberId via step1 (using validation-bypassing setters).
      notifier.setProfileImage(File('/tmp/avatar.png'));
      notifier.setSelectedDistance('Upto 50 Miles');
      notifier.setAcceptedTerms(true);
      notifier.setCurrentLatLng(const LatLng(0, 0));
      await notifier.submitStep1(
        firstName: 'Ada',
        lastName: 'L',
        email: 'a@b.com',
        phone: '1',
        password: 'pw',
        confirmPassword: 'pw',
        location: 'Mumbai',
      );
      // Load lookups + select.
      await notifier.loadStep2Lookups();
      notifier.toggleRole('Editor', selected: true);
      notifier.toggleSkill('Lighting', selected: true);

      final ok = await notifier
          .submitStep2(yearsOfExperience: '5', hourlyRate: '100', bio: 'hi');
      expect(ok, isTrue);
      expect(repo.capturedStep2?.crewMemberId, 42);
      expect(repo.capturedStep2?.primaryRoleIds, [2]);
      expect(repo.capturedStep2?.skillIds, [10]);
      expect(repo.capturedStep2?.yearsOfExperience, 5);
      expect(repo.capturedStep2?.hourlyRate, 100.0);
      expect(c.read(signupNotifierProvider).step2Success, isTrue);
      expect(c.read(signupNotifierProvider).step2Progress, greaterThan(0));
    });
  });

  group('SignupNotifier step 3 mutators', () {
    test('setSocialLinks + removeSocialLinkAt', () {
      final c = _container(_FakeAuthRepo());
      final notifier = c.read(signupNotifierProvider.notifier);
      notifier.setSocialLinks([
        {'name': 'Instagram', 'url': 'insta.com/a'},
        {'name': 'TikTok', 'url': 'tiktok.com/a'},
      ]);
      expect(c.read(signupNotifierProvider).savedSocialLinks.length, 2);
      notifier.removeSocialLinkAt(0);
      expect(c.read(signupNotifierProvider).savedSocialLinks.length, 1);
      expect(
        c.read(signupNotifierProvider).savedSocialLinks.first['name'],
        'TikTok',
      );
    });

    test('setFeaturedProjects + removeFeaturedProjectAt keeps titles aligned',
        () {
      final c = _container(_FakeAuthRepo());
      final notifier = c.read(signupNotifierProvider.notifier);
      notifier.setFeaturedProjects(
        [
          [File('/tmp/a.jpg')],
          [File('/tmp/b.jpg'), File('/tmp/c.jpg')],
        ],
        ['Project A', 'Project B'],
      );
      notifier.removeFeaturedProjectAt(0);
      final state = c.read(signupNotifierProvider);
      expect(state.featuredProjects.length, 1);
      expect(state.featuredProjects.first.length, 2);
      expect(state.featuredProjectsTitles, ['Project B']);
    });

    test('addCertificate + removeCertificateAt', () {
      final c = _container(_FakeAuthRepo());
      final notifier = c.read(signupNotifierProvider.notifier);
      notifier.addCertificate(File('/tmp/cert1.pdf'));
      notifier.addCertificate(File('/tmp/cert2.pdf'));
      expect(c.read(signupNotifierProvider).certificateFiles.length, 2);
      notifier.removeCertificateAt(0);
      expect(c.read(signupNotifierProvider).certificateFiles.length, 1);
    });

    test('setResumeFile(null) clears the resume', () {
      final c = _container(_FakeAuthRepo());
      final notifier = c.read(signupNotifierProvider.notifier);
      notifier.setResumeFile(File('/tmp/cv.pdf'));
      expect(c.read(signupNotifierProvider).resumeFile, isNotNull);
      notifier.setResumeFile(null);
      expect(c.read(signupNotifierProvider).resumeFile, isNull);
    });

    test('seedStep3FromRoute fills carry-through but preserves crewMemberId',
        () async {
      final c = _container(_FakeAuthRepo()..step1Result = 99);
      final notifier = c.read(signupNotifierProvider.notifier);
      notifier.setProfileImage(File('/tmp/avatar.png'));
      notifier.setSelectedDistance('Upto 50 Miles');
      notifier.setAcceptedTerms(true);
      notifier.setCurrentLatLng(const LatLng(0, 0));
      await notifier.submitStep1(
        firstName: 'A',
        lastName: 'B',
        email: 'a@b.com',
        phone: '1',
        password: 'pw',
        confirmPassword: 'pw',
        location: 'L',
      );
      notifier.seedStep3FromRoute(
        crewMemberId: 12345, // should not overwrite 99
        primaryRole: 'DOP',
        experience: '5',
        hourlyRate: '100',
        bio: 'hi',
        skills: 'Lighting',
        equipments: 'RED',
        step2Progress: 60,
      );
      final state = c.read(signupNotifierProvider);
      expect(state.crewMemberId, 99);
      expect(state.primaryRoleDisplay, 'DOP');
      expect(state.hourlyRateDisplay, '100');
    });
  });

  group('SignupNotifier.submitStep3', () {
    test('rejects when crewMemberId missing', () async {
      final c = _container(_FakeAuthRepo());
      final ok =
          await c.read(signupNotifierProvider.notifier).submitStep3();
      expect(ok, isFalse);
      expect(
        c.read(signupNotifierProvider).errorMessage,
        'Missing crew member id',
      );
    });

    test('happy path captures multipart payload with platform keys + indexes',
        () async {
      final repo = _FakeAuthRepo()..step1Result = 7;
      final c = _container(repo);
      final notifier = c.read(signupNotifierProvider.notifier);
      // Prime crewMemberId via step1.
      notifier.setProfileImage(File('/tmp/a.png'));
      notifier.setSelectedDistance('Upto 50 Miles');
      notifier.setAcceptedTerms(true);
      notifier.setCurrentLatLng(const LatLng(0, 0));
      await notifier.submitStep1(
        firstName: 'A',
        lastName: 'B',
        email: 'a@b.com',
        phone: '1',
        password: 'pw',
        confirmPassword: 'pw',
        location: 'L',
      );

      notifier.setSocialLinks([
        {'name': 'Instagram', 'url': 'insta.com/a'},
      ]);
      notifier.setPortfolioLinks([
        {'name': 'Google Drive', 'url': 'drive.google.com/x'},
      ]);
      notifier.setFeaturedProjects(
        [
          [File('/tmp/p1a.jpg'), File('/tmp/p1b.jpg')],
          [File('/tmp/p2.jpg')],
        ],
        ['First', 'Second'],
      );
      notifier.addCertificate(File('/tmp/cert.pdf'));
      notifier.setResumeFile(File('/tmp/cv.pdf'));

      final ok = await notifier.submitStep3();
      expect(ok, isTrue);
      final payload = repo.capturedStep3;
      expect(payload, isNotNull);
      expect(payload!.crewMemberId, 7);
      expect(payload.socialMediaLinks, [
        {'platform': 'instagram', 'url': 'https://insta.com/a'},
      ]);
      expect(payload.portfolioLinks, [
        {'platform': 'google_drive', 'url': 'https://drive.google.com/x'},
      ]);
      expect(payload.featuredWork.length, 2);
      expect(payload.featuredWork.first['work_title'], 'First');
      expect(payload.certificationFiles.length, 1);
      expect(payload.resume?.path, '/tmp/cv.pdf');
      expect(payload.portfolio, isNull);
      expect(payload.recentWorkMediaFiles.length, 3);
      expect(payload.recentWorkMediaIndexes, [0, 0, 1]);
      expect(c.read(signupNotifierProvider).step3Success, isTrue);
    });

    test('surfaces repository error', () async {
      final repo = _FakeAuthRepo()..step1Result = 5;
      repo.throwOnStep3 = Exception('boom');
      final c = _container(repo);
      final notifier = c.read(signupNotifierProvider.notifier);
      notifier.setProfileImage(File('/tmp/a.png'));
      notifier.setSelectedDistance('Upto 50 Miles');
      notifier.setAcceptedTerms(true);
      notifier.setCurrentLatLng(const LatLng(0, 0));
      await notifier.submitStep1(
        firstName: 'A',
        lastName: 'B',
        email: 'a@b.com',
        phone: '1',
        password: 'pw',
        confirmPassword: 'pw',
        location: 'L',
      );
      final ok = await notifier.submitStep3();
      expect(ok, isFalse);
      expect(c.read(signupNotifierProvider).errorMessage, 'boom');
      expect(c.read(signupNotifierProvider).isSubmittingStep3, isFalse);
    });
  });

  group('SignupNotifier event emission (B1)', () {
    test('markSignupStarted emits signup_started once per flow', () async {
      final telemetry = _RecordingTelemetry();
      final c = _container(_FakeAuthRepo(), telemetry: telemetry);
      final notifier = c.read(signupNotifierProvider.notifier);

      notifier.markSignupStarted();
      notifier.markSignupStarted();
      notifier.markSignupStarted();

      final hits = telemetry.events
          .where((e) => e.name == AnalyticsEvents.signupStarted)
          .toList();
      expect(hits, hasLength(1));
      expect(hits.single.parameters, isNull);
      expect(c.read(signupNotifierProvider).signupStartedEmitted, isTrue);
    });

    test('reset() re-arms signupStarted for a fresh flow', () async {
      final telemetry = _RecordingTelemetry();
      final c = _container(_FakeAuthRepo(), telemetry: telemetry);
      final notifier = c.read(signupNotifierProvider.notifier);
      notifier.markSignupStarted();
      notifier.reset();
      notifier.markSignupStarted();
      final hits = telemetry.events
          .where((e) => e.name == AnalyticsEvents.signupStarted)
          .toList();
      expect(hits, hasLength(2));
    });

    test('submitStep3 success emits signup_completed with asset flags',
        () async {
      final repo = _FakeAuthRepo()..step1Result = 11;
      final telemetry = _RecordingTelemetry();
      final c = _container(repo, telemetry: telemetry);
      final notifier = c.read(signupNotifierProvider.notifier);
      // Prime crewMemberId via step1.
      notifier.setProfileImage(File('/tmp/a.png'));
      notifier.setSelectedDistance('Upto 50 Miles');
      notifier.setAcceptedTerms(true);
      notifier.setCurrentLatLng(const LatLng(0, 0));
      await notifier.submitStep1(
        firstName: 'A',
        lastName: 'B',
        email: 'a@b.com',
        phone: '1',
        password: 'pw',
        confirmPassword: 'pw',
        location: 'L',
      );
      notifier.setSocialLinks([
        {'name': 'Instagram', 'url': 'insta.com/a'},
        {'name': 'TikTok', 'url': 'tt.com/a'},
      ]);
      notifier.setFeaturedProjects([
        [File('/tmp/a.jpg')],
      ], const ['p1']);
      notifier.setResumeFile(File('/tmp/cv.pdf'));

      final ok = await notifier.submitStep3();
      expect(ok, isTrue);
      final hits = telemetry.events
          .where((e) => e.name == AnalyticsEvents.signupCompleted)
          .toList();
      expect(hits, hasLength(1));
      expect(hits.single.parameters, {
        'has_resume': true,
        'has_featured_work': true,
        'social_count': 2,
      });
    });

    test('submitStep3 failure does not emit signup_completed', () async {
      final repo = _FakeAuthRepo()..step1Result = 12;
      repo.throwOnStep3 = Exception('boom');
      final telemetry = _RecordingTelemetry();
      final c = _container(repo, telemetry: telemetry);
      final notifier = c.read(signupNotifierProvider.notifier);
      notifier.setProfileImage(File('/tmp/a.png'));
      notifier.setSelectedDistance('Upto 50 Miles');
      notifier.setAcceptedTerms(true);
      notifier.setCurrentLatLng(const LatLng(0, 0));
      await notifier.submitStep1(
        firstName: 'A',
        lastName: 'B',
        email: 'a@b.com',
        phone: '1',
        password: 'pw',
        confirmPassword: 'pw',
        location: 'L',
      );
      final ok = await notifier.submitStep3();
      expect(ok, isFalse);
      expect(
        telemetry.events
            .where((e) => e.name == AnalyticsEvents.signupCompleted),
        isEmpty,
      );
    });
  });
}
